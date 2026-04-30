import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/providers/language_provider.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'package:banking_app/widgets/appearance_sheets.dart';
import 'package:banking_app/widgets/header.dart';
import 'package:banking_app/widgets/profile_avatar_section.dart';
import 'package:banking_app/widgets/profile_settings_section.dart';
import 'package:banking_app/widgets/profile_wallet_badge.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  const ProfileScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final userProvider = context.watch<UserProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final isVietnamese = languageProvider.isVietnamese;
    final user = userProvider.user;
    final wallet = userProvider.wallet;

    return Scaffold(
      backgroundColor: theme.background,
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primary))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Header ──────────────
                    Header.iconOnly(
                      onBack: onBackToHome,
                      action: GestureDetector(
                        onTap: () => _handleLogout(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.logOut,
                                color: Colors.redAccent,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isVietnamese ? 'Thoát' : 'Logout',
                                style: NovaFonts.body.copyWith(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Avatar + name ────────────────────────────────────────
                    ProfileAvatarSection(
                      greeting: isVietnamese ? 'Xin chào 👋' : 'Hello 👋',
                      displayName: user?.name ??
                          (isVietnamese ? 'Người dùng' : 'User'),
                      displayEmail: user?.email ?? '',
                      onTap: () => showAvatarSheet(context),
                    ),

                    const SizedBox(height: 20),

                    // ── Wallet badge ─────────────────────────────────────────
                    ProfileWalletBadge(
                      title: isVietnamese
                          ? 'Tài khoản chính'
                          : 'Main account',
                      accountNumber: wallet?.accountNumber ?? '****',
                      balanceLabel: isVietnamese ? 'Số dư' : 'Balance',
                      balanceValue: '${_formatBalance(wallet?.balance)} VND',
                    ),

                    const SizedBox(height: 24),

                    ProfileSettingsSection(
                      title: isVietnamese
                          ? 'Cài đặt cá nhân'
                          : 'Personal settings',
                      items: [
                        ProfileSettingsItem(
                          LucideIcons.user,
                          isVietnamese ? 'Đổi ảnh đại diện' : 'Change avatar',
                          onTap: () => showAvatarSheet(context),
                        ),
                        ProfileSettingsItem(
                          LucideIcons.sparkles,
                          isVietnamese ? 'Đổi giao diện' : 'Change theme',
                          onTap: () => showThemeSheet(context),
                        ),
                        ProfileSettingsItem(
                          LucideIcons.image,
                          isVietnamese ? 'Đổi ảnh nền' : 'Change background',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/background-picker',
                          ),
                        ),
                        ProfileSettingsItem(
                          LucideIcons.languages,
                          isVietnamese ? 'Ngôn ngữ' : 'Language',
                          trailing: _langTag(context),
                          onTap: () => _showLanguageSheet(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ProfileSettingsSection(
                      title: isVietnamese ? 'An toàn – Bảo mật' : 'Security',
                      items: [
                        ProfileSettingsItem(
                          LucideIcons.shieldCheck,
                          isVietnamese ? 'Sinh trắc học' : 'Biometrics',
                          onTap: () => _showDevelopmentSheet(
                            context,
                            title: isVietnamese
                                ? 'Sinh trắc học'
                                : 'Biometrics',
                            icon: LucideIcons.shieldCheck,
                          ),
                        ),
                        ProfileSettingsItem(
                          LucideIcons.scanFace,
                          isVietnamese ? 'Cài đặt FaceID' : 'Face ID setup',
                          onTap: () => _showDevelopmentSheet(
                            context,
                            title: isVietnamese
                                ? 'Cài đặt FaceID'
                                : 'Face ID setup',
                            icon: LucideIcons.scanFace,
                          ),
                        ),
                        ProfileSettingsItem(
                          LucideIcons.wrench,
                          'Smart OTP',
                          onTap: () =>
                              Navigator.pushNamed(context, '/smart_otp'),
                        ),
                        ProfileSettingsItem(
                          LucideIcons.lock,
                          isVietnamese ? 'Đổi mật khẩu' : 'Change password',
                          onTap: () =>
                              Navigator.pushNamed(context, '/change-password'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatBalance(double? balance) {
    return balance != null
        ? balance
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]}.',
              )
        : '---';
  }

  Widget _langTag(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().code;
    final theme = NovaTheme.watch(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primaryMid, width: 1),
      ),
      child: Text(
        languageCode,
        style: NovaFonts.body.copyWith(
          fontSize: 11,
          color: theme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final isVietnamese = context.read<LanguageProvider>().isVietnamese;
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (dialogContext) {
        final theme = NovaTheme.watch(dialogContext);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.primaryMid,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.logOut,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  isVietnamese ? 'Đăng xuất' : 'Logout',
                  textAlign: TextAlign.center,
                  style: NovaFonts.heading.copyWith(
                    color: theme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isVietnamese
                      ? 'Bạn có chắc chắn muốn thoát khỏi tài khoản này không?'
                      : 'Are you sure you want to sign out of this account?',
                  textAlign: TextAlign.center,
                  style: NovaFonts.body.copyWith(
                    color: theme.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      isVietnamese ? 'Đăng xuất' : 'Logout',
                      style: NovaFonts.body.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isVietnamese ? 'Hủy' : 'Cancel',
                      style: NovaFonts.body.copyWith(
                        color: theme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    try {
      await context.read<AuthRepository>().signOut();
      if (context.mounted) {
        context.read<UserProvider>().clearUser();
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      debugPrint('Logout Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVietnamese
                  ? 'Không thể đăng xuất. Vui lòng thử lại.'
                  : 'Unable to sign out. Please try again.',
              style: NovaFonts.body.copyWith(color: Colors.white),
            ),
            backgroundColor: NovaColors.textPrimary,
          ),
        );
      }
    }
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
    final languageProvider = context.read<LanguageProvider>();
    final isVietnamese = languageProvider.isVietnamese;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = NovaTheme.watch(sheetContext);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.primaryMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.languages,
                  size: 28,
                  color: theme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isVietnamese ? 'Chọn ngôn ngữ' : 'Choose language',
                style: NovaFonts.heading.copyWith(
                  fontSize: 18,
                  color: theme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isVietnamese
                    ? 'Bạn có thể chuyển đổi ngôn ngữ hiển thị của ứng dụng.'
                    : 'You can switch the app display language.',
                style: NovaFonts.body.copyWith(
                  color: theme.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                context: sheetContext,
                label: 'Tiếng Việt',
                value: AppLanguage.vi,
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context: sheetContext,
                label: 'English',
                value: AppLanguage.en,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required AppLanguage value,
  }) {
    final languageProvider = context.watch<LanguageProvider>();
    final isSelected = languageProvider.language == value;
    final theme = NovaTheme.watch(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await context.read<LanguageProvider>().setLanguage(value);
          if (!context.mounted) return;
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryLight : theme.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? theme.primary : theme.primaryMid,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: NovaFonts.body.copyWith(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                color: isSelected ? theme.primary : theme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDevelopmentSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) async {
    final isVietnamese = context.read<LanguageProvider>().isVietnamese;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = NovaTheme.watch(sheetContext);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.primaryMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: theme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: NovaFonts.heading.copyWith(
                  fontSize: 18,
                  color: theme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock, size: 16, color: theme.primary),
                    const SizedBox(width: 8),
                    Text(
                      isVietnamese
                          ? 'Tính năng đang được phát triển'
                          : 'This feature is in development',
                      style: NovaFonts.body.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isVietnamese
                    ? 'Chúng tôi đang hoàn thiện tính năng này.\nVui lòng quay lại sau!'
                    : 'We are still working on this feature.\nPlease check back later!',
                style: NovaFonts.body.copyWith(
                  color: theme.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isVietnamese ? 'Đã hiểu' : 'Got it',
                    style: NovaFonts.heading.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
