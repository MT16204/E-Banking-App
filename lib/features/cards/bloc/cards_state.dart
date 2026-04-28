import 'package:banking_app/data/models/models.dart';

abstract class CardsState {
  const CardsState();
}

class CardsInitial extends CardsState {
  const CardsInitial();
}

class CardsLoading extends CardsState {
  const CardsLoading();
}

class CardsLoaded extends CardsState {
  final List<CardModel> cards;
  final bool isRefreshing;
  final bool isMutating;
  final String? message;

  const CardsLoaded({
    required this.cards,
    this.isRefreshing = false,
    this.isMutating = false,
    this.message,
  });

  CardsLoaded copyWith({
    List<CardModel>? cards,
    bool? isRefreshing,
    bool? isMutating,
    String? message,
    bool clearMessage = false,
  }) {
    return CardsLoaded(
      cards: cards ?? this.cards,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isMutating: isMutating ?? this.isMutating,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class CardsError extends CardsState {
  final String message;

  const CardsError(this.message);
}
