import 'package:equatable/equatable.dart';

import '../../domain/entities/location_entity.dart';

/// Abstract base class for all location-related states.
abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object> get props => [];
}

/// Initial state before any operation.
class LocationInitial extends LocationState {}

/// Loading state while fetching or processing data.
class LocationLoading extends LocationState {}

/// Successfully loaded a single location.
class LocationLoaded extends LocationState {
  /// The loaded location.
  final LocationEntity location;

  const LocationLoaded(this.location);
  @override
  List<Object> get props => [location];
}

/// Successfully loaded the list of locations.
class LocationsLoaded extends LocationState {
  /// The list of locations.
  final List<LocationEntity> locations;

  /// Active guest list filter (default: 'Semua').
  final String selectedFilter;

  const LocationsLoaded(this.locations, {this.selectedFilter = 'Semua'});
  @override
  List<Object> get props => [locations, selectedFilter];
}

/// A location operation (create, update, delete) completed successfully.
class LocationOperationSuccess extends LocationState {
  /// Descriptive message about the operation result.
  final String message;

  const LocationOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

/// An error occurred during a location operation.
class LocationError extends LocationState {
  /// Human-readable error message.
  final String message;

  const LocationError(this.message);
  @override
  List<Object> get props => [message];
}
