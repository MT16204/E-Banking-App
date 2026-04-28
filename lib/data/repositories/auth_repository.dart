import 'package:appwrite/appwrite.dart';
import 'package:banking_app/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_services.dart';

class AuthRepository {
  final AuthService authService;
  final Databases databases;

  static const String _databaseId = AppConfig.databaseId;
  static const String _usersCollection = AppConfig.usersCollection;
  static const String _walletsCollection = AppConfig.walletsCollection;
  static const String _resetPasswordFunctionId =
      AppConfig.resetPasswordFunctionId;

  AuthRepository(this.authService, this.databases);

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
