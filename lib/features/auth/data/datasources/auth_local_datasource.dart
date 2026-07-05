abstract class AuthLocalDataSource {
  Future<void> cacheUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getCachedUser();
  Future<void> clearCache();
}
