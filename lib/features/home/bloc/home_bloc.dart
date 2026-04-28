import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_app/data/repositories/cards_repository.dart';
import 'package:banking_app/data/repositories/current_user_repository.dart';
import 'package:banking_app/data/repositories/transactions_repository.dart';
import 'package:banking_app/data/repositories/wallet_repository.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CurrentUserRepository currentUserRepository;
  final WalletRepository walletRepository;
  final TransactionsRepository transactionsRepository;
  final CardsRepository cardsRepository;

  HomeBloc({
    required this.currentUserRepository,
    required this.walletRepository,
    required this.transactionsRepository,
    required this.cardsRepository,
  }) : super(const HomeInitial()) {
    on<HomeStarted>(_load);
    on<HomeRefreshed>(_load);
  }

  Future<void> _load(HomeEvent event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const HomeLoading());
    }
    try {
      final user = await currentUserRepository.getCurrentUser();
      final wallet = await walletRepository.getWalletByUserId(user.$id);
      final transactions = await transactionsRepository.fetchTransactions(
        user.$id,
      );
      final cards = await cardsRepository.fetchCards(user.$id);
      emit(
        HomeLoaded(
          user: user,
          wallet: wallet,
          transactions: transactions,
          cards: cards,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
