import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_app/data/repositories/current_user_repository.dart';
import 'package:banking_app/data/repositories/transactions_repository.dart';

import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final CurrentUserRepository currentUserRepository;
  final TransactionsRepository transactionsRepository;

  AnalyticsBloc({
    required this.currentUserRepository,
    required this.transactionsRepository,
  }) : super(const AnalyticsInitial()) {
    on<AnalyticsStarted>(_load);
    on<AnalyticsRefreshed>(_load);
  }

  Future<void> _load(
    AnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final user = await currentUserRepository.getCurrentUser();
      final transactions = await transactionsRepository.fetchTransactions(
        user.$id,
      );
      emit(AnalyticsLoaded(transactions));
    } catch (e) {
      emit(AnalyticsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
