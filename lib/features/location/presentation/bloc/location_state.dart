import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}
class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final LocationEntity location;
  const LocationLoaded(this.location);
  @override
  List<Object> get props => [location];
}

class LocationsLoaded extends LocationState {
  final List<LocationEntity> locations;
  const LocationsLoaded(this.locations);
  @override
  List<Object> get props => [locations];
}

class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);
  @override
  List<Object> get props => [message];
}
