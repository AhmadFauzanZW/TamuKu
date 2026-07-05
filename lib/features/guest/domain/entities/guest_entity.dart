import 'package:equatable/equatable.dart';

class GuestEntity extends Equatable {
  final String guestId;
  final String name;
  final String phone;
  final String? email;
  final String keperluan;
  final String? instansi;
  final String? photoUrl;
  final String locationId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? hostPhone;
  final String status;

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
    this.status = 'checked_in',
  });

  @override
  List<Object?> get props => [
        guestId, name, phone, email, keperluan,
        instansi, photoUrl, locationId, checkInTime,
        checkOutTime, hostPhone, status,
      ];
}
