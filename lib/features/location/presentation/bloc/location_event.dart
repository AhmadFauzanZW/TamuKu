import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object> get props => [];
}

class LoadLocation extends LocationEvent {
  final String locationId;
  const LoadLocation(this.locationId);
  @override
  List<Object> get props => [locationId];
}

class LoadLocationsByAdmin extends LocationEvent {
  final String adminId;
  const LoadLocationsByAdmin(this.adminId);
  @override
  List<Object> get props => [adminId];
}

class CreateLocationRequested extends LocationEvent {
  final String name;
  final String address;
  final String hostPhone;
  const CreateLocationRequested({required this.name, required this.address, required this.hostPhone});
  @override
  List<Object> get props => [name, address, hostPhone];
}

class UpdateLocationRequested extends LocationEvent {
  final String locationId;
  final String name;
  final String address;
  final String hostPhone;
  const UpdateLocationRequested({required this.locationId, required this.name, required this.address, required this.hostPhone});
  @override
  List<Object> get props => [locationId, name, address, hostPhone];
}
