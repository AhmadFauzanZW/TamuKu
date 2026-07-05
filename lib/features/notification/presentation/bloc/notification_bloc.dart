import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitialize);
    on<SendWhatsAppNotification>(_onSendWhatsApp);
  }

  Future<void> _onInitialize(InitializeNotifications event, Emitter<NotificationState> emit) async {
    try {
      await _notificationRepository.initialize();
      final token = await _notificationRepository.getToken();
      emit(NotificationLoaded(fcmToken: token));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onSendWhatsApp(SendWhatsAppNotification event, Emitter<NotificationState> emit) async {
    try {
      await _notificationRepository.sendWhatsAppMessage(
        phoneNumber: event.phoneNumber,
        guestName: event.guestName,
        locationName: event.locationName,
        checkInTime: event.checkInTime,
      );
      emit(const NotificationSent());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
