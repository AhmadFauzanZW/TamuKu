import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

/// BLoC that manages location CRUD and real-time state.
///
/// Handles loading, streaming, creating, updating, and deleting locations.
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repository;
  StreamSubscription<List<LocationEntity>>? _locationsSubscription;

  /// Creates a [LocationBloc] with the given [repository].
  LocationBloc({required LocationRepository repository})
    : _repository = repository,
      super(LocationInitial()) {
    on<LoadLocation>(_onLoadLocation);
    on<LoadLocations>(_onLoadLocations);
    on<CreateLocation>(_onCreateLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<DeleteLocation>(_onDeleteLocation);
    on<WatchLocationsStarted>(_onWatchLocationsStarted);
    on<LocationsUpdatedInternal>(_onLocationsUpdated);
    on<LocationFilterChanged>(_onFilterChanged);
  }

  /// Loads a single location by [locationId].
  Future<void> _onLoadLocation(
    LoadLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _repository.getLocation(event.locationId);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (location) => emit(LocationLoaded(location)),
    );
  }

  /// Loads all locations from the repository.
  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _repository.getLocations();
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (locations) => emit(LocationsLoaded(locations)),
    );
  }

  /// Creates a new location.
  Future<void> _onCreateLocation(
    CreateLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final location = LocationEntity(
      locationId: '',
      name: event.name,
      address: event.address,
      adminId: event.adminId,
      hostPhone: event.hostPhone,
      qrCodeValue: '',
      createdAt: DateTime.now(),
    );
    final result = await _repository.createLocation(location);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (_) => emit(const LocationOperationSuccess('Lokasi berhasil dibuat')),
    );
  }

  /// Updates an existing location.
  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _repository.updateLocation(event.location);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (_) => emit(const LocationOperationSuccess('Lokasi berhasil diperbarui')),
    );
  }

  /// Deletes a location by [locationId].
  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _repository.deleteLocation(event.locationId);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (_) => emit(const LocationOperationSuccess('Lokasi berhasil dihapus')),
    );
  }

  /// Subscribes to real-time location updates via [StreamSubscription].
  void _onWatchLocationsStarted(
    WatchLocationsStarted event,
    Emitter<LocationState> emit,
  ) {
    _locationsSubscription?.cancel();
    _locationsSubscription = _repository.watchLocations().listen((locations) {
      add(LocationsUpdatedInternal(locations));
    });
  }

  /// Handles real-time location list updates from the stream.
  Future<void> _onLocationsUpdated(
    LocationsUpdatedInternal event,
    Emitter<LocationState> emit,
  ) async {
    final current = state;
    final filter = current is LocationsLoaded
        ? current.selectedFilter
        : 'Semua';
    emit(LocationsLoaded(event.locations, selectedFilter: filter));
  }

  /// Updates the active guest list filter.
  void _onFilterChanged(
    LocationFilterChanged event,
    Emitter<LocationState> emit,
  ) {
    final current = state;
    if (current is LocationsLoaded) {
      emit(LocationsLoaded(current.locations, selectedFilter: event.filter));
    }
  }

  @override
  Future<void> close() {
    _locationsSubscription?.cancel();
    return super.close();
  }
}
