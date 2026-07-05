import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String locationId;
  final String name;
  final String address;
  final String adminId;
  final String hostPhone;
  final String qrCodeValue;
  final DateTime createdAt;
  final bool isActive;

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

  @override
  List<Object> get props => [
        locationId, name, address, adminId,
        hostPhone, qrCodeValue, createdAt, isActive,
      ];
}
