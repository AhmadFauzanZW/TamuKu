abstract class LocationLocalDataSource {
  Future<Map<String, dynamic>?> getCachedLocation(String locationId);
  Future<void> cacheLocation(Map<String, dynamic> location);
  Future<void> clearCache();
}
