import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/appwrite.dart';

import '../data/repositories/cards_repository.dart';
import '../data/repositories/current_user_repository.dart';
import '../data/models/models.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/transactions_repository.dart';
import '../data/repositories/wallet_repository.dart';
import '../providers/appearance_provider.dart';

class TransferSuccessNotification {
  final String recipientName;
  final double amount;
  final DateTime createdAt;

  const TransferSuccessNotification({
    required this.recipientName,
    required this.amount,
    required this.createdAt,
  });
}

class UserProvider extends ChangeNotifier {
  models.User? _user;
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  List<NotificationModel> _notifications = [];
  List<CardModel> _cards = [];
  TransferSuccessNotification? _pendingTransferNotification;
  bool _isLoading = false;
  CurrentUserRepository? _currentUserRepository;
  WalletRepository? _walletRepository;
  TransactionsRepository? _transactionsRepository;
  CardsRepository? _cardsRepository;
  NotificationRepository? _notificationRepository;

  models.User? get user => _user;
  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  List<NotificationModel> get notifications => _notifications;
  List<CardModel> get cards => _cards;
  TransferSuccessNotification? get pendingTransferNotification =>
      _pendingTransferNotification;
  bool get isLoading => _isLoading;

  // ── fetchUser ─────────────────────────────────────────────────────────────

  Future<void> fetchUser(Account account) async {
    _isLoading = true;
    notifyListeners();
    try {
      final currentUserRepo = _currentUserRepository;
      if (currentUserRepo == null) return;
      _user = await currentUserRepo.getCurrentUser();

      if (_user != null) {
        await Future.wait([
          fetchWallet(_user!.$id),
          fetchTransactions(_user!.$id),
          fetchNotifications(_user!.$id),
          fetchCards(_user!.$id),
        ]);
      }
      // Ngay sau khi có _user
      await _appearanceProvider?.loadForUser(_user!.$id);
    } catch (e) {
      debugPrint('UserProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Cards ─────────────────────────────────────────────────────────────────

  Future<void> fetchCards(String userId) async {
    final repo = _cardsRepository;
    if (repo == null) return;
    _cards = await repo.fetchCards(userId);
    notifyListeners();
  }

  Future<CardModel?> addCard({
    required String cardName,
    required String cardNumber,
    required String cardType,
    String? expiryDate,
  }) async {
    if (_user == null) return null;
    final repo = _cardsRepository;
    if (repo == null) return null;
    final newCard = await repo.addCard(
      userId: _user!.$id,
      cardName: cardName,
      cardNumber: cardNumber,
      cardType: cardType,
      expiryDate: expiryDate,
    );
    if (newCard != null) {
      _cards = [newCard, ..._cards];
      notifyListeners();
    }
    return newCard;
  }

  Future<bool> deleteCard(String cardId) async {
    final repo = _cardsRepository;
    if (repo == null) return false;
    final ok = await repo.deleteCard(cardId);
    if (ok) {
      _cards.removeWhere((c) => c.id == cardId);
      notifyListeners();
    }
    return ok;
  }

  Future<bool> toggleCardStatus(CardModel card) async {
    final repo = _cardsRepository;
    if (repo == null) return false;
    final updated = await repo.toggleCardStatus(card);
    if (updated != null) {
      final idx = _cards.indexWhere((c) => c.id == card.id);
      if (idx != -1) {
        _cards[idx] = updated;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<void> fetchNotifications(String userId) async {
    final repo = _notificationRepository;
    if (repo == null) return;
    _notifications = await repo.fetchNotifications(userId);
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final repo = _notificationRepository;
      if (repo == null) return;
      await repo.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi xóa thông báo: $e');
    }
  }

  // ── Wallet ────────────────────────────────────────────────────────────────

  Future<void> fetchWallet(String userId) async {
    final repo = _walletRepository;
    if (repo == null) return;
    _wallet = await repo.getWalletByUserId(userId);
    notifyListeners();
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<void> fetchTransactions(String userId) async {
    final repo = _transactionsRepository;
    if (repo == null) return;
    _transactions = await repo.fetchTransactions(userId);
    notifyListeners();
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  void queueTransferSuccessNotification({
    required String recipientName,
    required double amount,
  }) {
    _pendingTransferNotification = TransferSuccessNotification(
      recipientName: recipientName,
      amount: amount,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  TransferSuccessNotification? consumeTransferSuccessNotification() {
    final pending = _pendingTransferNotification;
    _pendingTransferNotification = null;
    return pending;
  }

  void clearUser() {
    _user = null;
    _wallet = null;
    _transactions = [];
    _notifications = [];
    _cards = [];
    _pendingTransferNotification = null;
    notifyListeners();
  }

  void subscribeToUpdates() {
    // Realtime hiện chưa tách theo bloc, giữ trống để tránh provider tiếp tục
    // ôm logic subscription toàn cục.
  }

  AppearanceProvider? _appearanceProvider;

  void setAppearanceProvider(AppearanceProvider p) {
    _appearanceProvider = p;
  }

  void setCurrentUserRepository(CurrentUserRepository repository) {
    _currentUserRepository = repository;
  }

  void setWalletRepository(WalletRepository repository) {
    _walletRepository = repository;
  }

  void setTransactionsRepository(TransactionsRepository repository) {
    _transactionsRepository = repository;
  }

  void setCardsRepository(CardsRepository repository) {
    _cardsRepository = repository;
  }

  void setNotificationRepository(NotificationRepository repository) {
    _notificationRepository = repository;
  }
}
