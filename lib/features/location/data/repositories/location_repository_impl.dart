import '../../domain/repositories/location_repository.dart';
import '../../domain/entities/location_entity.dart';
import '../datasources/location_remote_datasource.dart';
import '../datasources/location_local_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<LocationEntity> getLocationById(String locationId) => throw UnimplementedError();
  @override
  Future<List<LocationEntity>> getLocationsByAdmin(String adminId) => throw UnimplementedError();
  @override
  Future<void> createLocation(LocationEntity location) => throw UnimplementedError();
  @override
  Future<void> updateLocation(LocationEntity location) => throw UnimplementedError();
}
