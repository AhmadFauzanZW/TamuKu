import '../entities/guest_entity.dart';

abstract class GuestRepository {
  Future<List<GuestEntity>> getGuests(String locationId);
  Future<GuestEntity> getGuestById(String guestId);
  Future<void> checkIn(GuestEntity guest);
  Future<void> checkOut(String guestId);
  Stream<List<GuestEntity>> watchGuests(String locationId);
}
