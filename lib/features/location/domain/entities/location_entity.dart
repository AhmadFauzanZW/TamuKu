import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Domain entity representing a physical location in the system.
///
/// Each location has its own QR code, host phone for notifications,
/// and tracks multiple guests via [GuestEntity.locationId].
class LocationEntity extends Equatable {
  /// Auto-generated Firestore document ID.
  final String locationId;

  /// Display name of the location (e.g. "Kantor Desa Cakrawala").
  final String name;

  /// Physical address of the location.
  final String address;

  /// Firebase UID of the admin who owns this location.
  final String adminId;

  /// WhatsApp phone number of the host for notifications.
  final String hostPhone;

  /// Unique value encoded in the QR code for this location.
  final String qrCodeValue;

  /// Timestamp when the location was created.
  final DateTime createdAt;

  /// Whether this location is active and accepting guests.
  final bool isActive;

  /// Creates a [LocationEntity].
  const LocationEntity({
    required this.locationId,
    required this.name,
    required this.address,
    required this.adminId,
    required this.hostPhone,
    required this.qrCodeValue,
    required this.createdAt,
    this.isActive = true,
  });

  /// Creates a [LocationEntity] from a Firestore document snapshot.
  factory LocationEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return LocationEntity(
      locationId: doc.id,
      name: data[AppConstants.fieldName] as String,
      address: data[AppConstants.fieldAddress] as String? ?? '',
      adminId: data[AppConstants.fieldAdminId] as String? ?? '',
      hostPhone: data[AppConstants.fieldHostPhone] as String? ?? '',
      qrCodeValue: data['qrCodeValue'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Serializes to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => {
    AppConstants.fieldName: name,
    AppConstants.fieldAddress: address,
    AppConstants.fieldAdminId: adminId,
    AppConstants.fieldHostPhone: hostPhone,
    'qrCodeValue': qrCodeValue,
    'createdAt': Timestamp.fromDate(createdAt),
    'isActive': isActive,
  };

  /// Serializes to a JSON-compatible map (for local storage).
  Map<String, dynamic> toMap() => {
    'locationId': locationId,
    'name': name,
    'address': address,
    'adminId': adminId,
    'hostPhone': hostPhone,
    'qrCodeValue': qrCodeValue,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  /// Deserializes from a JSON map.
  factory LocationEntity.fromMap(Map<String, dynamic> map) => LocationEntity(
    locationId: map['locationId'] as String,
    name: map['name'] as String,
    address: map['address'] as String? ?? '',
    adminId: map['adminId'] as String? ?? '',
    hostPhone: map['hostPhone'] as String? ?? '',
    qrCodeValue: map['qrCodeValue'] as String? ?? '',
    createdAt: DateTime.parse(map['createdAt'] as String),
    isActive: map['isActive'] as bool? ?? true,
  );

  /// Returns a copy with optional field overrides.
  LocationEntity copyWith({
    String? locationId,
    String? name,
    String? address,
    String? adminId,
    String? hostPhone,
    String? qrCodeValue,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return LocationEntity(
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      address: address ?? this.address,
      adminId: adminId ?? this.adminId,
      hostPhone: hostPhone ?? this.hostPhone,
      qrCodeValue: qrCodeValue ?? this.qrCodeValue,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object> get props => [
    locationId,
    name,
    address,
    adminId,
    hostPhone,
    qrCodeValue,
    createdAt,
    isActive,
  ];
}
