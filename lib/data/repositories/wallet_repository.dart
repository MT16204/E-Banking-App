import 'package:appwrite/appwrite.dart';
import 'package:banking_app/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

import '/data/models/models.dart';

class WalletRepository {
  final Databases databases;

  static const String _databaseId = AppConfig.databaseId;
  static const String _walletsCollection = AppConfig.walletsCollection;
  static const String _usersCollection = AppConfig.usersCollection;

  WalletRepository(this.databases);

  Future<Map<String, dynamic>> lookupAccountByNumber(String accountNumber) async {
    try {
      final walletResponse = await databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _walletsCollection,
        queries: [Query.equal('accountNumber', accountNumber), Query.limit(1)],
      );

      if (walletResponse.documents.isEmpty) {
        throw Exception('Không tìm thấy tài khoản');
      }

      final walletDoc = walletResponse.documents.first;
      final wallet = WalletModel.fromMap(walletDoc.data);

      final userDoc = await databases.getDocument(
        databaseId: _databaseId,
        collectionId: _usersCollection,
        documentId: wallet.userId,
      );

      final userModel = UserModel.fromMap(userDoc.data);
      return {'wallet': wallet, 'user': userModel};
    } on AppwriteException catch (e) {
      debugPrint('lookupAccount Appwrite error (${e.code}): ${e.message}');
      throw Exception('Không tìm thấy tài khoản Nova Banking');
    } catch (e) {
      debugPrint('lookupAccount error: $e');
      rethrow;
    }
  }

  Future<WalletModel?> getWalletByUserId(String userId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: _databaseId,
        collectionId: _walletsCollection,
        documentId: userId,
      );
      return WalletModel.fromMap(doc.data);
    } catch (e) {
      debugPrint('getWalletByUserId error: $e');
      return null;
    }
  }
}
