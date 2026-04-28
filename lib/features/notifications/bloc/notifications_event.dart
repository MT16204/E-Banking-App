abstract class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed();
}

class NotificationsQueryChanged extends NotificationsEvent {
  final String query;

  const NotificationsQueryChanged(this.query);
}

class NotificationDeleted extends NotificationsEvent {
  final String notificationId;

  const NotificationDeleted(this.notificationId);
}
