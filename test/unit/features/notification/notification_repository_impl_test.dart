import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamuku/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:tamuku/shared/services/api_client.dart';
import 'package:test/test.dart';

// ─── Mocks ────────────────────────────────────────────────────────

class MockApiClient extends Mock implements ApiClient {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

// ─── Fixtures ─────────────────────────────────────────────────────

const tChatId = '123456789';
const tGuestName = 'Budi Santoso';
const tLocationName = 'Kantor Desa Cakrawala';
const tCheckInTime = '06/07/2026 10.00';
const tTopic = 'location-loc1';

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  late MockApiClient apiClient;
  late MockFirebaseMessaging messaging;
  late NotificationRepositoryImpl repository;

  setUp(() {
    apiClient = MockApiClient();
    messaging = MockFirebaseMessaging();
    repository = NotificationRepositoryImpl(
      apiClient: apiClient,
      messaging: messaging,
    );
  });

  // ─── buildTelegramMessage (pure helper) ───────────────────────

  group('buildTelegramMessage', () {
    test('contains guest name, location, and check-in time', () {
      final text = NotificationRepositoryImpl.buildTelegramMessage(
        guestName: tGuestName,
        locationName: tLocationName,
        checkInTime: tCheckInTime,
      );

      expect(text, contains(tGuestName));
      expect(text, contains(tLocationName));
      expect(text, contains(tCheckInTime));
    });

    test('uses HTML bold tags matching backend format', () {
      final text = NotificationRepositoryImpl.buildTelegramMessage(
        guestName: tGuestName,
        locationName: tLocationName,
        checkInTime: tCheckInTime,
      );

      expect(text, contains('<b>'));
      expect(text, contains('</b>'));
      expect(text, contains('Tamu Baru'));
    });
  });

  // ─── sendTelegramMessage ──────────────────────────────────────

  group('sendTelegramMessage', () {
    test(
      'forwards phoneNumber as chatId and a well-formed text to ApiClient',
      () async {
        when(
          () => apiClient.sendTelegramNotification(
            chatId: any(named: 'chatId'),
            text: any(named: 'text'),
          ),
        ).thenAnswer((_) async {});

        await repository.sendTelegramMessage(
          phoneNumber: tChatId,
          guestName: tGuestName,
          locationName: tLocationName,
          checkInTime: tCheckInTime,
        );

        final captured =
            verify(
                  () => apiClient.sendTelegramNotification(
                    chatId: tChatId,
                    text: captureAny(named: 'text'),
                  ),
                ).captured.single
                as String;

        expect(captured, contains(tGuestName));
        expect(captured, contains(tLocationName));
        expect(captured, contains(tCheckInTime));
      },
    );

    test('wraps ApiClient failure in an Indonesian error message', () async {
      when(
        () => apiClient.sendTelegramNotification(
          chatId: any(named: 'chatId'),
          text: any(named: 'text'),
        ),
      ).thenThrow(Exception('network down'));

      expect(
        () => repository.sendTelegramMessage(
          phoneNumber: tChatId,
          guestName: tGuestName,
          locationName: tLocationName,
          checkInTime: tCheckInTime,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Gagal mengirim notifikasi Telegram'),
          ),
        ),
      );
    });
  });

  // ─── getToken ─────────────────────────────────────────────────

  group('getToken', () {
    test('returns the FCM token from FirebaseMessaging', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');

      final token = await repository.getToken();

      expect(token, 'fcm-token');
      verify(() => messaging.getToken()).called(1);
    });

    test('wraps failure in an Indonesian error message', () async {
      when(() => messaging.getToken()).thenThrow(Exception('boom'));

      expect(
        repository.getToken,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Gagal mengambil token notifikasi'),
          ),
        ),
      );
    });
  });

  // ─── subscribeToTopic ─────────────────────────────────────────

  group('subscribeToTopic', () {
    test('delegates to FirebaseMessaging.subscribeToTopic', () async {
      when(() => messaging.subscribeToTopic(tTopic)).thenAnswer((_) async {});

      await repository.subscribeToTopic(tTopic);

      verify(() => messaging.subscribeToTopic(tTopic)).called(1);
    });

    test('wraps failure in an Indonesian error message', () async {
      when(
        () => messaging.subscribeToTopic(tTopic),
      ).thenThrow(Exception('boom'));

      expect(
        () => repository.subscribeToTopic(tTopic),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Gagal berlangganan topik notifikasi'),
          ),
        ),
      );
    });
  });
}
