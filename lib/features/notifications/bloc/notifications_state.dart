import 'package:banking_app/data/models/models.dart';

abstract class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final String query;
  final Set<String> deletingIds;
  final bool isRefreshing;

  const NotificationsLoaded({
    required this.notifications,
    this.query = '',
    this.deletingIds = const {},
    this.isRefreshing = false,
  });

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  NotificationsLoaded copyWith({
    List<NotificationModel>? notifications,
    String? query,
    Set<String>? deletingIds,
    bool? isRefreshing,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      query: query ?? this.query,
      deletingIds: deletingIds ?? this.deletingIds,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);
}
