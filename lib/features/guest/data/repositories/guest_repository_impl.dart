import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/sync_operation.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/sync_queue_service.dart';
import '../../domain/entities/guest_entity.dart';
import '../../domain/repositories/guest_repository.dart';
import '../datasources/guest_local_datasource.dart';
import '../datasources/guest_remote_datasource.dart';

/// Offline-first implementation of [GuestRepository].
///
/// **Read path**: remote → cache locally → return. On failure: local fallback.
/// **Write path**: local first (immediate) → remote when online.
/// Failed remote writes are queued in [SyncQueueService] for later retry.
/// **Stream**: passes through remote stream directly.
class GuestRepositoryImpl implements GuestRepository {
  /// Creates a [GuestRepositoryImpl].
  GuestRepositoryImpl({
    required GuestRemoteDataSource remote,
    required GuestLocalDataSource local,
    required NetworkInfo networkInfo,
    SyncQueueService? syncQueue,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo,
       _syncQueue = syncQueue;

  final GuestRemoteDataSource _remote;
  final GuestLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final SyncQueueService? _syncQueue;

  // ─── Read Operations ──────────────────────────────────────────

  @override
  Future<Either<Failure, List<GuestEntity>>> getGuests(
    String locationId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final guests = await _remote.getGuests(locationId);
        await _local.cacheGuests(guests, locationId);
        return Right(guests);
      } catch (_) {
        final cached = await _local.getCachedGuests(locationId);
        return cached.isNotEmpty ? Right(cached) : const Left(ServerFailure());
      }
    } else {
      final cached = await _local.getCachedGuests(locationId);
      return cached.isNotEmpty ? Right(cached) : const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, GuestEntity>> getGuest(String guestId) async {
    if (await _networkInfo.isConnected) {
      try {
        final guest = await _remote.getGuest(guestId);
        await _local.cacheGuest(guest);
        return Right(guest);
      } catch (_) {
        return const Left(ServerFailure());
      }
    }
    // Local datasource lacks single-ID lookup — return cache failure.
    return const Left(CacheFailure('Data tamu tidak tersedia secara offline'));
  }

  // ─── Write Operations (local-first) ───────────────────────────

  @override
  Future<Either<Failure, void>> checkIn(GuestEntity guest) async {
    await _local.cacheGuest(guest);
    if (await _networkInfo.isConnected) {
      try {
        await _remote.checkIn(guest);
      } catch (_) {
        await _enqueueOperation('check_in', guest.toMap());
      }
    } else {
      await _enqueueOperation('check_in', guest.toMap());
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> checkOut(
    String guestId,
    DateTime checkOutTime,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remote.checkOut(guestId, checkOutTime);
        final guest = await _remote.getGuest(guestId);
        await _local.cacheGuest(guest);
        return const Right(null);
      } catch (_) {
        await _enqueueOperation('check_out', {
          'guestId': guestId,
          'checkOutTime': checkOutTime.toIso8601String(),
        });
        return const Right(null);
      }
    } else {
      await _enqueueOperation('check_out', {
        'guestId': guestId,
        'checkOutTime': checkOutTime.toIso8601String(),
      });
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> updateGuest(GuestEntity guest) async {
    await _local.cacheGuest(guest);
    if (await _networkInfo.isConnected) {
      try {
        await _remote.updateGuest(guest);
      } catch (_) {
        await _enqueueOperation('update_guest', guest.toMap());
      }
    } else {
      await _enqueueOperation('update_guest', guest.toMap());
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteGuest(String guestId) async {
    await _local.removeCachedGuest(guestId);
    if (await _networkInfo.isConnected) {
      try {
        await _remote.deleteGuest(guestId);
      } catch (_) {
        await _enqueueOperation('delete_guest', {'guestId': guestId});
      }
    } else {
      await _enqueueOperation('delete_guest', {'guestId': guestId});
    }
    return const Right(null);
  }

  // ─── Stream ───────────────────────────────────────────────────

  @override
  Stream<List<GuestEntity>> watchGuests(String locationId) {
    return _remote.watchGuests(locationId);
  }

  // ─── Sync Queue Helper ───────────────────────────────────────

  /// Enqueues a failed operation for later retry when online.
  Future<void> _enqueueOperation(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    if (_syncQueue == null) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _syncQueue.addToQueue(
      SyncOperation(
        id: id,
        operation: operation,
        entityType: 'guest',
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
  }
}
