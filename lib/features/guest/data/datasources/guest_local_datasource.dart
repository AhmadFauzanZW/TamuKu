abstract class GuestLocalDataSource {
  Future<List<Map<String, dynamic>>> getCachedGuests(String locationId);
  Future<void> cacheGuests(String locationId, List<Map<String, dynamic>> guests);
  Future<void> deleteCachedGuest(String guestId);
}
