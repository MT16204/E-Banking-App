import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_app/data/repositories/current_user_repository.dart';
import 'package:banking_app/data/repositories/transactions_repository.dart';
import 'package:banking_app/data/repositories/transfer_repository.dart';
import 'package:banking_app/data/repositories/wallet_repository.dart';

import 'payments_event.dart';
import 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final CurrentUserRepository currentUserRepository;
  final WalletRepository walletRepository;
  final TransactionsRepository transactionsRepository;
  final TransferRepository transferRepository;

  PaymentsBloc({
    required this.currentUserRepository,
    required this.walletRepository,
    required this.transactionsRepository,
    required this.transferRepository,
  }) : super(const PaymentsInitial()) {
    on<PaymentsStarted>(_load);
    on<PaymentsRefreshed>(_load);
    on<PaymentsLookupCleared>(_clearLookup);
    on<LookupAccountRequested>(_lookup);
    on<TransferRequested>(_transfer);
  }

  Future<void> _load(
    PaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    final current = state;
    if (current is PaymentsLoaded) {
      emit(
        current.copyWith(
          isRefreshing: true,
          clearLookupError: true,
          clearSubmitError: true,
        ),
      );
    } else {
      emit(const PaymentsLoading());
    }
    try {
      final user = await currentUserRepository.getCurrentUser();
      final wallet = await walletRepository.getWalletByUserId(user.$id);
      final transactions = await transactionsRepository.fetchTransactions(
        user.$id,
      );
      emit(
        PaymentsLoaded(
          user: user,
          wallet: wallet,
          transactions: transactions,
          lookupUser: current is PaymentsLoaded ? current.lookupUser : null,
          lookupWallet: current is PaymentsLoaded ? current.lookupWallet : null,
        ),
      );
    } catch (e) {
      emit(PaymentsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _clearLookup(
    PaymentsLookupCleared event,
    Emitter<PaymentsState> emit,
  ) {
    final current = state;
    if (current is! PaymentsLoaded) return;
    emit(
      current.copyWith(
        clearLookup: true,
        clearLookupError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> _lookup(
    LookupAccountRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PaymentsLoaded) {
      await _load(const PaymentsStarted(), emit);
      if (state is! PaymentsLoaded) return;
    }
    final loaded = state as PaymentsLoaded;
    emit(
      loaded.copyWith(
        isLookingUpRecipient: true,
        clearLookupError: true,
        clearSubmitError: true,
        clearSuccess: true,
      ),
    );
    try {
      final result = await walletRepository.lookupAccountByNumber(
        event.accountNumber,
      );
      emit(
        loaded.copyWith(
          lookupUser: result['user'] as dynamic,
          lookupWallet: result['wallet'] as dynamic,
          isLookingUpRecipient: false,
        ),
      );
    } catch (e) {
      emit(
        loaded.copyWith(
          isLookingUpRecipient: false,
          lookupError: e.toString().replaceAll('Exception: ', ''),
          clearLookup: true,
        ),
      );
    }
  }

  Future<void> _transfer(
    TransferRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PaymentsLoaded) {
      await _load(const PaymentsStarted(), emit);
      if (state is! PaymentsLoaded) return;
    }
    final loaded = state as PaymentsLoaded;
    emit(
      loaded.copyWith(
        isSubmittingTransfer: true,
        clearSubmitError: true,
        clearSuccess: true,
      ),
    );
    try {
      final transaction = await transferRepository.transferMoney(
        senderUserId: event.senderUserId,
        senderAccountNumber: event.senderAccountNumber,
        recipientAccountNumber: event.recipientAccountNumber,
        amount: event.amount,
        note: event.note,
        categoryId: event.categoryId,
      );
      final user = await currentUserRepository.getCurrentUser();
      final wallet = await walletRepository.getWalletByUserId(user.$id);
      final transactions = await transactionsRepository.fetchTransactions(
        user.$id,
      );
      emit(
        loaded.copyWith(
          wallet: wallet,
          transactions: transactions,
          isSubmittingTransfer: false,
          lastSuccessfulTransaction: transaction,
          clearLookup: true,
        ),
      );
    } catch (e) {
      emit(
        loaded.copyWith(
          isSubmittingTransfer: false,
          submitError: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
