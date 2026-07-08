import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/guest_entity.dart';
import '../../domain/repositories/guest_repository.dart';
import '../../../notification/domain/repositories/notification_repository.dart';
import 'guest_event.dart';
import 'guest_state.dart';

/// BLoC that manages guest check-in/check-out state.
///
/// Handles loading, real-time watching, check-in, check-out,
/// deletion, and local search filtering of guests.
class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository _repository;
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<GuestEntity>>? _guestsSubscription;

  /// Cache of all loaded guests for local search filtering.
  List<GuestEntity> _allGuests = [];

  /// Current search query for local text search.
  String _searchQuery = '';

  /// Active status filter ('Semua', 'Check-In', or 'Selesai').
  String _activeFilter = 'Semua';

  /// Current sort type for the guest list.
  SortType _sortType = SortType.byDateDesc;

  /// Creates a [GuestBloc] with the given [repository].
  GuestBloc({
    required GuestRepository repository,
    NotificationRepository? notificationRepository,
  }) : _repository = repository,
       _notificationRepository =
           notificationRepository ?? _NoOpNotificationRepository(),
       super(GuestInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<CheckInRequested>(_onCheckInRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
    on<DeleteGuest>(_onDeleteGuest);
    on<WatchGuestsStarted>(_onWatchGuestsStarted);
    on<_GuestsUpdated>(_onGuestsUpdated);
    on<SearchGuests>(_onSearchGuests);
    on<FilterGuests>(_onFilterGuests);
    on<SortGuests>(_onSortGuests);
  }

  /// Loads all guests for the given [locationId].
  Future<void> _onLoadGuests(LoadGuests event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    final result = await _repository.getGuests(event.locationId);
    result.fold((failure) => emit(GuestError(failure.message)), (guests) {
      _allGuests = guests;
      _applyFilterAndSort(emit);
    });
  }

  /// Processes a new guest check-in.
  Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<GuestState> emit,
  ) async {
    emit(GuestLoading());
    final now = DateTime.now();
    final guest = GuestEntity(
      guestId: '',
      name: event.name,
      phone: event.phone,
      email: event.email,
      keperluan: event.keperluan,
      keperluanLainnya: event.keperluanLainnya,
      instansi: event.instansi,
      photoUrl: event.photoUrl,
      locationId: event.locationId,
      hostPhone: event.hostPhone,
      checkInTime: now,
    );
    final result = await _repository.checkIn(guest);
    result.fold((failure) => emit(GuestError(failure.message)), (_) {
      emit(const GuestOperationSuccess('Check-in berhasil'));
      _sendCheckInNotification(event, now);
    });
  }

  /// Sends Telegram notification to host (fire-and-forget, non-blocking).
  void _sendCheckInNotification(CheckInRequested event, DateTime checkInTime) {
    if (event.hostPhone == null || event.hostPhone!.isEmpty) return;
    final timeStr =
        '${checkInTime.day.toString().padLeft(2, '0')}/'
        '${checkInTime.month.toString().padLeft(2, '0')}/'
        '${checkInTime.year} '
        '${checkInTime.hour.toString().padLeft(2, '0')}:'
        '${checkInTime.minute.toString().padLeft(2, '0')}';
    _notificationRepository
        .sendTelegramMessage(
          phoneNumber: event.hostPhone!,
          guestName: event.name,
          locationName: event.locationId,
          checkInTime: timeStr,
        )
        // ignore: avoid_catches_without_on_clauses
        .catchError((_) {});
  }

  /// Processes a guest check-out.
  Future<void> _onCheckOutRequested(
    CheckOutRequested event,
    Emitter<GuestState> emit,
  ) async {
    emit(GuestLoading());
    final result = await _repository.checkOut(event.guestId, DateTime.now());
    result.fold(
      (failure) => emit(GuestError(failure.message)),
      (_) => emit(const GuestOperationSuccess('Check-out berhasil')),
    );
  }

  /// Deletes a guest record by [guestId].
  Future<void> _onDeleteGuest(
    DeleteGuest event,
    Emitter<GuestState> emit,
  ) async {
    emit(GuestLoading());
    final result = await _repository.deleteGuest(event.guestId);
    result.fold(
      (failure) => emit(GuestError(failure.message)),
      (_) => emit(const GuestOperationSuccess('Tamu berhasil dihapus')),
    );
  }

  /// Subscribes to real-time guest updates via [StreamSubscription].
  ///
  /// Cancels any existing subscription before starting a new one.
  void _onWatchGuestsStarted(
    WatchGuestsStarted event,
    Emitter<GuestState> emit,
  ) {
    emit(GuestLoading());
    _guestsSubscription?.cancel();
    _guestsSubscription =
        _repository.watchGuests(event.locationId).listen((guests) {
          _allGuests = guests;
          add(_GuestsUpdated(guests));
        })..onError((error) {
          debugPrint('Guest stream error: $error');
          emit(GuestError('Gagal memuat data tamu: $error'));
        });
  }

  /// Handles real-time guest list updates from the stream.
  Future<void> _onGuestsUpdated(
    _GuestsUpdated event,
    Emitter<GuestState> emit,
  ) async {
    _allGuests = event.guests;
    _applyFilterAndSort(emit);
  }

  /// Filters the cached guest list by [query] (local, no repository call).
  void _onSearchGuests(SearchGuests event, Emitter<GuestState> emit) {
    _searchQuery = event.query;
    _applyFilterAndSort(emit);
  }

  /// Applies the current status filter and sort to [_allGuests].
  void _applyFilterAndSort(Emitter<GuestState> emit) {
    var filtered = List<GuestEntity>.from(_allGuests);

    // Apply text search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply status filter
    if (_activeFilter != 'Semua') {
      final statusFilter = _activeFilter == 'Check-In'
          ? GuestStatus.checkedIn
          : GuestStatus.checkedOut;
      filtered = filtered.where((g) => g.status == statusFilter).toList();
    }

    // Apply sort
    switch (_sortType) {
      case SortType.byDateDesc:
        filtered.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
        break;
      case SortType.byDateAsc:
        filtered.sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
        break;
      case SortType.byNameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    emit(
      GuestLoaded(filtered, activeFilter: _activeFilter, sortType: _sortType),
    );
  }

  /// Updates the active status filter and reapplies filter+sort.
  void _onFilterGuests(FilterGuests event, Emitter<GuestState> emit) {
    _activeFilter = event.filter;
    _applyFilterAndSort(emit);
  }

  /// Updates the sort type and reapplies filter+sort.
  void _onSortGuests(SortGuests event, Emitter<GuestState> emit) {
    _sortType = event.sortType;
    _applyFilterAndSort(emit);
  }

  @override
  Future<void> close() {
    _guestsSubscription?.cancel();
    return super.close();
  }
}

/// Internal event for stream updates (not exposed publicly).
class _GuestsUpdated extends GuestEvent {
  final List<GuestEntity> guests;
  const _GuestsUpdated(this.guests);
  @override
  List<Object> get props => [guests];
}

/// No-op fallback when no [NotificationRepository] is provided.
class _NoOpNotificationRepository implements NotificationRepository {
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> getToken() async => null;
  @override
  Future<void> subscribeToTopic(String topic) async {}
  @override
  Future<void> sendTelegramMessage({
    required String phoneNumber,
    required String guestName,
    required String locationName,
    required String checkInTime,
  }) async {}
}
