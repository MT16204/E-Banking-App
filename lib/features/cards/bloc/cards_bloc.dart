import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_app/data/repositories/cards_repository.dart';
import 'package:banking_app/data/repositories/current_user_repository.dart';

import 'cards_event.dart';
import 'cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  final CurrentUserRepository currentUserRepository;
  final CardsRepository cardsRepository;

  CardsBloc({
    required this.currentUserRepository,
    required this.cardsRepository,
  }) : super(const CardsInitial()) {
    on<CardsStarted>(_load);
    on<CardsRefreshed>(_load);
    on<CardAdded>(_addCard);
    on<CardDeleted>(_deleteCard);
    on<CardStatusToggled>(_toggleCardStatus);
  }

  Future<void> _load(CardsEvent event, Emitter<CardsState> emit) async {
    final current = state;
    if (current is CardsLoaded) {
      emit(current.copyWith(isRefreshing: true, clearMessage: true));
    } else {
      emit(const CardsLoading());
    }
    try {
      final user = await currentUserRepository.getCurrentUser();
      final cards = await cardsRepository.fetchCards(user.$id);
      emit(CardsLoaded(cards: cards));
    } catch (e) {
      emit(CardsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _addCard(CardAdded event, Emitter<CardsState> emit) async {
    final current = state is CardsLoaded ? (state as CardsLoaded).cards : null;
    if (state is CardsLoaded) {
      emit((state as CardsLoaded).copyWith(isMutating: true, clearMessage: true));
    } else {
      emit(const CardsLoading());
    }
    try {
      final user = await currentUserRepository.getCurrentUser();
      final newCard = await cardsRepository.addCard(
        userId: user.$id,
        cardName: event.cardName,
        cardNumber: event.cardNumber,
        cardType: event.cardType,
        expiryDate: event.expiryDate,
      );
      if (newCard == null) throw Exception('Không thể thêm thẻ.');
      emit(
        CardsLoaded(
          cards: [newCard, ...(current ?? [])],
          message: 'Card added',
        ),
      );
    } catch (e) {
      emit(CardsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _deleteCard(CardDeleted event, Emitter<CardsState> emit) async {
    final current = state is CardsLoaded ? (state as CardsLoaded).cards : null;
    if (state is CardsLoaded) {
      emit((state as CardsLoaded).copyWith(isMutating: true, clearMessage: true));
    } else {
      emit(const CardsLoading());
    }
    try {
      final ok = await cardsRepository.deleteCard(event.cardId);
      if (!ok) throw Exception('Không thể xóa thẻ.');
      emit(
        CardsLoaded(
          cards: (current ?? [])
              .where((card) => card.id != event.cardId)
              .toList(),
          message: 'Card deleted',
        ),
      );
    } catch (e) {
      emit(CardsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _toggleCardStatus(
    CardStatusToggled event,
    Emitter<CardsState> emit,
  ) async {
    final current = state is CardsLoaded ? (state as CardsLoaded).cards : null;
    if (state is CardsLoaded) {
      emit((state as CardsLoaded).copyWith(isMutating: true, clearMessage: true));
    } else {
      emit(const CardsLoading());
    }
    try {
      final updated = await cardsRepository.toggleCardStatus(event.card);
      if (updated == null) throw Exception('Không thể cập nhật trạng thái thẻ.');
      emit(
        CardsLoaded(
          cards: (current ?? [])
              .map((card) => card.id == updated.id ? updated : card)
              .toList(),
          message: 'Card status updated',
        ),
      );
    } catch (e) {
      emit(CardsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
