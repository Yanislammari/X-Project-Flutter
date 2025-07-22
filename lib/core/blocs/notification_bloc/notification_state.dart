part of 'notification_bloc.dart';

enum NotificationStatus {
  initial,
  loaded,
  error,
}

class NotificationState {
  final NotificationStatus status;
  final String? message;
  final List<AppNotification>? notifications;
  final bool hasUnread;
  final Exception? error;

  NotificationState({
    this.status = NotificationStatus.initial,
    this.message,
    this.notifications,
    this.hasUnread = false,
    this.error,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    String? message,
    List<AppNotification>? notifications,
    bool? hasUnread,
    Exception? error,
  }) {
    return NotificationState(
      status: status ?? this.status,
      message: message ?? this.message,
      notifications: notifications ?? this.notifications,
      hasUnread: hasUnread ?? this.hasUnread,
      error: error ?? this.error,
    );
  }
}
