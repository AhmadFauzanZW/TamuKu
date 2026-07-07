import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_datasource.dart';
import '../datasources/location_remote_datasource.dart';

/// Offline-first implementation of [LocationRepository].
///
/// **Read path**: remote → cache locally → return. On failure: local fallback.
/// **Write path**: local first (immediate) → remote when online.
/// **Stream**: passes through remote stream directly.
class LocationRepositoryImpl implements LocationRepository {
  /// Creates a [LocationRepositoryImpl].
  LocationRepositoryImpl({
    required LocationRemoteDataSource remote,
    required LocationLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final LocationRemoteDataSource _remote;
  final LocationLocalDataSource _local;
  final NetworkInfo _networkInfo;

  // ─── Read Operations ──────────────────────────────────────────

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    if (await _networkInfo.isConnected) {
      try {
        final locations = await _remote.watchLocations().first;
        await _local.cacheLocations(locations);
        return Right(locations);
      } catch (_) {
        final cached = await _local.getCachedLocations();
        return cached.isNotEmpty
            ? Right(cached)
            : const Left(ServerFailure());
      }
    } else {
      final cached = await _local.getCachedLocations();
      return cached.isNotEmpty ? Right(cached) : const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> getLocation(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final location = await _remote.getLocationById(id);
        await _local.cacheLocation(location);
        return Right(location);
      } catch (_) {
        final cached = await _local.getCachedLocation(id);
        return cached != null
            ? Right(cached)
            : const Left(ServerFailure());
      }
    } else {
      final cached = await _local.getCachedLocation(id);
      return cached != null
          ? Right(cached)
          : const Left(CacheFailure('Data lokasi tidak tersedia secara offline'));
    }
  }

  // ─── Write Operations (local-first) ───────────────────────────

  @override
  Future<Either<Failure, void>> createLocation(
    LocationEntity location,
  ) async {
    await _local.cacheLocation(location);
    if (await _networkInfo.isConnected) {
      try {
        await _remote.createLocation(location);
      } catch (_) {
        // Write already cached locally; will retry on next sync.
      }
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateLocation(
    LocationEntity location,
  ) async {
    await _local.cacheLocation(location);
    if (await _networkInfo.isConnected) {
      try {
        await _remote.updateLocation(location);
      } catch (_) {
        // Write already cached locally; will retry on next sync.
      }
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String id) async {
    await _local.removeCachedLocation(id);
    if (await _networkInfo.isConnected) {
      try {
        await _remote.deleteLocation(id);
      } catch (_) {
        // Delete already applied locally; will retry on next sync.
      }
    }
    return const Right(null);
  }

  // ─── Stream ───────────────────────────────────────────────────

  @override
  Stream<List<LocationEntity>> watchLocations() {
    return _remote.watchLocations();
  }
}
