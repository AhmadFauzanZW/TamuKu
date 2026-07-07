import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamuku/core/errors/failures.dart';
import 'package:tamuku/features/guest/domain/entities/guest_entity.dart';
import 'package:tamuku/features/guest/domain/repositories/guest_repository.dart';
import 'package:tamuku/features/guest/presentation/bloc/guest_bloc.dart';
import 'package:tamuku/features/guest/presentation/bloc/guest_event.dart';
import 'package:tamuku/features/guest/presentation/bloc/guest_state.dart';
import 'package:tamuku/features/notification/domain/repositories/notification_repository.dart';

// ─── Mocks ────────────────────────────────────────────────────────

class MockGuestRepository extends Mock implements GuestRepository {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

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

final tGuest2 = GuestEntity(
  guestId: 'g2',
  name: 'Andi Wijaya',
  phone: '081234567890',
  keperluan: Keperluan.personal,
  locationId: 'loc1',
  checkInTime: tNow,
);

final tGuestList = [tGuest, tGuest2];

// ─── Filter / Sort Fixtures ──────────────────────────────────────

final tCheckedInGuest1 = GuestEntity(
  guestId: 'g1',
  name: 'Budi Santoso',
  phone: '081298765432',
  email: 'budi@example.com',
  keperluan: Keperluan.meeting,
  instansi: 'PT Maju Jaya',
  locationId: 'loc1',
  checkInTime: DateTime(2026, 7, 6, 10, 0),
  status: GuestStatus.checkedIn,
);

final tCheckedInGuest2 = GuestEntity(
  guestId: 'g2',
  name: 'Citra Dewi',
  phone: '081234567890',
  keperluan: Keperluan.personal,
  locationId: 'loc1',
  checkInTime: DateTime(2026, 7, 6, 14, 0),
  status: GuestStatus.checkedIn,
);

final tCheckedOutGuest = GuestEntity(
  guestId: 'g3',
  name: 'Andi Wijaya',
  phone: '081211111111',
  keperluan: Keperluan.kantor,
  locationId: 'loc1',
  checkInTime: DateTime(2026, 7, 5, 9, 0),
  checkOutTime: DateTime(2026, 7, 5, 11, 0),
  status: GuestStatus.checkedOut,
);

final tMixedGuestList = [tCheckedInGuest1, tCheckedOutGuest, tCheckedInGuest2];

const tLocationId = 'loc1';
const tGuestId = 'g1';

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  late MockGuestRepository repository;
  late MockNotificationRepository notificationRepository;
  late GuestBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeGuest());
    registerFallbackValue(FakeDateTime(tNow));
  });

  setUp(() {
    repository = MockGuestRepository();
    notificationRepository = MockNotificationRepository();
    bloc = GuestBloc(
      repository: repository,
      notificationRepository: notificationRepository,
    );
  });

  tearDown(() => bloc.close());

  // ─── Initial state ────────────────────────────────────────────

  test('initial state is GuestInitial', () {
    expect(bloc.state, isA<GuestInitial>());
  });

  // ─── LoadGuests ───────────────────────────────────────────────

  group('LoadGuests', () {
    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestLoaded] on success',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LoadGuests(tLocationId)),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'guests',
          tGuestList,
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestError] on failure',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return GuestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LoadGuests(tLocationId)),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestError>().having(
          (s) => s.message,
          'message',
          'Gagal terhubung ke server',
        ),
      ],
    );
  });

  // ─── CheckInRequested ─────────────────────────────────────────

  group('CheckInRequested', () {
    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestOperationSuccess] on success',
      build: () {
        when(() => repository.checkIn(any()))
            .thenAnswer((_) async => const Right(null));
        return GuestBloc(
          repository: repository,
          notificationRepository: notificationRepository,
        );
      },
      act: (bloc) => bloc.add(CheckInRequested(
        name: tGuest.name,
        phone: tGuest.phone,
        email: tGuest.email,
        keperluan: tGuest.keperluan,
        instansi: tGuest.instansi,
        locationId: tGuest.locationId,
      )),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestOperationSuccess>().having(
          (s) => s.message,
          'message',
          'Check-in berhasil',
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestError] on failure',
      build: () {
        when(() => repository.checkIn(any()))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return GuestBloc(
          repository: repository,
          notificationRepository: notificationRepository,
        );
      },
      act: (bloc) => bloc.add(CheckInRequested(
        name: tGuest.name,
        phone: tGuest.phone,
        keperluan: tGuest.keperluan,
        locationId: tGuest.locationId,
      )),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestError>(),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'sends Telegram notification after successful check-in when hostPhone provided',
      build: () {
        when(() => repository.checkIn(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => notificationRepository.sendTelegramMessage(
              phoneNumber: any(named: 'phoneNumber'),
              guestName: any(named: 'guestName'),
              locationName: any(named: 'locationName'),
              checkInTime: any(named: 'checkInTime'),
            )).thenAnswer((_) async {});
        return GuestBloc(
          repository: repository,
          notificationRepository: notificationRepository,
        );
      },
      act: (bloc) => bloc.add(CheckInRequested(
        name: tGuest.name,
        phone: tGuest.phone,
        keperluan: tGuest.keperluan,
        locationId: tGuest.locationId,
        hostPhone: '081234567890',
      )),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestOperationSuccess>(),
      ],
      verify: (_) {
        verify(() => notificationRepository.sendTelegramMessage(
              phoneNumber: any(named: 'phoneNumber'),
              guestName: any(named: 'guestName'),
              locationName: any(named: 'locationName'),
              checkInTime: any(named: 'checkInTime'),
            )).called(1);
      },
    );

    blocTest<GuestBloc, GuestState>(
      'does NOT send notification when hostPhone is null',
      build: () {
        when(() => repository.checkIn(any()))
            .thenAnswer((_) async => const Right(null));
        return GuestBloc(
          repository: repository,
          notificationRepository: notificationRepository,
        );
      },
      act: (bloc) => bloc.add(CheckInRequested(
        name: tGuest.name,
        phone: tGuest.phone,
        keperluan: tGuest.keperluan,
        locationId: tGuest.locationId,
      )),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestOperationSuccess>(),
      ],
      verify: (_) {
        verifyNever(() => notificationRepository.sendTelegramMessage(
              phoneNumber: any(named: 'phoneNumber'),
              guestName: any(named: 'guestName'),
              locationName: any(named: 'locationName'),
              checkInTime: any(named: 'checkInTime'),
            ));
      },
    );
  });

  // ─── CheckOutRequested ────────────────────────────────────────

  group('CheckOutRequested', () {
    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestOperationSuccess] on success',
      build: () {
        when(() => repository.checkOut(any(), any()))
            .thenAnswer((_) async => const Right(null));
        return GuestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const CheckOutRequested(tGuestId)),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestOperationSuccess>().having(
          (s) => s.message,
          'message',
          'Check-out berhasil',
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestError] on failure',
      build: () {
        when(() => repository.checkOut(any(), any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return GuestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const CheckOutRequested(tGuestId)),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestError>().having(
          (s) => s.message,
          'message',
          'Tidak ada koneksi internet',
        ),
      ],
    );
  });

  // ─── DeleteGuest ──────────────────────────────────────────────

  group('DeleteGuest', () {
    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestOperationSuccess] on success',
      build: () {
        when(() => repository.deleteGuest(tGuestId))
            .thenAnswer((_) async => const Right(null));
        return GuestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const DeleteGuest(tGuestId)),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestOperationSuccess>().having(
          (s) => s.message,
          'message',
          'Tamu berhasil dihapus',
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'emits [GuestLoading, GuestError] on failure',
      build: () {
        when(() => repository.deleteGuest(tGuestId))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return GuestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const DeleteGuest(tGuestId)),
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestError>(),
      ],
    );
  });

  // ─── SearchGuests ─────────────────────────────────────────────

  group('SearchGuests', () {
    blocTest<GuestBloc, GuestState>(
      'loads guests then filters by name query',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        // Wait for LoadGuests to complete
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const SearchGuests('Budi'));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>().having(
          (s) => s.guests.length,
          'guests count',
          2,
        ),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'filtered guests',
          [tGuest],
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'empty query restores all guests',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        // Search for non-matching then clear
        bloc.add(const SearchGuests('xyz'));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const SearchGuests(''));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>(),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'empty filtered',
          <GuestEntity>[],
        ),
        isA<GuestLoaded>().having(
          (s) => s.guests.length,
          'restored all',
          2,
        ),
      ],
    );
  });

  // ─── FilterGuests ─────────────────────────────────────────────

  group('FilterGuests', () {
    blocTest<GuestBloc, GuestState>(
      'emits GuestLoaded with only checked-in guests when filter is Check-In',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tMixedGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const FilterGuests('Check-In'));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>(),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'checked-in only',
          [tCheckedInGuest2, tCheckedInGuest1],
        ).having(
          (s) => s.activeFilter,
          'activeFilter',
          'Check-In',
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'emits GuestLoaded with only checked-out guests when filter is Selesai',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tMixedGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const FilterGuests('Selesai'));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>(),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'checked-out only',
          [tCheckedOutGuest],
        ).having(
          (s) => s.activeFilter,
          'activeFilter',
          'Selesai',
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'emits GuestLoaded with all guests when filter is Semua',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tMixedGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        // First apply a filter, then reset to Semua
        bloc.add(const FilterGuests('Check-In'));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const FilterGuests('Semua'));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>(),
        isA<GuestLoaded>().having(
          (s) => s.guests.length,
          'filtered count',
          2,
        ),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'all guests restored',
          [tCheckedInGuest2, tCheckedInGuest1, tCheckedOutGuest],
        ).having(
          (s) => s.activeFilter,
          'activeFilter',
          'Semua',
        ),
      ],
    );
  });

  // ─── SortGuests ───────────────────────────────────────────────

  group('SortGuests', () {
    blocTest<GuestBloc, GuestState>(
      'sorts guests by date descending (newest first)',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tMixedGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) {
        bloc.add(const LoadGuests(tLocationId));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'sorted by date desc',
          [tCheckedInGuest2, tCheckedInGuest1, tCheckedOutGuest],
        ).having(
          (s) => s.sortType,
          'sortType',
          SortType.byDateDesc,
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'sorts guests by date ascending (oldest first)',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tMixedGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const SortGuests(SortType.byDateAsc));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>(),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'sorted by date asc',
          [tCheckedOutGuest, tCheckedInGuest1, tCheckedInGuest2],
        ).having(
          (s) => s.sortType,
          'sortType',
          SortType.byDateAsc,
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'sorts guests by name alphabetically (A-Z)',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tMixedGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const SortGuests(SortType.byNameAsc));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>(),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'sorted by name A-Z',
          [tCheckedOutGuest, tCheckedInGuest1, tCheckedInGuest2],
        ).having(
          (s) => s.sortType,
          'sortType',
          SortType.byNameAsc,
        ),
      ],
    );
  });

  // ─── Filter + Sort combined ───────────────────────────────────

  group('Filter and Sort combined', () {
    blocTest<GuestBloc, GuestState>(
      'applies both filter and sort together',
      build: () {
        when(() => repository.getGuests(tLocationId))
            .thenAnswer((_) async => Right(tMixedGuestList));
        return GuestBloc(repository: repository);
      },
      act: (bloc) async {
        bloc.add(const LoadGuests(tLocationId));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const FilterGuests('Check-In'));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<GuestLoaded>()),
        );
        bloc.add(const SortGuests(SortType.byDateAsc));
      },
      expect: () => [
        isA<GuestLoading>(),
        isA<GuestLoaded>(),
        isA<GuestLoaded>().having(
          (s) => s.guests.length,
          'filtered count',
          2,
        ),
        isA<GuestLoaded>().having(
          (s) => s.guests,
          'checked-in sorted asc',
          [tCheckedInGuest1, tCheckedInGuest2],
        ).having(
          (s) => s.activeFilter,
          'activeFilter',
          'Check-In',
        ).having(
          (s) => s.sortType,
          'sortType',
          SortType.byDateAsc,
        ),
      ],
    );
  });
}
