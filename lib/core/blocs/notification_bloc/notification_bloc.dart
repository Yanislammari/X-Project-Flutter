import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification.dart';
import '../../repositories/notification/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import 'dart:async';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  StreamSubscription<List<AppNotification>>? _subscription;
  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<ListenNotifications>(_onListenNotifications);
    on<AddNotificationEvent>(_onAddNotification);
    on<_NotificationsUpdated>((event, emit) {
      emit(NotificationLoaded(event.notifications));
      if (event.notifications.isNotEmpty) {
        add(NotificationReceived(event.notifications.first));
      }
    });
    on<NotificationReceived>((event, emit) {
    });
  }

  void _onListenNotifications(ListenNotifications event, Emitter<NotificationState> emit) {
    _subscription?.cancel();
    _subscription = notificationRepository.notificationsStream(event.toUserId).listen((notifications) {
      add(_NotificationsUpdated(notifications));
    });
  }

  Future<void> _onAddNotification(AddNotificationEvent event, Emitter<NotificationState> emit) async {
    try {
      await notificationRepository.addNotification(event.notification);
    } catch (e) {
      emit(NotificationError(e.toString()));
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

class NotificationReceived extends NotificationEvent {
  final AppNotification notification;
  NotificationReceived(this.notification);
} 