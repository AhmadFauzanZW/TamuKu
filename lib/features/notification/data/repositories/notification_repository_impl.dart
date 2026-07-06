import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../shared/services/api_client.dart';
import '../../domain/repositories/notification_repository.dart';

/// Implementation of [NotificationRepository].
///
/// **Push (FCM)**: uses [FirebaseMessaging] (free tier) only for requesting
/// permission, obtaining the device token, and subscribing to topics on the
/// client. No Cloud Functions are used (those require the paid Blaze plan).
///
/// **Delivery to host**: the actual notification is delivered as a Telegram
/// message, sent through the Contabo ElysiaJS backend via [ApiClient].
class NotificationRepositoryImpl implements NotificationRepository {
  /// Creates a [NotificationRepositoryImpl].
  ///
  /// [apiClient] is injectable for testability and defaults to [ApiClient].
  /// [messaging] defaults to [FirebaseMessaging.instance].
  NotificationRepositoryImpl({
    ApiClient? apiClient,
    FirebaseMessaging? messaging,
  }) : _apiClient = apiClient ?? ApiClient(),
       _messaging = messaging ?? FirebaseMessaging.instance;

  final ApiClient _apiClient;
  final FirebaseMessaging _messaging;

  /// Requests FCM notification permission and wires foreground handling.
  ///
  /// Foreground messages are logged via [FirebaseMessaging.onMessage]; the UI
  /// layer is free to listen to the same stream for in-app banners.
  @override
  Future<void> initialize() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      // Foreground messages: subscribe so notifications are not lost while the
      // app is open. Presentation layer can also listen for richer UI.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Intentionally silent: display is handled by the presentation layer.
      });
    } catch (e) {
      throw Exception('Gagal menginisialisasi notifikasi: $e');
    }
  }

  /// Returns the FCM device token, or `null` if unavailable.
  @override
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      throw Exception('Gagal mengambil token notifikasi: $e');
    }
  }

  /// Subscribes the device to an FCM [topic] for broadcast notifications.
  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      throw Exception('Gagal berlangganan topik notifikasi: $e');
    }
  }

  /// Sends a guest check-in notification to the host via Telegram.
  ///
  /// NOTE: the interface param [phoneNumber] is reused as the Telegram
  /// **chat id** (numeric id or `@username`). The backend forwards it to the
  /// Telegram Bot API as `chat_id`. Kept named `phoneNumber` to satisfy the
  /// [NotificationRepository] contract.
  ///
  /// The message body is built by [buildTelegramMessage] in Bahasa Indonesia
  /// using HTML formatting (matching the backend's `sendGuestNotification`).
  @override
  Future<void> sendTelegramMessage({
    required String phoneNumber,
    required String guestName,
    required String locationName,
    required String checkInTime,
  }) async {
    try {
      final text = buildTelegramMessage(
        guestName: guestName,
        locationName: locationName,
        checkInTime: checkInTime,
      );
      await _apiClient.sendTelegramNotification(
        chatId: phoneNumber,
        text: text,
      );
    } catch (e) {
      throw Exception('Gagal mengirim notifikasi Telegram: $e');
    }
  }

  /// Builds the HTML Telegram message for a guest check-in.
  ///
  /// Pure function (no I/O) so it can be unit-tested directly. Mirrors the
  /// backend format: judul lokasi, nama tamu, dan jam kedatangan.
  static String buildTelegramMessage({
    required String guestName,
    required String locationName,
    required String checkInTime,
  }) {
    final lines = <String>[
      '🏢 <b>Tamu Baru — $locationName</b>',
      '',
      '👤 <b>Nama:</b> $guestName',
      '🕐 <b>Waktu Check-In:</b> $checkInTime',
    ];
    return lines.join('\n');
  }
}
