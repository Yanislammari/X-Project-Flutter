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
    on<_NotificationsUpdated>(_onNotificationsUpdated);
  }

  void _onListenNotifications(ListenNotifications event, Emitter<NotificationState> emit) {
    // Annuler l'ancienne souscription s'il y en a une
    _subscription?.cancel();
    
    // Créer une nouvelle souscription
    _subscription = notificationRepository.notificationsStream(event.toUserId).listen(
      (notifications) {
        add(_NotificationsUpdated(notifications));
      },
      onError: (error) {
        emit(NotificationError('Erreur lors de l\'écoute des notifications : $error'));
      },
    );
  }

  void _onNotificationsUpdated(_NotificationsUpdated event, Emitter<NotificationState> emit) {
    emit(NotificationLoaded(event.notifications));
  }

  Future<void> _onAddNotification(AddNotificationEvent event, Emitter<NotificationState> emit) async {
    try {
      await notificationRepository.addNotification(event.notification);
      // Pas besoin d'émettre un état spécifique, le stream se chargera de la mise à jour
    } catch (e) {
      emit(NotificationError('Erreur lors de l\'ajout de la notification : $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

// Événement privé pour les mises à jour du stream
class _NotificationsUpdated extends NotificationEvent {
  final List<AppNotification> notifications;
  _NotificationsUpdated(this.notifications);
} 