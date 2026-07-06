abstract class NotificationRepository {
  Future<void> initialize();
  Future<String?> getToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> sendTelegramMessage({
    required String phoneNumber,
    required String guestName,
    required String locationName,
    required String checkInTime,
  });
}
