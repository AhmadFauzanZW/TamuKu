import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/location_entity.dart';

/// Abstract interface for remote location data operations via Cloud Firestore.
abstract class LocationRemoteDataSource {
  /// Fetches a single location by [locationId].
  Future<LocationEntity> getLocationById(String locationId);

  /// Fetches all locations for a given [adminId].
  Future<List<LocationEntity>> getLocationsByAdmin(String adminId);

  /// Creates a new location document in Firestore.
  Future<void> createLocation(LocationEntity location);

  /// Updates an existing location document in Firestore.
  Future<void> updateLocation(LocationEntity location);

  /// Deletes a location document by [locationId].
  Future<void> deleteLocation(String locationId);

  /// Streams all locations for real-time updates.
  Stream<List<LocationEntity>> watchLocations();
}

/// Firestore implementation of [LocationRemoteDataSource].
///
/// Uses [LocationEntity.fromFirestore] for reads and [LocationEntity.toFirestore]
/// for writes to keep serialization centralized.
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  /// Creates a [LocationRemoteDataSourceImpl] with optional [FirebaseFirestore] override.
  LocationRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore collection reference for locations.
  CollectionReference<Map<String, dynamic>> get _locations =>
      _firestore.collection(AppConstants.locationsCollection);

  @override
  Future<LocationEntity> getLocationById(String locationId) async {
    final doc = await _locations.doc(locationId).get();

    if (!doc.exists || doc.data() == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Lokasi dengan ID $locationId tidak ditemukan',
      );
    }

    return LocationEntity.fromFirestore(doc);
  }

  @override
  Future<List<LocationEntity>> getLocationsByAdmin(String adminId) async {
    final snapshot = await _locations
        .where(AppConstants.fieldAdminId, isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(LocationEntity.fromFirestore).toList();
  }

  @override
  Future<void> createLocation(LocationEntity location) async {
    await _locations.add(location.toFirestore());
  }

  @override
  Future<void> updateLocation(LocationEntity location) async {
    await _locations.doc(location.locationId).update(location.toFirestore());
  }

  @override
  Future<void> deleteLocation(String locationId) async {
    await _locations.doc(locationId).delete();
  }

  @override
  Stream<List<LocationEntity>> watchLocations() {
    return _locations
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(LocationEntity.fromFirestore).toList(),
        );
  }
}
