import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/guest_repository.dart';
import '../../domain/entities/guest_entity.dart';
import 'guest_event.dart';
import 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository _guestRepository;

  GuestBloc({required GuestRepository guestRepository})
      : _guestRepository = guestRepository,
        super(GuestInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<CheckInRequested>(_onCheckInRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
    on<SearchGuests>(_onSearchGuests);
  }

  Future<void> _onLoadGuests(LoadGuests event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    try {
      final guests = await _guestRepository.getGuests(event.locationId);
      emit(GuestLoaded(guests));
    } catch (e) {
      emit(GuestError(e.toString()));
    }
  }

  Future<void> _onCheckInRequested(CheckInRequested event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    try {
      final guest = GuestEntity(
        guestId: '',
        name: event.name,
        phone: event.phone,
        email: event.email,
        keperluan: event.keperluan,
        instansi: event.instansi,
        locationId: event.locationId,
        checkInTime: DateTime.now(),
      );
      await _guestRepository.checkIn(guest);
      emit(GuestCheckInSuccess(guest));
    } catch (e) {
      emit(GuestError(e.toString()));
    }
  }

  Future<void> _onCheckOutRequested(CheckOutRequested event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    try {
      await _guestRepository.checkOut(event.guestId);
      emit(GuestCheckOutSuccess(event.guestId));
    } catch (e) {
      emit(GuestError(e.toString()));
    }
  }

  Future<void> _onSearchGuests(SearchGuests event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    try {
      final guests = await _guestRepository.getGuests('');
      final filtered = guests
          .where((g) => g.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(GuestLoaded(filtered));
    } catch (e) {
      emit(GuestError(e.toString()));
    }
  }
}
