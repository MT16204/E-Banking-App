import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:banking_app/config/app_config.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_services.dart';
import '/data/models/models.dart';

class AuthRepository {
  final AuthService authService;
  final Databases databases;

  // ✅ Tất cả config đọc từ AppConfig — không còn hardcode
  static const String _databaseId = AppConfig.databaseId;
  static const String _walletsCollection = AppConfig.walletsCollection;
  static const String _transactionsCollection =
      AppConfig.transactionsCollection;
  static const String _notificationsCollection =
      AppConfig.notificationsCollection;
  static const String _usersCollection = AppConfig.usersCollection;
  static const String _resetPasswordFunctionId =
      AppConfig.resetPasswordFunctionId;

  AuthRepository(this.authService, this.databases);

  // ─────────────────────────────────────────────────────────────
  // CHUYỂN TIỀN: Tra cứu tài khoản theo số tài khoản
  // ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> lookupAccountByNumber(
    String accountNumber,
  ) async {
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

  // ─────────────────────────────────────────────────────────────
  // Lấy ví theo userId
  // ─────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────
  // CHUYỂN TIỀN: Thực hiện giao dịch nội bộ
  // ─────────────────────────────────────────────────────────────
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

      final double senderNewBalance = senderWallet.balance - amount;
      final double recipientNewBalance = recipientWallet.balance + amount;

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
        await _createTransferNotification(
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

  // ─────────────────────────────────────────────────────────────
  // HELPER: Tạo thông báo cho người nhận
  // ─────────────────────────────────────────────────────────────
  Future<void> _createTransferNotification({
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

  // ─────────────────────────────────────────────────────────────
  // CÁC METHOD AUTH GIỮ NGUYÊN
  // ─────────────────────────────────────────────────────────────
  Future<void> verifyOTP(String userId, String otpCode) async {
    try {
      try {
        await authService.account.deleteSession(sessionId: 'current');
        debugPrint("Đã xóa session cũ trước khi verify.");
      } catch (_) {}
      await authService.account.createSession(userId: userId, secret: otpCode);
      debugPrint("Xác thực OTP thành công!");
    } on AppwriteException catch (e) {
      debugPrint("Lỗi Appwrite (${e.code}): ${e.message}");
      throw Exception("Lỗi: ${e.message}");
    }
  }

  Future<void> finalizePasswordAndPhone({
    required String newPassword,
    required String phone,
    required String name,
  }) async {
    try {
      final user = await authService.account.get();
      final userId = user.$id;
      await authService.account.updateName(name: name);
      await authService.account.updatePassword(password: newPassword);
      await authService.account.updatePhone(
        phone: phone,
        password: newPassword,
      );
      await databases.createDocument(
        databaseId: _databaseId,
        collectionId: _usersCollection,
        documentId: userId,
        data: {
          'userId': userId,
          'fullName': name,
          'phoneNumber': phone,
          'role': 'user',
        },
      );
      await databases.createDocument(
        databaseId: _databaseId,
        collectionId: _walletsCollection,
        documentId: userId,
        data: {
          'userId': userId,
          'accountNumber':
              (1000000000 +
                      (DateTime.now().millisecondsSinceEpoch % 9000000000))
                  .toString(),
          'balance': 0.0,
          'accountType': 'checking',
        },
      );
      debugPrint("Đã tạo User Model và Ví thành công cho: $userId");
    } catch (e) {
      debugPrint("Lỗi finalize: $e");
      throw Exception('Lỗi lưu thông tin tài khoản: $e');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      try {
        await authService.logout();
      } catch (_) {}
      await authService.login(email, password);
    } on AppwriteException catch (e) {
      debugPrint("Appwrite Error Code: ${e.code}");
      if (e.code == 404 || e.type == 'user_not_found') {
        throw Exception('Tài khoản không tồn tại trên hệ thống.');
      }
      if (e.code == 401 || e.type == 'user_invalid_credentials') {
        throw Exception('Email hoặc mật khẩu không chính xác.');
      }
      throw Exception(e.message ?? 'Lỗi đăng nhập hệ thống.');
    }
  }

  Future<String> fetchShortName() async {
    try {
      final user = await authService.account.get();
      if (user.name.isNotEmpty) {
        String lastPart = user.name.trim().split(' ').last;
        return lastPart[0].toUpperCase() + lastPart.substring(1).toLowerCase();
      }
      return "Khách hàng";
    } catch (e) {
      return "User";
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await authService.account.updatePassword(
        password: newPassword,
        oldPassword: currentPassword,
      );
    } on AppwriteException catch (e) {
      debugPrint('changePassword error (${e.code}): ${e.message}');
      if (e.code == 401 || e.type == 'user_invalid_credentials') {
        throw Exception('Mật khẩu hiện tại không chính xác.');
      }
      throw Exception(e.message ?? 'Không thể đổi mật khẩu.');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // QUÊN MẬT KHẨU
  // ─────────────────────────────────────────────────────────────

  /// Bước 1: Gửi OTP 6 số về email.
  Future<String> sendPasswordResetOTP(String email) async {
    try {
      final token = await authService.sendEmailOTP(email);
      return token.userId;
    } on AppwriteException catch (e) {
      debugPrint('sendPasswordResetOTP error (${e.code}): ${e.message}');
      if (e.code == 500) {
        throw Exception('Không thể gửi email. Vui lòng thử lại sau.');
      }
      throw Exception(e.message ?? 'Gửi mã OTP thất bại.');
    }
  }

  /// Bước 2: Xác minh OTP → tạo session.
  Future<void> verifyResetOTP(String userId, String otpCode) async {
    try {
      try {
        await authService.logout();
      } catch (_) {}
      await authService.verifyEmailOTP(userId, otpCode);
      debugPrint('[RESET] ✅ verifyEmailOTP thành công — session sẵn sàng');
    } on AppwriteException catch (e) {
      debugPrint('verifyResetOTP error (${e.code}): ${e.message}');
      if (e.code == 401 || e.type == 'user_invalid_token') {
        throw Exception('Mã OTP không đúng. Vui lòng kiểm tra lại.');
      }
      if (e.type == 'token_expired') {
        throw Exception('Mã OTP đã hết hạn. Vui lòng gửi lại.');
      }
      throw Exception(e.message ?? 'Xác thực OTP thất bại.');
    }
  }

  /// Bước 3: Đặt lại mật khẩu qua Appwrite Function.
  Future<void> resetPasswordWithOTP(String newPassword, String email) async {
    try {
      debugPrint('[RESET] ▶️ Lấy userId từ session hiện tại...');
      final user = await authService.account.get();
      debugPrint('[RESET] ✅ userId: ${user.$id}');

      debugPrint('[RESET] ▶️ Gọi Appwrite Function reset password...');
      await authService.resetPasswordViaFunction(
        functionId: _resetPasswordFunctionId,
        userId: user.$id,
        newPassword: newPassword,
      );
      debugPrint('[RESET] ✅ Reset password thành công');

      try {
        await authService.logout();
        debugPrint('[RESET] ✅ Logout thành công');
      } catch (_) {}
    } on AppwriteException catch (e) {
      debugPrint('[RESET] ❌ error (${e.code}): ${e.message}');
      throw Exception(e.message ?? 'Không thể đặt lại mật khẩu.');
    }
  }

  Future<void> signOut() async => await authService.logout();
}
