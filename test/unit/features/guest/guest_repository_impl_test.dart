import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamuku/core/errors/failures.dart';
import 'package:tamuku/core/network/network_info.dart';
import 'package:tamuku/features/guest/data/datasources/guest_local_datasource.dart';
import 'package:tamuku/features/guest/data/datasources/guest_remote_datasource.dart';
import 'package:tamuku/features/guest/data/repositories/guest_repository_impl.dart';
import 'package:tamuku/features/guest/domain/entities/guest_entity.dart';
import 'package:test/test.dart';

// ─── Mocks ────────────────────────────────────────────────────────

class MockRemoteDataSource extends Mock implements GuestRemoteDataSource {}

class MockLocalDataSource extends Mock implements GuestLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class FakeGuest extends Fake implements GuestEntity {}

class FakeDateTime extends Fake implements DateTime {
  FakeDateTime(this._dt);
  final DateTime _dt;
  @override
  bool operator ==(Object other) => other is DateTime && _dt == other;
  @override
  int get hashCode => _dt.hashCode;
}

// ─── Fixtures ─────────────────────────────────────────────────────

final tNow = DateTime(2026, 7, 6, 10, 0);

final tGuest = GuestEntity(
  guestId: 'g1',
  name: 'Budi Santoso',
  phone: '081298765432',
  email: 'budi@example.com',
  keperluan: Keperluan.meeting,
  instansi: 'PT Maju Jaya',
  locationId: 'loc1',
  checkInTime: tNow,
);

final tGuestList = [tGuest];

