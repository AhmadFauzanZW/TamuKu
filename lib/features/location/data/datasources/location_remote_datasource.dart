abstract class LocationRemoteDataSource {
  Future<Map<String, dynamic>> getLocationById(String locationId);
  Future<List<Map<String, dynamic>>> getLocationsByAdmin(String adminId);
  Future<void> createLocation(Map<String, dynamic> location);
  Future<void> updateLocation(Map<String, dynamic> location);
}
