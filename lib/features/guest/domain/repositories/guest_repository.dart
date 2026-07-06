import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/guest_entity.dart';

/// Abstract repository interface for guest data operations.
///
/// Defines the contract for guest CRUD, check-in/check-out,
/// and real-time streaming. Implementations handle remote (Firestore)
/// and local (Hive/SQLite) data sources with offline-first strategy.
abstract class GuestRepository {
  /// Fetches all guests for a given [locationId].
  ///
  /// Returns [ServerFailure] on remote error, [CacheFailure] if
  /// no local data is available when offline.
  Future<Either<Failure, List<GuestEntity>>> getGuests(String locationId);

  /// Fetches a single guest by [guestId].
  ///
  /// Returns [ServerFailure] if the guest cannot be found or fetched.
  Future<Either<Failure, GuestEntity>> getGuest(String guestId);

  /// Records a new guest check-in.
  ///
  /// Writes to local storage first, then syncs to Firestore when online.
  /// Returns [ServerFailure] on remote sync failure.
  Future<Either<Failure, void>> checkIn(GuestEntity guest);

  /// Records a guest check-out by [guestId] with the given [checkOutTime].
  ///
  /// Returns [ServerFailure] on remote error, [CacheFailure] if
  /// local update fails.
  Future<Either<Failure, void>> checkOut(String guestId, DateTime checkOutTime);

  /// Updates an existing guest record.
  ///
  /// Returns [ServerFailure] on remote error, [CacheFailure] if
  /// local update fails.
  Future<Either<Failure, void>> updateGuest(GuestEntity guest);

  /// Deletes a guest record by [guestId].
  ///
  /// Returns [ServerFailure] on remote error, [CacheFailure] if
  /// local delete fails.
  Future<Either<Failure, void>> deleteGuest(String guestId);

  /// Streams real-time guest updates for a given [locationId].
  ///
  /// Emits a new list whenever the Firestore snapshot changes.
  Stream<List<GuestEntity>> watchGuests(String locationId);
}
