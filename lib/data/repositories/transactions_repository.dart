import 'package:appwrite/appwrite.dart';
import 'package:banking_app/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class TransactionsRepository {
  final Databases databases;

  static const String _databaseId = AppConfig.databaseId;
  static const String _transactionsCollection =
      AppConfig.transactionsCollection;

  TransactionsRepository(this.databases);

  Future<List<TransactionModel>> fetchTransactions(String userId) async {
    try {
      final res = await databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _transactionsCollection,
        queries: [
          Query.or([
            Query.equal('senderId', userId),
            Query.equal('receiverId', userId),
          ]),
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );
      return res.documents.map((d) => TransactionModel.fromMap(d.data)).toList();
    } catch (e) {
      debugPrint('Lỗi lấy lịch sử giao dịch: $e');
      return [];
    }
  }
}
