import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';

/// Abstract interface for local (offline) authentication caching.
///
/// Stores the signed-in user so the app can restore an authenticated
/// session when Firebase is unreachable (Concept F — offline fallback).
abstract class AuthLocalDataSource {
  /// Caches the [user] map as a JSON string.
  Future<void> cacheUser(Map<String, dynamic> user);

  /// Returns the cached user map, or `null` if none is stored.
  Future<Map<String, dynamic>?> getCachedUser();

  /// Clears the cached user (used on sign-out).
  Future<void> clearCache();
}

/// Hive implementation of [AuthLocalDataSource].
///
/// The user is stored as a single JSON-encoded string under [_userKey],
/// mirroring how `GuestLocalDataSourceImpl` persists JSON in its box.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Creates an [AuthLocalDataSourceImpl] backed by [box].
  AuthLocalDataSourceImpl({required Box<String> box}) : _box = box;

  final Box<String> _box;

  /// Hive key under which the cached user JSON is stored.
  static const String _userKey = 'currentUser';

  @override
  Future<void> cacheUser(Map<String, dynamic> user) async {
    await _box.put(_userKey, jsonEncode(user));
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() async {
    final raw = _box.get(_userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const CacheException('Data pengguna lokal rusak.');
    }
  }

  @override
  Future<void> clearCache() async {
    await _box.delete(_userKey);
  }
}
