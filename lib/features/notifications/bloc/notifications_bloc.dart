import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_app/data/repositories/current_user_repository.dart';
import 'package:banking_app/data/repositories/notification_repository.dart';

import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  final CurrentUserRepository currentUserRepository;
  final NotificationRepository notificationRepository;

  NotificationsBloc({
    required this.currentUserRepository,
    required this.notificationRepository,
  }) : super(const NotificationsInitial()) {
    on<NotificationsStarted>(_load);
    on<NotificationsRefreshed>(_load);
    on<NotificationsQueryChanged>(_onQueryChanged);
    on<NotificationDeleted>(_delete);
  }

  Future<void> _load(
    NotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is NotificationsLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const NotificationsLoading());
    }
    try {
      final user = await currentUserRepository.getCurrentUser();
      final notifications = await notificationRepository.fetchNotifications(
        user.$id,
      );
      emit(
        NotificationsLoaded(
          notifications: notifications,
          query: current is NotificationsLoaded ? current.query : '',
        ),
      );
    } catch (e) {
      emit(NotificationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onQueryChanged(
    NotificationsQueryChanged event,
    Emitter<NotificationsState> emit,
  ) {
    final current = state;
    if (current is! NotificationsLoaded) return;
    emit(current.copyWith(query: event.query));
  }

  Future<void> _delete(
    NotificationDeleted event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state is NotificationsLoaded
        ? (state as NotificationsLoaded).notifications
        : null;
    final deletingIds = state is NotificationsLoaded
        ? Set<String>.from((state as NotificationsLoaded).deletingIds)
        : <String>{};
    deletingIds.add(event.notificationId);
    if (state is NotificationsLoaded) {
      emit((state as NotificationsLoaded).copyWith(deletingIds: deletingIds));
    } else {
      emit(const NotificationsLoading());
    }
    try {
      await notificationRepository.deleteNotification(event.notificationId);
      emit(
        NotificationsLoaded(
          notifications: (current ?? [])
              .where((item) => item.id != event.notificationId)
              .toList(),
        ),
      );
    } catch (e) {
      emit(NotificationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
