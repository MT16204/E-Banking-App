import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const bool isDemoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: false,
  );

  static const String appwriteEndpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: '',
  );
  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '',
  );
  static const String databaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: '',
  );
  static const String walletsCollection = 'wallets';
  static const String transactionsCollection = 'transactions';
  static const String notificationsCollection = 'notification';
  static const String usersCollection = 'users';
  static const String resetPasswordFunctionId = String.fromEnvironment(
    'APPWRITE_RESET_PASSWORD_FUNCTION_ID',
    defaultValue: '',
  );

  static void validate() {
    // ✅ Bỏ qua validation khi chạy demo hoặc web
    if (isDemoMode || kIsWeb) return;

    final missing = <String>[];
    if (appwriteEndpoint.isEmpty) missing.add('APPWRITE_ENDPOINT');
    if (appwriteProjectId.isEmpty) missing.add('APPWRITE_PROJECT_ID');
    if (databaseId.isEmpty) missing.add('APPWRITE_DATABASE_ID');
    if (resetPasswordFunctionId.isEmpty) {
      missing.add('APPWRITE_RESET_PASSWORD_FUNCTION_ID');
    }
    if (missing.isNotEmpty) {
      throw StateError(
        '\n[AppConfig] Thiếu các biến --dart-define:\n'
        '  ${missing.join('\n  ')}\n'
        'Xem .env.example để biết cách truyền.',
      );
    }
  }
}
