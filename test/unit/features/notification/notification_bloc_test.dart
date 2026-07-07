import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamuku/features/notification/domain/repositories/notification_repository.dart';
import 'package:tamuku/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:tamuku/features/notification/presentation/bloc/notification_event.dart';
import 'package:tamuku/features/notification/presentation/bloc/notification_state.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepo;
  late NotificationBloc bloc;

  setUp(() {
    mockRepo = MockNotificationRepository();
    bloc = NotificationBloc(notificationRepository: mockRepo);
  });

  tearDown(() => bloc.close());

  group('InitializeNotifications', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoaded] with fcmToken on success',
      build: () {
        when(() => mockRepo.initialize()).thenAnswer((_) async {});
        when(() => mockRepo.getToken()).thenAnswer((_) async => 'fake-token');
        return NotificationBloc(notificationRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const InitializeNotifications()),
      expect: () => [
        isA<NotificationLoaded>().having(
          (s) => s.fcmToken,
          'fcmToken',
          'fake-token',
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.initialize()).called(1);
        verify(() => mockRepo.getToken()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationError] when initialize throws',
      build: () {
        when(() => mockRepo.initialize()).thenThrow(Exception('FCM failed'));
        return NotificationBloc(notificationRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const InitializeNotifications()),
      expect: () => [isA<NotificationError>()],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationError] when getToken throws',
      build: () {
        when(() => mockRepo.initialize()).thenAnswer((_) async {});
        when(() => mockRepo.getToken()).thenThrow(Exception('Token error'));
        return NotificationBloc(notificationRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const InitializeNotifications()),
      expect: () => [isA<NotificationError>()],
    );
  });

  group('SendTelegramNotification', () {
    setUp(() {
      registerFallbackValue(const SendTelegramNotification(
        phoneNumber: '',
        guestName: '',
        locationName: '',
        checkInTime: '',
      ));
    });

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationSent] on success',
      build: () {
        when(() => mockRepo.sendTelegramMessage(
              phoneNumber: any(named: 'phoneNumber'),
              guestName: any(named: 'guestName'),
              locationName: any(named: 'locationName'),
              checkInTime: any(named: 'checkInTime'),
            )).thenAnswer((_) async {});
        return NotificationBloc(notificationRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const SendTelegramNotification(
        phoneNumber: '081234567890',
        guestName: 'Budi Santoso',
        locationName: 'Kantor Desa Cakrawala',
        checkInTime: '2026-07-07 10:00',
      )),
      expect: () => [isA<NotificationSent>()],
      verify: (_) {
        verify(() => mockRepo.sendTelegramMessage(
              phoneNumber: '081234567890',
              guestName: 'Budi Santoso',
              locationName: 'Kantor Desa Cakrawala',
              checkInTime: '2026-07-07 10:00',
            )).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationError] when sendTelegramMessage throws',
      build: () {
        when(() => mockRepo.sendTelegramMessage(
              phoneNumber: any(named: 'phoneNumber'),
              guestName: any(named: 'guestName'),
              locationName: any(named: 'locationName'),
              checkInTime: any(named: 'checkInTime'),
            )).thenThrow(Exception('Telegram API error'));
        return NotificationBloc(notificationRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const SendTelegramNotification(
        phoneNumber: '081234567890',
        guestName: 'Budi',
        locationName: 'Kantor',
        checkInTime: '2026-07-07 10:00',
      )),
      expect: () => [isA<NotificationError>()],
    );
  });
}
