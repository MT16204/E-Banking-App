import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';

class AuthService {
  final Account _account;
  AuthService(this._account);

  Account get account => _account;

  // Gửi mã OTP
  Future<Token> sendEmailOTP(String email) async {
    return await _account.createEmailToken(userId: ID.unique(), email: email);
  }

  // Xác thực mã OTP
  Future<Session> verifyEmailOTP(String userId, String otpCode) async {
    return await _account.createSession(userId: userId, secret: otpCode);
  }

  Future<Session> login(String email, String password) async {
    return await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async =>
      await _account.deleteSession(sessionId: 'current');

  // Gọi Appwrite Function để reset password (server-side, không cần oldPassword)
  Future<void> resetPasswordViaFunction({
    required String functionId,
    required String userId,
    required String newPassword,
  }) async {
    final functions = Functions(_account.client);
    final result = await functions.createExecution(
      functionId: functionId,
      body: jsonEncode({'userId': userId, 'newPassword': newPassword}),
      xasync: false,
      method: ExecutionMethod.pOST,
      headers: {'content-type': 'application/json'},
    );

    final statusCode = result.responseStatusCode;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    if (!isSuccess) {
      Map<String, dynamic>? body;
      try {
        body = jsonDecode(result.responseBody) as Map<String, dynamic>;
      } catch (_) {}
      throw Exception(
        body?['error'] ??
            body?['message'] ??
            'Không thể đặt lại mật khẩu. (HTTP $statusCode)',
      );
    }
  }
}
