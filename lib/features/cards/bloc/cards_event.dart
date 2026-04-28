import 'package:banking_app/data/models/models.dart';

abstract class CardsEvent {
  const CardsEvent();
}

class CardsStarted extends CardsEvent {
  const CardsStarted();
}

class CardsRefreshed extends CardsEvent {
  const CardsRefreshed();
}

class CardAdded extends CardsEvent {
  final String cardName;
  final String cardNumber;
  final String cardType;
  final String? expiryDate;

  const CardAdded({
    required this.cardName,
    required this.cardNumber,
    required this.cardType,
    this.expiryDate,
  });
}

class CardDeleted extends CardsEvent {
  final String cardId;

  const CardDeleted(this.cardId);
}

class CardStatusToggled extends CardsEvent {
  final CardModel card;

  const CardStatusToggled(this.card);
}
