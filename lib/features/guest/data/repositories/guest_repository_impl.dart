import '../../domain/repositories/guest_repository.dart';
import '../../domain/entities/guest_entity.dart';
import '../datasources/guest_remote_datasource.dart';
import '../datasources/guest_local_datasource.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteDataSource remoteDataSource;
  final GuestLocalDataSource localDataSource;

  GuestRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<GuestEntity>> getGuests(String locationId) => throw UnimplementedError();
  @override
  Future<GuestEntity> getGuestById(String guestId) => throw UnimplementedError();
  @override
  Future<void> checkIn(GuestEntity guest) => throw UnimplementedError();
  @override
  Future<void> checkOut(String guestId) => throw UnimplementedError();
  @override
  Stream<List<GuestEntity>> watchGuests(String locationId) => const Stream.empty();
}
