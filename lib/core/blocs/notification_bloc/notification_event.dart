import '../../models/notification.dart';

abstract class NotificationEvent {}

class ListenNotifications extends NotificationEvent {
  final String toUserId;
  ListenNotifications(this.toUserId);
}

class AddNotificationEvent extends NotificationEvent {
  final AppNotification notification;
  AddNotificationEvent(this.notification);
} 