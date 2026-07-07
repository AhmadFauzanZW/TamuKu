import 'package:equatable/equatable.dart';

import '../../domain/entities/location_entity.dart';

/// Abstract base class for all location-related events.
///
/// Each event triggers a state transition in [LocationBloc].
abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object> get props => [];
}

/// Loads a single location by [locationId].
class LoadLocation extends LocationEvent {
  /// The ID of the location to load.
  final String locationId;

  const LoadLocation(this.locationId);
  @override
  List<Object> get props => [locationId];
}

/// Loads all locations from the repository.
class LoadLocations extends LocationEvent {
  const LoadLocations();
  @override
  List<Object> get props => [];
}

/// Creates a new location with the provided details.
class CreateLocation extends LocationEvent {
  /// Location name.
  final String name;

  /// Physical address.
  final String address;

  /// Admin ID who owns this location.
  final String adminId;

  /// Host WhatsApp phone number.
  final String hostPhone;

  const CreateLocation({
    required this.name,
    required this.address,
    required this.adminId,
    required this.hostPhone,
  });
  @override
  List<Object> get props => [name, address, adminId, hostPhone];
}

/// Updates an existing location with the provided details.
class UpdateLocation extends LocationEvent {
  /// The full updated location entity.
  final LocationEntity location;

  const UpdateLocation(this.location);
  @override
  List<Object> get props => [location];
}

/// Deletes a location by [locationId].
class DeleteLocation extends LocationEvent {
  /// The ID of the location to delete.
  final String locationId;

  const DeleteLocation(this.locationId);
  @override
  List<Object> get props => [locationId];
}

/// Subscribes to real-time location list updates.
class WatchLocationsStarted extends LocationEvent {
  const WatchLocationsStarted();
  @override
  List<Object> get props => [];
}

/// Changes the active guest list filter.
///
/// [filter] must be one of [AppConstants.filterAll],
/// [AppConstants.filterCheckedIn], or [AppConstants.filterCompleted].
class LocationFilterChanged extends LocationEvent {
  /// The selected filter name.
  final String filter;

  const LocationFilterChanged(this.filter);
  @override
  List<Object> get props => [filter];
}

/// Internal event dispatched when the stream emits updated locations.
///
/// Prefixed with [LocationsUpdatedInternal] to avoid collision with state name
/// while remaining public for cross-file access from [LocationBloc].
class LocationsUpdatedInternal extends LocationEvent {
  /// The updated locations list from the stream.
  final List<LocationEntity> locations;

  /// Creates a [LocationsUpdatedInternal].
  const LocationsUpdatedInternal(this.locations);
  @override
  List<Object> get props => [locations];
}
