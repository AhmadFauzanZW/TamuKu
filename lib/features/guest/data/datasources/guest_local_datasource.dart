import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/guest_entity.dart';

/// Abstract interface for local guest data operations via Hive.
///
/// Provides offline fallback caching when Firestore is unreachable.
abstract class GuestLocalDataSource {
  /// Returns cached guests filtered by [locationId].
  Future<List<GuestEntity>> getCachedGuests(String locationId);

  /// Overwrites the guest cache with [guests] for [locationId].
  Future<void> cacheGuests(List<GuestEntity> guests, String locationId);

  /// Adds or updates a single [guest] in the cache.
  Future<void> cacheGuest(GuestEntity guest);

  /// Removes a single guest by [guestId] from the cache.
  Future<void> removeCachedGuest(String guestId);

  /// Clears all cached guest data.
  Future<void> clearCache();
}

/// Hive implementation of [GuestLocalDataSource].
///
/// Guests are stored as JSON-encoded strings keyed by their [guestId].
/// A secondary index (`_locationKey`) maps each location to its guest ID list
/// so filtering by [locationId] does not require a full scan.
class GuestLocalDataSourceImpl implements GuestLocalDataSource {
  /// Creates a [GuestLocalDataSourceImpl] with an optional [Box] override.
  GuestLocalDataSourceImpl({Box<String>? box}) : _box = box;

  final Box<String>? _box;

  /// Lazy-opened Hive box for guest JSON strings.
  Box<String> get _guestBox => _box ?? Hive.box(AppConstants.boxNameGuests);

  static const String _locationIndexKey = '_locationIndex';

  Map<String, List<String>> _locationIndex() {
    final raw = _guestBox.get(_locationIndexKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, List<String>.from(v as List)),
    );
  }

  Future<void> _saveLocationIndex(Map<String, List<String>> index) async {
    await _guestBox.put(_locationIndexKey, jsonEncode(index));
  }

  @override
  Future<List<GuestEntity>> getCachedGuests(String locationId) async {
    final index = _locationIndex();
    final ids = index[locationId] ?? [];

    return ids
        .map((id) => _guestBox.get(id))
        .where((raw) => raw != null)
        .map(
          (raw) =>
              GuestEntity.fromMap(jsonDecode(raw!) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> cacheGuests(List<GuestEntity> guests, String locationId) async {
    final index = _locationIndex();
    final ids = <String>[];

    for (final guest in guests) {
      await _guestBox.put(guest.guestId, jsonEncode(guest.toMap()));
      ids.add(guest.guestId);
    }

    index[locationId] = ids;
    await _saveLocationIndex(index);
  }

  @override
  Future<void> cacheGuest(GuestEntity guest) async {
    await _guestBox.put(guest.guestId, jsonEncode(guest.toMap()));

    final index = _locationIndex();
    final ids = index[guest.locationId] ?? [];
    if (!ids.contains(guest.guestId)) {
      ids.add(guest.guestId);
      index[guest.locationId] = ids;
      await _saveLocationIndex(index);
    }
  }

  @override
  Future<void> removeCachedGuest(String guestId) async {
    await _guestBox.delete(guestId);

    final index = _locationIndex();
    for (final entry in index.entries) {
      if (entry.value.remove(guestId)) break;
    }
    await _saveLocationIndex(index);
  }

  @override
  Future<void> clearCache() async {
    await _guestBox.clear();
  }
}
