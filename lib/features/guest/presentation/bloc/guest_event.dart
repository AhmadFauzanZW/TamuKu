import 'package:equatable/equatable.dart';

abstract class GuestEvent extends Equatable {
  const GuestEvent();
  @override
  List<Object> get props => [];
}

class LoadGuests extends GuestEvent {
  final String locationId;
  const LoadGuests(this.locationId);
  @override
  List<Object> get props => [locationId];
}

class CheckInRequested extends GuestEvent {
  final String name;
  final String phone;
  final String keperluan;
  final String? email;
  final String? instansi;
  final String locationId;

  const CheckInRequested({
    required this.name,
    required this.phone,
    required this.keperluan,
    this.email,
    this.instansi,
    required this.locationId,
  });

  @override
  List<Object> get props => [name, phone, keperluan, locationId];
}

class CheckOutRequested extends GuestEvent {
  final String guestId;
  const CheckOutRequested(this.guestId);
  @override
  List<Object> get props => [guestId];
}

class SearchGuests extends GuestEvent {
  final String query;
  const SearchGuests(this.query);
  @override
  List<Object> get props => [query];
}
