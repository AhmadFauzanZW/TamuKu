import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:tamuku/core/errors/failures.dart';
import 'package:tamuku/core/network/network_info.dart';
import 'package:tamuku/features/location/data/datasources/location_local_datasource.dart';
import 'package:tamuku/features/location/data/datasources/location_remote_datasource.dart';
import 'package:tamuku/features/location/data/repositories/location_repository_impl.dart';
import 'package:tamuku/features/location/domain/entities/location_entity.dart';

// ─── Mocks ──────────────────────────────────────────────────────

class MockRemoteDataSource extends Mock implements LocationRemoteDataSource {}

class MockLocalDataSource extends Mock implements LocationLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// ─── Fixtures ───────────────────────────────────────────────────

LocationEntity _testLocation({String id = 'loc1'}) => LocationEntity(
  locationId: id,
  name: 'Kantor Cakrawala',
  address: 'Jl. Merdeka No. 10',
  adminId: 'admin1',
  hostPhone: '081234567890',
  qrCodeValue: 'qr_$id',
  createdAt: DateTime(2025, 1, 1),
  isActive: true,
);

void main() {
  late LocationRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = LocationRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
      networkInfo: mockNetworkInfo,
    );

    registerFallbackValue(_testLocation());
  });

  group('getLocation', () {
    test('returns LocationEntity on remote success (online)', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getLocationById('loc1'),
      ).thenAnswer((_) async => _testLocation());
      when(() => mockLocal.cacheLocation(any())).thenAnswer((_) async {});

      final result = await repository.getLocation('loc1');

      expect(result, isA<Right<Failure, LocationEntity>>());
      result.fold((l) => fail('Should not be Left'), (r) {
        expect(r.locationId, 'loc1');
      });
    });

    test('returns CacheFailure when offline and no cache', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocal.getCachedLocation('loc1'),
      ).thenAnswer((_) async => null);

      final result = await repository.getLocation('loc1');

      expect(result, isA<Left<Failure, LocationEntity>>());
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('Should not be Right'),
      );
    });

    test('returns cached location when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocal.getCachedLocation('loc1'),
      ).thenAnswer((_) async => _testLocation());

      final result = await repository.getLocation('loc1');

      expect(result, isA<Right<Failure, LocationEntity>>());
    });
  });

  group('getLocations', () {
    test('returns list from remote when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.watchLocations(),
      ).thenAnswer((_) => Stream.value([_testLocation()]));
      when(() => mockLocal.cacheLocations(any())).thenAnswer((_) async {});

      final result = await repository.getLocations();

      expect(result, isA<Right<Failure, List<LocationEntity>>>());
      result.fold((l) => fail('Should not be Left'), (r) {
        expect(r, hasLength(1));
      });
    });

    test('returns ServerFailure on remote error when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.watchLocations(),
      ).thenAnswer((_) => Stream.error(Exception('fail')));
      when(() => mockLocal.getCachedLocations()).thenAnswer((_) async => []);

      final result = await repository.getLocations();

      expect(result, isA<Left<Failure, List<LocationEntity>>>());
    });
  });

  group('createLocation', () {
    test('caches locally and writes to remote when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocal.cacheLocation(any())).thenAnswer((_) async {});
      when(() => mockRemote.createLocation(any())).thenAnswer((_) async {});

      final result = await repository.createLocation(_testLocation());

      expect(result, isA<Right<Failure, void>>());
      verify(() => mockLocal.cacheLocation(any())).called(1);
      verify(() => mockRemote.createLocation(any())).called(1);
    });

    test('caches locally only when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.cacheLocation(any())).thenAnswer((_) async {});

      final result = await repository.createLocation(_testLocation());

      expect(result, isA<Right<Failure, void>>());
      verifyNever(() => mockRemote.createLocation(any()));
    });
  });

  group('deleteLocation', () {
    test('removes from local and remote when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockLocal.removeCachedLocation('loc1'),
      ).thenAnswer((_) async {});
      when(() => mockRemote.deleteLocation('loc1')).thenAnswer((_) async {});

      final result = await repository.deleteLocation('loc1');

      expect(result, isA<Right<Failure, void>>());
      verify(() => mockLocal.removeCachedLocation('loc1')).called(1);
      verify(() => mockRemote.deleteLocation('loc1')).called(1);
    });
  });

  group('watchLocations', () {
    test('delegates to remote stream', () async {
      final stream = Stream.value([_testLocation()]);
      when(() => mockRemote.watchLocations()).thenAnswer((_) => stream);

      expect(repository.watchLocations(), stream);
    });
  });
}
