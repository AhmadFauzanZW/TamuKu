import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import '../constants/app_constants.dart';
import '../models/sync_operation.dart';
import '../../features/guest/data/datasources/guest_remote_datasource.dart';
import '../../features/guest/domain/entities/guest_entity.dart';
import '../network/network_info.dart';

/// Service to manage pending writes that failed when offline.
///
/// When connectivity is restored, [processQueue] retries all pending
/// operations stored in Hive box('sync_queue').
class SyncQueueService {
  /// Creates a [SyncQueueService].
  SyncQueueService({
    required GuestRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    Box<String>? syncBox,
  })  : _remote = remoteDataSource,
        _networkInfo = networkInfo,
        _syncBox = syncBox;

  final GuestRemoteDataSource _remote;
  final NetworkInfo _networkInfo;
  final Box<String>? _syncBox;

  /// Hive box for sync queue entries.
  Box<String> get _box =>
      _syncBox ?? Hive.box(AppConstants.boxNameSyncQueue);

  final _isSyncingController = StreamController<bool>.broadcast();

  /// Stream that emits `true` when the queue is being processed.
  Stream<bool> get isSyncing => _isSyncingController.stream;

  /// Adds a failed write operation to the queue.
  Future<void> addToQueue(SyncOperation operation) async {
    await _box.put(operation.id, jsonEncode(operation.toMap()));
  }

  /// Returns all pending operations ordered by creation time.
  Future<List<SyncOperation>> getPendingOperations() async {
    final operations = _box.values
        .map((raw) => SyncOperation.fromMap(
              jsonDecode(raw) as Map<String, dynamic>,
            ))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return operations;
  }

  /// Processes all pending operations when connectivity is restored.
  ///
  /// Iterates through the queue, attempts each operation, and removes
  /// successful entries. Failed operations remain for the next retry.
  Future<int> processQueue() async {
    if (!await _networkInfo.isConnected) return 0;

    _isSyncingController.add(true);
    var processed = 0;

    try {
      if (!await _networkInfo.isConnected) return 0;

      final pending = await getPendingOperations();

      for (final op in pending) {
        try {
          await _executeOperation(op);
          await _box.delete(op.id);
          processed++;
        } catch (_) {
          // Keep in queue for next retry.
        }
      }
    } finally {
      _isSyncingController.add(false);
    }

    return processed;
  }

  /// Executes a single [SyncOperation] against the remote data source.
  Future<void> _executeOperation(SyncOperation op) async {
    final payload = op.payload;

    switch (op.operation) {
      case 'check_in':
        final guest = GuestEntity.fromMap(payload);
        await _remote.checkIn(guest);
      case 'check_out':
        final guestId = payload['guestId'] as String;
        final checkOutTime = DateTime.parse(payload['checkOutTime'] as String);
        await _remote.checkOut(guestId, checkOutTime);
      case 'update_guest':
        final guest = GuestEntity.fromMap(payload);
        await _remote.updateGuest(guest);
      case 'delete_guest':
        final guestId = payload['guestId'] as String;
        await _remote.deleteGuest(guestId);
    }
  }

  /// Removes all entries from the sync queue.
  Future<void> clearQueue() async {
    await _box.clear();
  }

  /// Disposes internal resources.
  void dispose() {
    _isSyncingController.close();
  }
}
