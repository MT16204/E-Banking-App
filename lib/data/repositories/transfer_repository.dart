import 'package:appwrite/appwrite.dart';
import 'package:banking_app/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'notification_repository.dart';

class TransferRepository {
  final Databases databases;
  final NotificationRepository notificationRepository;

  static const String _databaseId = AppConfig.databaseId;
  static const String _walletsCollection = AppConfig.walletsCollection;
  static const String _transactionsCollection =
      AppConfig.transactionsCollection;

  TransferRepository(this.databases, this.notificationRepository);

  Future<TransactionModel> transferMoney({
    required String senderUserId,
    required String senderAccountNumber,
    required String recipientAccountNumber,
    required double amount,
    required String note,
    String? categoryId,
  }) async {
    try {
      final senderWalletDoc = await databases.getDocument(
        databaseId: _databaseId,
        collectionId: _walletsCollection,
        documentId: senderUserId,
      );
      final senderWallet = WalletModel.fromMap(senderWalletDoc.data);

      if (senderWallet.balance < amount) {
        throw Exception('Số dư không đủ để thực hiện giao dịch');
      }

      final recipientWalletResponse = await databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _walletsCollection,
        queries: [
          Query.equal('accountNumber', recipientAccountNumber),
          Query.limit(1),
        ],
      );

      if (recipientWalletResponse.documents.isEmpty) {
        throw Exception('Tài khoản thụ hưởng không tồn tại');
      }

      final recipientWalletDoc = recipientWalletResponse.documents.first;
      final recipientWallet = WalletModel.fromMap(recipientWalletDoc.data);

      if (recipientWallet.userId == senderUserId) {
        throw Exception('Không thể chuyển tiền cho chính mình');
      }

      final senderNewBalance = senderWallet.balance - amount;
      final recipientNewBalance = recipientWallet.balance + amount;

      await databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _walletsCollection,
        documentId: senderUserId,
        data: {'balance': senderNewBalance},
      );

      await databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _walletsCollection,
        documentId: recipientWallet.userId,
        data: {'balance': recipientNewBalance},
      );

      final transactionDoc = await databases.createDocument(
        databaseId: _databaseId,
        collectionId: _transactionsCollection,
        documentId: ID.unique(),
        data: {
          'senderId': senderUserId,
          'receiverId': recipientWallet.userId,
          'amount': amount,
          'balanceAfter': senderNewBalance,
          'type': 'transfer',
          'description': note.isNotEmpty ? note : 'Chuyển tiền nội bộ',
          'createdAt': DateTime.now().toIso8601String(),
          'category': categoryId ?? 'other',
        },
      );

      final transaction = TransactionModel.fromMap(transactionDoc.data);

      try {
        await notificationRepository.createTransferNotification(
          recipientUserId: recipientWallet.userId,
          senderAccountNumber: senderAccountNumber,
          amount: amount,
          note: note,
        );
      } catch (e) {
        debugPrint('Tạo notification thất bại (non-critical): $e');
      }

      debugPrint(
        'Chuyển tiền thành công: $amount VND từ $senderAccountNumber đến $recipientAccountNumber',
      );

      return transaction;
    } on AppwriteException catch (e) {
      debugPrint('transferMoney Appwrite error (${e.code}): ${e.message}');
      throw Exception('Giao dịch thất bại: ${e.message}');
    } catch (e) {
      debugPrint('transferMoney error: $e');
      rethrow;
    }
  }
}
