import 'package:appwrite/models.dart' as models;
import 'package:banking_app/data/models/models.dart';

abstract class PaymentsState {
  const PaymentsState();
}

class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsLoaded extends PaymentsState {
  final models.User user;
  final WalletModel? wallet;
  final List<TransactionModel> transactions;
  final UserModel? lookupUser;
  final WalletModel? lookupWallet;
  final bool isRefreshing;
  final bool isLookingUpRecipient;
  final bool isSubmittingTransfer;
  final String? lookupError;
  final String? submitError;
  final TransactionModel? lastSuccessfulTransaction;

  const PaymentsLoaded({
    required this.user,
    required this.wallet,
    required this.transactions,
    this.lookupUser,
    this.lookupWallet,
    this.isRefreshing = false,
    this.isLookingUpRecipient = false,
    this.isSubmittingTransfer = false,
    this.lookupError,
    this.submitError,
    this.lastSuccessfulTransaction,
  });

  PaymentsLoaded copyWith({
    models.User? user,
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    UserModel? lookupUser,
    WalletModel? lookupWallet,
    bool? isRefreshing,
    bool? isLookingUpRecipient,
    bool? isSubmittingTransfer,
    String? lookupError,
    String? submitError,
    TransactionModel? lastSuccessfulTransaction,
    bool clearLookupError = false,
    bool clearSubmitError = false,
    bool clearSuccess = false,
    bool clearLookup = false,
  }) {
    return PaymentsLoaded(
      user: user ?? this.user,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      lookupUser: clearLookup ? null : (lookupUser ?? this.lookupUser),
      lookupWallet: clearLookup ? null : (lookupWallet ?? this.lookupWallet),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLookingUpRecipient:
          isLookingUpRecipient ?? this.isLookingUpRecipient,
      isSubmittingTransfer: isSubmittingTransfer ?? this.isSubmittingTransfer,
      lookupError: clearLookupError ? null : (lookupError ?? this.lookupError),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      lastSuccessfulTransaction: clearSuccess
          ? null
          : (lastSuccessfulTransaction ?? this.lastSuccessfulTransaction),
    );
  }
}

class PaymentsError extends PaymentsState {
  final String message;

  const PaymentsError(this.message);
}
