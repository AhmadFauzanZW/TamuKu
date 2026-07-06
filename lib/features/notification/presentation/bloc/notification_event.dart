import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object> get props => [];
}

class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

class SendTelegramNotification extends NotificationEvent {
  final String phoneNumber;
  final String guestName;
  final String locationName;
  final String checkInTime;

  const SendTelegramNotification({
    required this.phoneNumber,
    required this.guestName,
    required this.locationName,
    required this.checkInTime,
  });

  @override
  List<Object> get props => [phoneNumber, guestName, locationName, checkInTime];
}
