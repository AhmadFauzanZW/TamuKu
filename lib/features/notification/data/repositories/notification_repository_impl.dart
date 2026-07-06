import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> getToken() async => null;
  @override
  Future<void> subscribeToTopic(String topic) async {}
  @override
  Future<void> sendTelegramMessage({
    required String phoneNumber,
    required String guestName,
    required String locationName,
    required String checkInTime,
  }) async {}
}
