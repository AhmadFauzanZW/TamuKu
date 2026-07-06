import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Represents the check-in/check-out status of a guest.
enum GuestStatus {
  /// Guest has checked in and is currently at the location.
  checkedIn,

  /// Guest has checked out.
  checkedOut,
}

/// Extension on [GuestStatus] for Firestore serialization.
extension GuestStatusX on GuestStatus {
  /// Convert enum value to Firestore-compatible string.
  String toValue() => switch (this) {
    GuestStatus.checkedIn => AppConstants.statusCheckedIn,
    GuestStatus.checkedOut => AppConstants.statusCheckedOut,
  };

  /// Parse Firestore string to [GuestStatus] enum.
  static GuestStatus fromValue(String value) => switch (value) {
    'checked_in' => GuestStatus.checkedIn,
    'checked_out' => GuestStatus.checkedOut,
    _ => GuestStatus.checkedIn,
  };
}

/// Represents the purpose of a guest's visit.
enum Keperluan {
  /// Business meeting.
  meeting,

  /// Personal visit.
  personal,

  /// Official office business.
  kantor,

  /// Package delivery.
  pengiriman,

  /// Other purpose.
  lainnya,
}

/// Extension on [Keperluan] for Firestore serialization.
extension KeperluanX on Keperluan {
  /// Convert enum value to Firestore-compatible string.
  String toValue() => switch (this) {
    Keperluan.meeting => 'Meeting',
    Keperluan.personal => 'Personal',
    Keperluan.kantor => 'Kantor',
    Keperluan.pengiriman => 'Pengiriman',
    Keperluan.lainnya => 'Lainnya',
  };

  /// Parse Firestore string to [Keperluan] enum.
  static Keperluan fromValue(String value) => switch (value) {
    'Meeting' => Keperluan.meeting,
    'Personal' => Keperluan.personal,
    'Kantor' => Keperluan.kantor,
    'Pengiriman' => Keperluan.pengiriman,
    _ => Keperluan.lainnya,
  };
}

/// Domain entity representing a guest record in the system.
///
/// Contains all data required for check-in/check-out tracking,
/// including guest information, visit purpose, and timestamps.
class GuestEntity extends Equatable {
  /// Auto-generated Firestore document ID.
  final String guestId;

  /// Guest's full name.
  final String name;

  /// Guest's WhatsApp phone number.
  final String phone;

  /// Guest's email address (optional).
  final String? email;

  /// Purpose of the visit.
  final Keperluan keperluan;

  /// Guest's institution or company (optional).
  final String? instansi;

  /// URL to the guest's photo (optional).
  final String? photoUrl;

  /// Foreign key referencing the visited location.
  final String locationId;

  /// Timestamp when the guest checked in.
  final DateTime checkInTime;

  /// Timestamp when the guest checked out (null if still present).
  final DateTime? checkOutTime;

  /// Host's WhatsApp phone number for notifications.
  final String? hostPhone;

  /// Current check-in/check-out status.
  final GuestStatus status;

  /// Creates a [GuestEntity] instance.
  const GuestEntity({
    required this.guestId,
    required this.name,
    required this.phone,
    this.email,
    required this.keperluan,
    this.instansi,
    this.photoUrl,
    required this.locationId,
    required this.checkInTime,
    this.checkOutTime,
    this.hostPhone,
    this.status = GuestStatus.checkedIn,
  });

