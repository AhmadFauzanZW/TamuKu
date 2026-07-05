import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final String? fcmToken;
  const NotificationLoaded({this.fcmToken});
  @override
  List<Object> get props => [fcmToken ?? ''];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object> get props => [message];
}

class NotificationSent extends NotificationState {
  const NotificationSent();
}
