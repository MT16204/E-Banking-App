import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/appwrite.dart';
import '../data/models/models.dart';
import '../main.dart';
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

  models.User? get user => _user;
  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  List<NotificationModel> get notifications => _notifications;
  List<CardModel> get cards => _cards;
  TransferSuccessNotification? get pendingTransferNotification =>
      _pendingTransferNotification;
  bool get isLoading => _isLoading;

  static const _dbId = '695ec15a0017be03292c';
  static const _colCards = 'cards';
  static const _colWallets = 'wallets';
  static const _colTx = 'transactions';
  static const _colNotif = 'notification';

  String get databaseId => _dbId;

  // ── fetchUser ─────────────────────────────────────────────────────────────

  Future<void> fetchUser(Account account) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await account.get();

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

  Map<String, dynamic> _docToMap(models.Document doc) => {
    '\$id': doc.$id,
    ...doc.data,
  };

  // ── Cards ─────────────────────────────────────────────────────────────────

  Future<void> fetchCards(String userId) async {
    try {
      final db = Databases(client);
      final res = await db.listDocuments(
        databaseId: _dbId,
        collectionId: _colCards,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      _cards = res.documents
          .map((d) => CardModel.fromMap(_docToMap(d)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi lấy thẻ: $e');
    }
  }

  Future<CardModel?> addCard({
    required String cardName,
    required String cardNumber,
    required String cardType,
    String? expiryDate,
  }) async {
    if (_user == null) return null;
    try {
      final db = Databases(client);
      final doc = await db.createDocument(
        databaseId: _dbId,
        collectionId: _colCards,
        documentId: ID.unique(),
        data: {
          'userId': _user!.$id,
          'cardName': cardName,
          'cardNumber': cardNumber,
          'cardType': cardType,
          'status': 'active',
          if (expiryDate != null) 'expiryDate': expiryDate,
        },
      );
      final newCard = CardModel.fromMap(_docToMap(doc));
      _cards = [newCard, ..._cards];
      notifyListeners();
      return newCard;
    } catch (e) {
      debugPrint('Lỗi thêm thẻ: $e');
      return null;
    }
  }

  Future<bool> deleteCard(String cardId) async {
    try {
      await Databases(client).deleteDocument(
        databaseId: _dbId,
        collectionId: _colCards,
        documentId: cardId,
      );
      _cards.removeWhere((c) => c.id == cardId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa thẻ: $e');
      return false;
    }
  }

  Future<bool> toggleCardStatus(CardModel card) async {
    final newStatus = card.isActive ? 'locked' : 'active';
    try {
      await Databases(client).updateDocument(
        databaseId: _dbId,
        collectionId: _colCards,
        documentId: card.id,
        data: {'status': newStatus},
      );
      final idx = _cards.indexWhere((c) => c.id == card.id);
      if (idx != -1) {
        _cards[idx] = CardModel.fromMap({
          ...card.toMap(),
          '\$id': card.id,
          'status': newStatus,
        });
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Lỗi cập nhật trạng thái thẻ: $e');
      return false;
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<void> fetchNotifications(String userId) async {
    try {
      final res = await Databases(client).listDocuments(
        databaseId: _dbId,
        collectionId: _colNotif,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
          Query.limit(20),
        ],
      );
      _notifications = res.documents
          .map((d) => NotificationModel.fromMap(d.data))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi lấy thông báo: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await Databases(client).deleteDocument(
        databaseId: _dbId,
        collectionId: _colNotif,
        documentId: notificationId,
      );
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi xóa thông báo: $e');
    }
  }

  // ── Wallet ────────────────────────────────────────────────────────────────

  Future<void> fetchWallet(String userId) async {
    try {
      final res = await Databases(client).getDocument(
        databaseId: _dbId,
        collectionId: _colWallets,
        documentId: userId,
      );
      _wallet = WalletModel.fromMap(res.data);
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi lấy ví: $e');
    }
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<void> fetchTransactions(String userId) async {
    try {
      final res = await Databases(client).listDocuments(
        databaseId: _dbId,
        collectionId: _colTx,
        queries: [
          Query.or([
            Query.equal('senderId', userId),
            Query.equal('receiverId', userId),
          ]),
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );
      _transactions = res.documents
          .map((d) => TransactionModel.fromMap(d.data))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi lấy lịch sử giao dịch: $e');
    }
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
    final realtime = Realtime(client);
    realtime
        .subscribe([
          'databases.$_dbId.collections.$_colTx.documents',
          'databases.$_dbId.collections.$_colNotif.documents',
          'databases.$_dbId.collections.$_colCards.documents',
        ])
        .stream
        .listen((_) {
          if (_user != null) fetchUser(account);
        });
  }

  AppearanceProvider? _appearanceProvider;

  void setAppearanceProvider(AppearanceProvider p) {
    _appearanceProvider = p;
  }
}
