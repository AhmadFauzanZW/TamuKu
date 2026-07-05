class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Auth error']);
  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation error']);
  @override
  String toString() => 'ValidationException: $message';
}
