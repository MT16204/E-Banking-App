import 'package:appwrite/models.dart' as models;
import 'package:banking_app/data/models/models.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final models.User user;
  final WalletModel? wallet;
  final List<TransactionModel> transactions;
  final List<CardModel> cards;
  final bool isRefreshing;

  const HomeLoaded({
    required this.user,
    required this.wallet,
    required this.transactions,
    required this.cards,
    this.isRefreshing = false,
  });

  HomeLoaded copyWith({
    models.User? user,
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    List<CardModel>? cards,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      user: user ?? this.user,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      cards: cards ?? this.cards,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