const tLocationId = 'loc1';
const tGuestId = 'g1';
final tCheckOutTime = DateTime(2026, 7, 6, 12, 0);

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late GuestRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeGuest());
    registerFallbackValue(FakeDateTime(tCheckOutTime));
  });

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = GuestRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
    );
  });

  // ─── getGuests ────────────────────────────────────────────────

  group('getGuests', () {
    test(
      'online → fetches remote, caches locally, returns Right',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.getGuests(tLocationId))
            .thenAnswer((_) async => tGuestList);
        when(() => local.cacheGuests(tGuestList, tLocationId))
            .thenAnswer((_) async {});

        final result = await repository.getGuests(tLocationId);

        expect(result, Right(tGuestList));
        verify(() => remote.getGuests(tLocationId)).called(1);
        verify(() => local.cacheGuests(tGuestList, tLocationId)).called(1);
      },
    );

    test(
      'online, remote throws → returns cached data when available',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.getGuests(tLocationId)).thenThrow(Exception('fail'));
        when(() => local.getCachedGuests(tLocationId))
            .thenAnswer((_) async => tGuestList);

        final result = await repository.getGuests(tLocationId);

        expect(result, Right(tGuestList));
        verify(() => local.getCachedGuests(tLocationId)).called(1);
      },
    );

    test(
      'online, remote throws, no cache → returns ServerFailure',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.getGuests(tLocationId)).thenThrow(Exception('fail'));
        when(() => local.getCachedGuests(tLocationId))
            .thenAnswer((_) async => []);

        final result = await repository.getGuests(tLocationId);

        expect(result, const Left(ServerFailure()));
      },
    );

    test(
      'offline, cache available → returns cached data',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(() => local.getCachedGuests(tLocationId))
            .thenAnswer((_) async => tGuestList);

        final result = await repository.getGuests(tLocationId);

        expect(result, Right(tGuestList));
        verifyNever(() => remote.getGuests(any()));
      },
    );

    test(
      'offline, no cache → returns CacheFailure',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(() => local.getCachedGuests(tLocationId))
            .thenAnswer((_) async => []);

        final result = await repository.getGuests(tLocationId);

        expect(result, const Left(CacheFailure()));
      },
    );
  });

  // ─── checkIn ──────────────────────────────────────────────────

  group('checkIn', () {
    test(
      'online → writes local first, then remote',
      () async {
        when(() => local.cacheGuest(tGuest)).thenAnswer((_) async {});
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.checkIn(tGuest)).thenAnswer((_) async {});

        final result = await repository.checkIn(tGuest);

        expect(result, const Right(null));
        verifyInOrder([
          () => local.cacheGuest(tGuest),
          () => networkInfo.isConnected,
          () => remote.checkIn(tGuest),
        ]);
      },
    );

    test(
      'online, remote throws → still returns Right (local succeeded)',
      () async {
        when(() => local.cacheGuest(tGuest)).thenAnswer((_) async {});
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.checkIn(tGuest)).thenThrow(Exception('fail'));

        final result = await repository.checkIn(tGuest);

        expect(result, const Right(null));
      },
    );

    test(
      'offline → writes local only, returns Right',
      () async {
        when(() => local.cacheGuest(tGuest)).thenAnswer((_) async {});
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.checkIn(tGuest);

        expect(result, const Right(null));
        verifyNever(() => remote.checkIn(any()));
      },
    );
  });

  // ─── checkOut ─────────────────────────────────────────────────

  group('checkOut', () {
    test(
      'online → updates remote, caches updated guest, returns Right',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.checkOut(tGuestId, tCheckOutTime))
            .thenAnswer((_) async {});
        when(() => remote.getGuest(tGuestId))
            .thenAnswer((_) async => tGuest.copyWith(
                  status: GuestStatus.checkedOut,
                  checkOutTime: tCheckOutTime,
                ));
        when(() => local.cacheGuest(any())).thenAnswer((_) async {});

        final result = await repository.checkOut(tGuestId, tCheckOutTime);

        expect(result, const Right(null));
        verify(() => remote.checkOut(tGuestId, tCheckOutTime)).called(1);
        verify(() => local.cacheGuest(any())).called(1);
      },
    );

    test(
      'online, remote throws → returns Right (queued for sync)',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.checkOut(tGuestId, tCheckOutTime))
            .thenThrow(Exception('fail'));

        final result = await repository.checkOut(tGuestId, tCheckOutTime);

        // Offline-first: operation queued for later retry, still succeeds locally
        expect(result, const Right(null));
      },
    );

    test(
      'offline → returns Right (queued for sync)',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.checkOut(tGuestId, tCheckOutTime);

        // Offline-first: operation queued for later retry
        expect(result, const Right(null));
        verifyNever(() => remote.checkOut(any(), any()));
      },
    );
  });

  // ─── updateGuest ──────────────────────────────────────────────

  group('updateGuest', () {
    test(
      'online → writes local, syncs remote, returns Right',
      () async {
        when(() => local.cacheGuest(tGuest)).thenAnswer((_) async {});
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.updateGuest(tGuest)).thenAnswer((_) async {});

        final result = await repository.updateGuest(tGuest);

        expect(result, const Right(null));
      },
    );

    test(
      'offline → writes local only, returns Right',
      () async {
        when(() => local.cacheGuest(tGuest)).thenAnswer((_) async {});
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.updateGuest(tGuest);

        expect(result, const Right(null));
        verifyNever(() => remote.updateGuest(any()));
      },
    );
  });

  // ─── deleteGuest ──────────────────────────────────────────────

  group('deleteGuest', () {
    test(
      'online → removes local, deletes remote, returns Right',
      () async {
        when(() => local.removeCachedGuest(tGuestId))
            .thenAnswer((_) async {});
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remote.deleteGuest(tGuestId)).thenAnswer((_) async {});

        final result = await repository.deleteGuest(tGuestId);

        expect(result, const Right(null));
      },
    );

    test(
      'offline → removes local only, returns Right',
      () async {
        when(() => local.removeCachedGuest(tGuestId))
            .thenAnswer((_) async {});
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.deleteGuest(tGuestId);

        expect(result, const Right(null));
        verifyNever(() => remote.deleteGuest(any()));
      },
    );
  });

  // ─── watchGuests ──────────────────────────────────────────────

  group('watchGuests', () {
    test('passes through remote stream', () {
      when(() => remote.watchGuests(tLocationId))
          .thenAnswer((_) => Stream.value(tGuestList));

      expectLater(
        repository.watchGuests(tLocationId),
        emitsInOrder([tGuestList]),
      );
    });
  });
}
