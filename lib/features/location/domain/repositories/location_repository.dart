import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/location_entity.dart';

/// Abstract repository interface for location data operations.
///
/// Defines the contract for location CRUD and real-time streaming.
/// Implementations handle remote (Firestore) and local (Hive) data sources
/// with offline-first strategy.
abstract class LocationRepository {
  /// Fetches all locations.
  ///
  /// Returns [ServerFailure] on remote error, [CacheFailure] if
  /// no local data is available when offline.
  Future<Either<Failure, List<LocationEntity>>> getLocations();

  /// Fetches a single location by [id].
  ///
  /// Returns [ServerFailure] on remote error, [CacheFailure] if
  /// the location cannot be found locally when offline.
  Future<Either<Failure, LocationEntity>> getLocation(String id);

  /// Creates a new [location] record.
  ///
  /// Writes to local cache first, then syncs to Firestore when online.
  Future<Either<Failure, void>> createLocation(LocationEntity location);

  /// Updates an existing [location] record.
  ///
  /// Writes to local cache first, then syncs to Firestore when online.
  Future<Either<Failure, void>> updateLocation(LocationEntity location);

  /// Deletes a location by [id].
  ///
  /// Removes from local cache first, then syncs deletion to Firestore.
  Future<Either<Failure, void>> deleteLocation(String id);

  /// Streams real-time location list updates.
  Stream<List<LocationEntity>> watchLocations();
}
