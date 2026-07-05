import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/entities/location_entity.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;

  LocationBloc({required LocationRepository locationRepository})
      : _locationRepository = locationRepository,
        super(LocationInitial()) {
    on<LoadLocation>(_onLoadLocation);
    on<LoadLocationsByAdmin>(_onLoadLocationsByAdmin);
    on<CreateLocationRequested>(_onCreateLocation);
    on<UpdateLocationRequested>(_onUpdateLocation);
  }

  Future<void> _onLoadLocation(LoadLocation event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final location = await _locationRepository.getLocationById(event.locationId);
      emit(LocationLoaded(location));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onLoadLocationsByAdmin(LoadLocationsByAdmin event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final locations = await _locationRepository.getLocationsByAdmin(event.adminId);
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onCreateLocation(CreateLocationRequested event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final location = LocationEntity(
        locationId: '', name: event.name, address: event.address,
        adminId: '', hostPhone: event.hostPhone, qrCodeValue: '',
        createdAt: DateTime.now(),
      );
      await _locationRepository.createLocation(location);
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onUpdateLocation(UpdateLocationRequested event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final location = LocationEntity(
        locationId: event.locationId, name: event.name, address: event.address,
        adminId: '', hostPhone: event.hostPhone, qrCodeValue: '',
        createdAt: DateTime.now(),
      );
      await _locationRepository.updateLocation(location);
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
