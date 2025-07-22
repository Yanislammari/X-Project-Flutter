import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification.dart';
import '../../repositories/notification/notification_repository.dart';
import 'notification_event.dart';
import 'dart:async';

part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  StreamSubscription<List<AppNotification>>? _subscription;
  
  NotificationBloc({required this.notificationRepository}) : super(NotificationState()) {
    on<ListenNotifications>(_onListenNotifications);
    on<AddNotificationEvent>(_onAddNotification);
    on<_NotificationsUpdated>(_onNotificationsUpdated);
  }

  void _onListenNotifications(ListenNotifications event, Emitter<NotificationState> emit) {
    _subscription?.cancel();
    
    _subscription = notificationRepository.notificationsStream(event.toUserId).listen(
      (notifications) {
        add(_NotificationsUpdated(notifications));
      },
      onError: (error) {
        emit(state.copyWith(status: NotificationStatus.error, message: 'Erreur lors de l\'écoute des notifications : $error'));
      },
    );
  }

  void _onNotificationsUpdated(_NotificationsUpdated event, Emitter<NotificationState> emit) {
    emit(state.copyWith(status: NotificationStatus.loaded, notifications: event.notifications));
  }

  Future<void> _onAddNotification(AddNotificationEvent event, Emitter<NotificationState> emit) async {
    try {
      await notificationRepository.addNotification(event.notification);
    } catch (e) {
      emit(state.copyWith(status: NotificationStatus.error, message: 'Erreur lors de l\'ajout de la notification : $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _NotificationsUpdated extends NotificationEvent {
  final List<AppNotification> notifications;
  _NotificationsUpdated(this.notifications);
}