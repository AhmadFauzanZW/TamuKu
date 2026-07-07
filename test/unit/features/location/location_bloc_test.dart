import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:tamuku/core/errors/failures.dart';
import 'package:tamuku/features/location/domain/entities/location_entity.dart';
import 'package:tamuku/features/location/domain/repositories/location_repository.dart';
import 'package:tamuku/features/location/presentation/bloc/location_bloc.dart';
import 'package:tamuku/features/location/presentation/bloc/location_event.dart';
import 'package:tamuku/features/location/presentation/bloc/location_state.dart';

// ─── Mocks ──────────────────────────────────────────────────────

class MockLocationRepository extends Mock implements LocationRepository {}

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
  late LocationBloc bloc;
  late MockLocationRepository mockRepo;

  setUp(() {
    mockRepo = MockLocationRepository();
    bloc = LocationBloc(repository: mockRepo);

    registerFallbackValue(_testLocation());
  });

  tearDown(() => bloc.close());

  group('LoadLocations', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationsLoaded] on success',
      build: () {
        when(
          () => mockRepo.getLocations(),
        ).thenAnswer((_) async => Right([_testLocation()]));
        return LocationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadLocations()),
      expect: () => [isA<LocationLoading>(), isA<LocationsLoaded>()],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationError] on failure',
      build: () {
        when(
          () => mockRepo.getLocations(),
        ).thenAnswer((_) async => const Left(ServerFailure()));
        return LocationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadLocations()),
      expect: () => [isA<LocationLoading>(), isA<LocationError>()],
    );
  });

  group('LoadLocation', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationLoaded] on success',
      build: () {
        when(
          () => mockRepo.getLocation('loc1'),
        ).thenAnswer((_) async => Right(_testLocation()));
        return LocationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadLocation('loc1')),
      expect: () => [isA<LocationLoading>(), isA<LocationLoaded>()],
    );
  });

  group('CreateLocation', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationOperationSuccess] on success',
      build: () {
        when(
          () => mockRepo.createLocation(any()),
        ).thenAnswer((_) async => const Right(null));
        return LocationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(
        const CreateLocation(
          name: 'New Location',
          address: 'Jl. Baru',
          adminId: 'admin1',
          hostPhone: '081234567890',
        ),
      ),
      expect: () => [isA<LocationLoading>(), isA<LocationOperationSuccess>()],
    );
  });

  group('UpdateLocation', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationOperationSuccess] on success',
      build: () {
        when(
          () => mockRepo.updateLocation(any()),
        ).thenAnswer((_) async => const Right(null));
        return LocationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(UpdateLocation(_testLocation())),
      expect: () => [isA<LocationLoading>(), isA<LocationOperationSuccess>()],
    );
  });

  group('DeleteLocation', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationOperationSuccess] on success',
      build: () {
        when(
          () => mockRepo.deleteLocation('loc1'),
        ).thenAnswer((_) async => const Right(null));
        return LocationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const DeleteLocation('loc1')),
      expect: () => [isA<LocationLoading>(), isA<LocationOperationSuccess>()],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationError] on failure',
      build: () {
        when(
          () => mockRepo.deleteLocation('loc1'),
        ).thenAnswer((_) async => const Left(ServerFailure('Gagal hapus')));
        return LocationBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const DeleteLocation('loc1')),
      expect: () => [isA<LocationLoading>(), isA<LocationError>()],
    );
  });
}
