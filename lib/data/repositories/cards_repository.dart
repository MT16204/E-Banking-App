import 'package:appwrite/appwrite.dart';
import 'package:banking_app/core/config/app_config.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class CardsRepository {
  final Databases databases;

  static const String _databaseId = AppConfig.databaseId;
  static const String _cardsCollection = 'cards';

  CardsRepository(this.databases);

  Map<String, dynamic> _docToMap(models.Document doc) => {
    '\$id': doc.$id,
    ...doc.data,
  };

  Future<List<CardModel>> fetchCards(String userId) async {
    try {
      final res = await databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _cardsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return res.documents.map((d) => CardModel.fromMap(_docToMap(d))).toList();
    } catch (e) {
      debugPrint('Lỗi lấy thẻ: $e');
      return [];
    }
  }

  Future<CardModel?> addCard({
    required String userId,
    required String cardName,
    required String cardNumber,
    required String cardType,
    String? expiryDate,
  }) async {
    try {
      final doc = await databases.createDocument(
        databaseId: _databaseId,
        collectionId: _cardsCollection,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'cardName': cardName,
          'cardNumber': cardNumber,
          'cardType': cardType,
          'status': 'active',
          if (expiryDate != null) 'expiryDate': expiryDate,
        },
      );
      return CardModel.fromMap(_docToMap(doc));
    } catch (e) {
      debugPrint('Lỗi thêm thẻ: $e');
      return null;
    }
  }

  Future<bool> deleteCard(String cardId) async {
    try {
      await databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _cardsCollection,
        documentId: cardId,
      );
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa thẻ: $e');
      return false;
    }
  }

  Future<CardModel?> toggleCardStatus(CardModel card) async {
    final newStatus = card.isActive ? 'locked' : 'active';
    try {
      await databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _cardsCollection,
        documentId: card.id,
        data: {'status': newStatus},
      );
      return CardModel.fromMap({
        ...card.toMap(),
        '\$id': card.id,
        'status': newStatus,
      });
    } catch (e) {
      debugPrint('Lỗi cập nhật trạng thái thẻ: $e');
      return null;
    }
  }
}
