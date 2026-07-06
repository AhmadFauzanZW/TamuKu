import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/guest_entity.dart';
import '../../domain/repositories/guest_repository.dart';
import 'guest_event.dart';
import 'guest_state.dart';

/// BLoC that manages guest check-in/check-out state.
///
/// Handles loading, real-time watching, check-in, check-out,
/// deletion, and local search filtering of guests.
class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository _repository;
  StreamSubscription<List<GuestEntity>>? _guestsSubscription;

  /// Cache of all loaded guests for local search filtering.
  List<GuestEntity> _allGuests = [];

  /// Creates a [GuestBloc] with the given [repository].
  GuestBloc({required GuestRepository repository})
    : _repository = repository,
      super(GuestInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<CheckInRequested>(_onCheckInRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
    on<DeleteGuest>(_onDeleteGuest);
    on<WatchGuestsStarted>(_onWatchGuestsStarted);
    on<_GuestsUpdated>(_onGuestsUpdated);
    on<SearchGuests>(_onSearchGuests);
  }

  /// Loads all guests for the given [locationId].
  Future<void> _onLoadGuests(LoadGuests event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    final result = await _repository.getGuests(event.locationId);
    result.fold((failure) => emit(GuestError(failure.message)), (guests) {
      _allGuests = guests;
      emit(GuestLoaded(guests));
    });
  }

  /// Processes a new guest check-in.
  Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<GuestState> emit,
  ) async {
    emit(GuestLoading());
    final guest = GuestEntity(
      guestId: '',
      name: event.name,
      phone: event.phone,
      email: event.email,
      keperluan: event.keperluan,
      instansi: event.instansi,
      photoUrl: event.photoUrl,
      locationId: event.locationId,
      hostPhone: event.hostPhone,
      checkInTime: DateTime.now(),
    );
    final result = await _repository.checkIn(guest);
    result.fold(
      (failure) => emit(GuestError(failure.message)),
      (_) => emit(const GuestOperationSuccess('Check-in berhasil')),
    );
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
    _guestsSubscription?.cancel();
    _guestsSubscription = _repository.watchGuests(event.locationId).listen((
      guests,
    ) {
      _allGuests = guests;
      add(_GuestsUpdated(guests));
    });
  }

  /// Handles real-time guest list updates from the stream.
  Future<void> _onGuestsUpdated(
    _GuestsUpdated event,
    Emitter<GuestState> emit,
  ) async {
    emit(GuestLoaded(event.guests));
  }

  /// Filters the cached guest list by [query] (local, no repository call).
  void _onSearchGuests(SearchGuests event, Emitter<GuestState> emit) {
    if (event.query.isEmpty) {
      emit(GuestLoaded(_allGuests));
      return;
    }
    final filtered = _allGuests
        .where((g) => g.name.toLowerCase().contains(event.query.toLowerCase()))
        .toList();
    emit(GuestLoaded(filtered));
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
