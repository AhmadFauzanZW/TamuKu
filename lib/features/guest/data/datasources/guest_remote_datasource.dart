import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/guest_entity.dart';

/// Abstract interface for remote guest data operations via Cloud Firestore.
abstract class GuestRemoteDataSource {
  /// Fetches all guests belonging to [locationId], ordered by check-in time.
  Future<List<GuestEntity>> getGuests(String locationId);

  /// Fetches a single guest by [guestId].
  Future<GuestEntity> getGuest(String guestId);

  /// Records a new guest check-in by adding a Firestore document.
  Future<void> checkIn(GuestEntity guest);

  /// Updates [guestId] with [checkOutTime] and sets status to checked out.
  Future<void> checkOut(String guestId, DateTime checkOutTime);

  /// Updates an existing guest document in Firestore.
  Future<void> updateGuest(GuestEntity guest);

  /// Deletes a guest document by [guestId].
  Future<void> deleteGuest(String guestId);

  /// Streams real-time guest updates for a given [locationId].
  Stream<List<GuestEntity>> watchGuests(String locationId);
}

/// Firestore implementation of [GuestRemoteDataSource].
///
/// Uses [GuestEntity.fromFirestore] for reads and [GuestEntity.toFirestore]
/// for writes to keep serialization centralized.
class GuestRemoteDataSourceImpl implements GuestRemoteDataSource {
  /// Creates a [GuestRemoteDataSourceImpl] with optional [FirebaseFirestore] override.
  GuestRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore collection reference for guests.
  CollectionReference<Map<String, dynamic>> get _guests =>
      _firestore.collection(AppConstants.guestsCollection);

  @override
  Future<List<GuestEntity>> getGuests(String locationId) async {
    final snapshot = await _guests
        .where(AppConstants.fieldLocationId, isEqualTo: locationId)
        .orderBy(AppConstants.fieldCheckInTime, descending: true)
        .get();

    return snapshot.docs.map(GuestEntity.fromFirestore).toList();
  }

  @override
  Future<GuestEntity> getGuest(String guestId) async {
    final doc = await _guests.doc(guestId).get();

    if (!doc.exists || doc.data() == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Tamu dengan ID $guestId tidak ditemukan',
      );
    }

    return GuestEntity.fromFirestore(doc);
  }

  @override
  Future<void> checkIn(GuestEntity guest) async {
    await _guests.add(guest.toFirestore());
  }

  @override
  Future<void> checkOut(String guestId, DateTime checkOutTime) async {
    await _guests.doc(guestId).update({
      AppConstants.fieldCheckOutTime: Timestamp.fromDate(checkOutTime),
      AppConstants.fieldStatus: AppConstants.statusCheckedOut,
    });
  }

  @override
  Future<void> updateGuest(GuestEntity guest) async {
    await _guests.doc(guest.guestId).update(guest.toFirestore());
  }

  @override
  Future<void> deleteGuest(String guestId) async {
    await _guests.doc(guestId).delete();
  }

  @override
  Stream<List<GuestEntity>> watchGuests(String locationId) {
    return _guests
        .where(AppConstants.fieldLocationId, isEqualTo: locationId)
        .orderBy(AppConstants.fieldCheckInTime, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(GuestEntity.fromFirestore).toList(),
        );
  }
}
