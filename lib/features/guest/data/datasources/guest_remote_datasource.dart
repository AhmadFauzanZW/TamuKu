abstract class GuestRemoteDataSource {
  Future<List<Map<String, dynamic>>> getGuests(String locationId);
  Future<Map<String, dynamic>> getGuestById(String guestId);
  Future<void> checkIn(Map<String, dynamic> guest);
  Future<void> checkOut(String guestId);
}