  /// Creates a [GuestEntity] from a Firestore document snapshot.
  factory GuestEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return GuestEntity(
      guestId: doc.id,
      name: data[AppConstants.fieldName] as String,
      phone: data[AppConstants.fieldPhone] as String,
      email: data[AppConstants.fieldEmail] as String?,
      keperluan: KeperluanX.fromValue(
        data[AppConstants.fieldKeperluan] as String,
      ),
      instansi: data[AppConstants.fieldInstansi] as String?,
      photoUrl: data[AppConstants.fieldPhotoUrl] as String?,
      locationId: data[AppConstants.fieldLocationId] as String,
      checkInTime: (data[AppConstants.fieldCheckInTime] as Timestamp).toDate(),
      checkOutTime: data[AppConstants.fieldCheckOutTime] != null
          ? (data[AppConstants.fieldCheckOutTime] as Timestamp).toDate()
          : null,
      hostPhone: data[AppConstants.fieldHostPhone] as String?,
      status: GuestStatusX.fromValue(data[AppConstants.fieldStatus] as String),
    );
  }

  /// Serializes this entity to a Firestore-compatible map.
  ///
  /// Omits [guestId] since Firestore auto-generates document IDs.
  Map<String, dynamic> toFirestore() => {
    AppConstants.fieldName: name,
    AppConstants.fieldPhone: phone,
    AppConstants.fieldEmail: email,
    AppConstants.fieldKeperluan: keperluan.toValue(),
    AppConstants.fieldInstansi: instansi,
    AppConstants.fieldPhotoUrl: photoUrl,
    AppConstants.fieldLocationId: locationId,
    AppConstants.fieldCheckInTime: Timestamp.fromDate(checkInTime),
    AppConstants.fieldCheckOutTime: checkOutTime != null
        ? Timestamp.fromDate(checkOutTime!)
        : null,
    AppConstants.fieldHostPhone: hostPhone,
    AppConstants.fieldStatus: status.toValue(),
  };

  /// Serializes to a JSON-safe map including [guestId] for local storage.
  Map<String, dynamic> toMap() => {
    AppConstants.fieldGuestId: guestId,
    AppConstants.fieldName: name,
    AppConstants.fieldPhone: phone,
    AppConstants.fieldEmail: email,
    AppConstants.fieldKeperluan: keperluan.toValue(),
    AppConstants.fieldInstansi: instansi,
    AppConstants.fieldPhotoUrl: photoUrl,
    AppConstants.fieldLocationId: locationId,
    AppConstants.fieldCheckInTime: checkInTime.toIso8601String(),
    AppConstants.fieldCheckOutTime: checkOutTime?.toIso8601String(),
    AppConstants.fieldHostPhone: hostPhone,
    AppConstants.fieldStatus: status.toValue(),
  };

  /// Restores a [GuestEntity] from a JSON map (local storage).
  factory GuestEntity.fromMap(Map<String, dynamic> map) {
    return GuestEntity(
      guestId: map[AppConstants.fieldGuestId] as String,
      name: map[AppConstants.fieldName] as String,
      phone: map[AppConstants.fieldPhone] as String,
      email: map[AppConstants.fieldEmail] as String?,
      keperluan: KeperluanX.fromValue(
        map[AppConstants.fieldKeperluan] as String,
      ),
      instansi: map[AppConstants.fieldInstansi] as String?,
      photoUrl: map[AppConstants.fieldPhotoUrl] as String?,
      locationId: map[AppConstants.fieldLocationId] as String,
      checkInTime: DateTime.parse(map[AppConstants.fieldCheckInTime] as String),
      checkOutTime: map[AppConstants.fieldCheckOutTime] != null
          ? DateTime.parse(map[AppConstants.fieldCheckOutTime] as String)
          : null,
      hostPhone: map[AppConstants.fieldHostPhone] as String?,
      status: GuestStatusX.fromValue(map[AppConstants.fieldStatus] as String),
    );
  }

  /// Returns a copy of this entity with optional field overrides.
  GuestEntity copyWith({
    String? guestId,
    String? name,
    String? phone,
    String? email,
    Keperluan? keperluan,
    String? instansi,
    String? photoUrl,
    String? locationId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? hostPhone,
    GuestStatus? status,
  }) {
    return GuestEntity(
      guestId: guestId ?? this.guestId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      keperluan: keperluan ?? this.keperluan,
      instansi: instansi ?? this.instansi,
      photoUrl: photoUrl ?? this.photoUrl,
      locationId: locationId ?? this.locationId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      hostPhone: hostPhone ?? this.hostPhone,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    guestId,
    name,
    phone,
    email,
    keperluan,
    instansi,
    photoUrl,
    locationId,
    checkInTime,
    checkOutTime,
    hostPhone,
    status,
  ];
}
