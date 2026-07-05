import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<LocationEntity> getLocationById(String locationId);
  Future<List<LocationEntity>> getLocationsByAdmin(String adminId);
  Future<void> createLocation(LocationEntity location);
  Future<void> updateLocation(LocationEntity location);
}
