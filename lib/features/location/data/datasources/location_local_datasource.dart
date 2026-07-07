import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/location_entity.dart';

/// Abstract interface for local location data operations via Hive.
///
/// Provides offline fallback caching when Firestore is unreachable.
abstract class LocationLocalDataSource {
  /// Returns all cached locations.
  Future<List<LocationEntity>> getCachedLocations();

  /// Returns a single cached location by [locationId].
  Future<LocationEntity?> getCachedLocation(String locationId);

  /// Overwrites the location cache with [locations].
  Future<void> cacheLocations(List<LocationEntity> locations);

  /// Adds or updates a single [location] in the cache.
  Future<void> cacheLocation(LocationEntity location);

  /// Removes a single location by [locationId] from the cache.
  Future<void> removeCachedLocation(String locationId);

  /// Clears all cached location data.
  Future<void> clearCache();
}

/// Hive implementation of [LocationLocalDataSource].
///
/// Locations are stored as JSON-encoded strings keyed by their [locationId].
class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  /// Creates a [LocationLocalDataSourceImpl] with an optional [Box] override.
  LocationLocalDataSourceImpl({Box<String>? box}) : _box = box;

  final Box<String>? _box;

  /// Lazy-opened Hive box for location JSON strings.
  Box<String> get _locationBox =>
      _box ?? Hive.box(AppConstants.boxNameLocations);

  static const String _allIdsKey = '_allIds';

  List<String> _allIds() {
    final raw = _locationBox.get(_allIdsKey);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw) as List);
  }

  Future<void> _saveAllIds(List<String> ids) async {
    await _locationBox.put(_allIdsKey, jsonEncode(ids));
  }

  @override
  Future<List<LocationEntity>> getCachedLocations() async {
    final ids = _allIds();
    return ids
        .map((id) => _locationBox.get(id))
        .where((raw) => raw != null)
        .map(
          (raw) =>
              LocationEntity.fromMap(jsonDecode(raw!) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<LocationEntity?> getCachedLocation(String locationId) async {
    final raw = _locationBox.get(locationId);
    if (raw == null) return null;
    return LocationEntity.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> cacheLocations(List<LocationEntity> locations) async {
    final ids = <String>[];
    for (final loc in locations) {
      await _locationBox.put(loc.locationId, jsonEncode(loc.toMap()));
      ids.add(loc.locationId);
    }
    await _saveAllIds(ids);
  }

  @override
  Future<void> cacheLocation(LocationEntity location) async {
    await _locationBox.put(location.locationId, jsonEncode(location.toMap()));

    final ids = _allIds();
    if (!ids.contains(location.locationId)) {
      ids.add(location.locationId);
      await _saveAllIds(ids);
    }
  }

  @override
  Future<void> removeCachedLocation(String locationId) async {
    await _locationBox.delete(locationId);
    final ids = _allIds();
    ids.remove(locationId);
    await _saveAllIds(ids);
  }

  @override
  Future<void> clearCache() async {
    await _locationBox.clear();
  }
}
