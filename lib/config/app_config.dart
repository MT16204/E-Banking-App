/// Local: chạy lệnh trong Makefile hoặc xem .env.example.
/// CI/CD: giá trị được inject từ GitHub Actions Secrets.
class AppConfig {
  AppConfig._();

  // ─── Appwrite Core ───────────────────────────────────────────
  static const String appwriteEndpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: '',
  );
  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '',
  );

  // ─── Database ────────────────────────────────────────────────
  static const String databaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: '',
  );

  // ─── Collections ─────────────────────────────────────────────
  // Collection names không nhạy cảm → hardcode là ổn.
  static const String walletsCollection       = 'wallets';
  static const String transactionsCollection  = 'transactions';
  static const String notificationsCollection = 'notification';
  static const String usersCollection         = 'users';

  // ─── Functions ───────────────────────────────────────────────
  static const String resetPasswordFunctionId = String.fromEnvironment(
    'APPWRITE_RESET_PASSWORD_FUNCTION_ID',
    defaultValue: '',
  );

  // ─── Guard: báo lỗi sớm nếu quên truyền biến ────────────────
  static void validate() {
    final missing = <String>[];
    if (appwriteEndpoint.isEmpty)         missing.add('APPWRITE_ENDPOINT');
    if (appwriteProjectId.isEmpty)        missing.add('APPWRITE_PROJECT_ID');
    if (databaseId.isEmpty)               missing.add('APPWRITE_DATABASE_ID');
    if (resetPasswordFunctionId.isEmpty)  missing.add('APPWRITE_RESET_PASSWORD_FUNCTION_ID');

    if (missing.isNotEmpty) {
      throw StateError(
        '\n[AppConfig] Thiếu các biến --dart-define:\n'
        '  ${missing.join('\n  ')}\n'
        'Xem .env.example để biết cách truyền.',
      );
    }
  }
}