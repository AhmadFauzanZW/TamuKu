import 'package:equatable/equatable.dart';

/// Represents a pending write operation stored in the sync queue.
///
/// Created when a write fails due to offline status. Processed by
/// [SyncQueueService] when connectivity is restored.
class SyncOperation extends Equatable {
  /// Unique identifier for this operation.
  final String id;

  /// Operation type: 'check_in', 'check_out', 'update_guest', 'delete_guest'.
  final String operation;

  /// Entity type being operated on (e.g. 'guest').
  final String entityType;

  /// Serialized payload data for the operation.
  final Map<String, dynamic> payload;

  /// Timestamp when the operation was queued.
  final DateTime createdAt;

  /// Creates a [SyncOperation].
  const SyncOperation({
    required this.id,
    required this.operation,
    required this.entityType,
    required this.payload,
    required this.createdAt,
  });

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'operation': operation,
        'entityType': entityType,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Deserializes from a JSON map.
  factory SyncOperation.fromMap(Map<String, dynamic> map) => SyncOperation(
        id: map['id'] as String,
        operation: map['operation'] as String,
        entityType: map['entityType'] as String,
        payload: Map<String, dynamic>.from(map['payload'] as Map),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  @override
  List<Object> get props => [id, operation, entityType, payload, createdAt];
}
