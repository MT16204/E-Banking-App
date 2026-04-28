import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:banking_app/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class NotificationRepository {
  final Databases databases;

  static const String _databaseId = AppConfig.databaseId;
  static const String _notificationsCollection =
      AppConfig.notificationsCollection;

  NotificationRepository(this.databases);

  Future<void> createTransferNotification({
    required String recipientUserId,
    required String senderAccountNumber,
    required double amount,
    required String note,
  }) async {
    final formattedAmount = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );

    final params = jsonEncode({
      'amount': formattedAmount,
      'senderAccount': senderAccountNumber,
      'note': note,
    });

    await databases.createDocument(
      databaseId: _databaseId,
      collectionId: _notificationsCollection,
      documentId: ID.unique(),
      data: {
        'userId': recipientUserId,
        'title': 'Nhận tiền thành công',
        'content':
            'Bạn vừa nhận $formattedAmount VND từ TK $senderAccountNumber.'
            '${note.isNotEmpty ? ' Nội dung: $note' : ''}',
        'params': params,
        'type': 'transfer',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      final res = await databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _notificationsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
          Query.limit(20),
        ],
      );
      return res.documents
          .map((d) => NotificationModel.fromMap(d.data))
          .toList();
    } catch (e) {
      debugPrint('Lỗi lấy thông báo: $e');
      return [];
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _notificationsCollection,
        documentId: notificationId,
      );
    } catch (e) {
      debugPrint('Lỗi xóa thông báo: $e');
      rethrow;
    }
  }
}
