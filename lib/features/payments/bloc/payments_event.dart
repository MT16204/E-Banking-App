abstract class PaymentsEvent {
  const PaymentsEvent();
}

class PaymentsStarted extends PaymentsEvent {
  const PaymentsStarted();
}

class PaymentsRefreshed extends PaymentsEvent {
  const PaymentsRefreshed();
}

class PaymentsLookupCleared extends PaymentsEvent {
  const PaymentsLookupCleared();
}

class LookupAccountRequested extends PaymentsEvent {
  final String accountNumber;

  const LookupAccountRequested(this.accountNumber);
}

class TransferRequested extends PaymentsEvent {
  final String senderUserId;
  final String senderAccountNumber;
  final String recipientAccountNumber;
  final double amount;
  final String note;
  final String? categoryId;

  const TransferRequested({
    required this.senderUserId,
    required this.senderAccountNumber,
    required this.recipientAccountNumber,
    required this.amount,
    required this.note,
    this.categoryId,
  });
}
