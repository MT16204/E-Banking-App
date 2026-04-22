import 'package:appwrite/appwrite.dart';
import '../models/models.dart';

class DatabaseService {
  final Databases _databases;
  static const String databaseId = '695ec15a0017be03292c'; 
  static const String transactionCollectionId = 'transactions';

  DatabaseService(this._databases);

  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: transactionCollectionId,
        queries: [
          // Lấy các giao dịch mà user là người gửi HOẶC người nhận
          Query.or([
            Query.equal('senderId', userId),
            Query.equal('receiverId', userId),
          ]),
          Query.orderDesc('createdAt'), // Sắp xếp mới nhất lên đầu
        ],
      );

      return response.documents
          .map((doc) => TransactionModel.fromMap(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}