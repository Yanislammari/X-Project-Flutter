import '../../models/notification.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final bool hasUnread;
  NotificationLoaded(this.notifications, {this.hasUnread = false});
}
class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
} 