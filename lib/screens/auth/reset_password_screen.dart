import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_lang.dart';
import '../../theme/colors.dart';
import '../../theme/fonts.dart';
import '../../widgets/auth_ui.dart';

/// Trang Đặt Lại Mật Khẩu — sau khi OTP đã xác minh thành công.
///
/// Nhận arguments: {'email': String}
/// Điều hướng ra:  '/login' (xoá toàn bộ stack) sau khi thành công

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isObscure = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;
  late Map _args; // ← thêm

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _checkPassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$&*]'));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map; // ← thêm
  }

  Future<void> _handleSubmit() async {
    final errWeak = context.tr(
      'Mật khẩu chưa đủ mạnh. Đảm bảo đủ 8 ký tự, có chữ in hoa và ký tự đặc biệt.',
      'Password is not strong enough. Ensure 8+ characters, uppercase and special character.',
    );
    final errMismatch = context.tr(
      'Mật khẩu xác nhận không khớp.',
      'Passwords do not match.',
    );
    final errFallback = context.tr(
      'Không thể đặt lại mật khẩu. Vui lòng thử lại.',
      'Unable to reset password. Please try again.',
    );
    final repo = context.read<AuthRepository>();

    final password = _passController.text;
    final confirm = _confirmController.text;

    if (!_hasMinLength || !_hasUppercase || !_hasSpecialChar) {
      setState(() => _errorMessage = errWeak);
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = errMismatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await repo.resetPasswordWithOTP(password, _args['email'] as String);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _isLoading = false;
        _errorMessage = raw.isNotEmpty ? raw : errFallback;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthScene(
        topBar: _isSuccess ? null : const AuthTopBar(),
        child: _isSuccess ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  // ── Form đặt mật khẩu mới ─────────────────────────────────────────────────
  Widget _buildFormView() {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AuthHero(
              eyebrow: context.tr('Khôi phục tài khoản', 'Account recovery'),
              title: context.tr('Đặt lại mật khẩu', 'Reset password'),
              chips: [
                context.tr('Tối thiểu 8 ký tự', 'Minimum 8 characters'),
                context.tr('Ít nhất 1 chữ in hoa', 'At least 1 uppercase'),
                context.tr('Có ký tự đặc biệt', 'Special character required'),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthSectionTitle(
                    title: context.tr('Mật khẩu mới', 'New password'),
                    subtitle: context.tr(
                      'Thiết lập mật khẩu mới đủ mạnh để bảo vệ tài khoản của bạn.',
                      'Create a strong new password to protect your account.',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Field mật khẩu mới
                  AuthInput(
                    controller: _passController,
                    label: context.tr('Mật khẩu mới', 'New password'),
                    hint: context.tr('Nhập mật khẩu mới', 'Enter new password'),
                    icon: LucideIcons.lock,
                    obscureText: _isObscure,
                    onChanged: _checkPassword,
                    suffix: IconButton(
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                      icon: Icon(
                        _isObscure ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18,
                        color: NovaColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Checklist yêu cầu
                  _buildRequirementItem(
                    context.tr('Tối thiểu 8 ký tự', 'Minimum 8 characters'),
                    _hasMinLength,
                  ),
                  _buildRequirementItem(
                    context.tr(
                      'Ít nhất 1 chữ in hoa (A-Z)',
                      'At least 1 uppercase (A-Z)',
                    ),
                    _hasUppercase,
                  ),
                  _buildRequirementItem(
                    context.tr(
                      'Ít nhất 1 ký tự đặc biệt (!@#\$&*)',
                      'At least 1 special character (!@#\$&*)',
                    ),
                    _hasSpecialChar,
                  ),
                  const SizedBox(height: 18),

                  // Field xác nhận
                  AuthInput(
                    controller: _confirmController,
                    label: context.tr('Xác nhận mật khẩu', 'Confirm password'),
                    hint: context.tr(
                      'Nhập lại mật khẩu mới',
                      'Re-enter new password',
                    ),
                    icon: LucideIcons.lock,
                    obscureText: _isObscureConfirm,
                    suffix: IconButton(
                      onPressed: () => setState(
                        () => _isObscureConfirm = !_isObscureConfirm,
                      ),
                      icon: Icon(
                        _isObscureConfirm
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        size: 18,
                        color: NovaColors.textSecondary,
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 14,
                          color: NovaColors.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: NovaFonts.body.copyWith(
                              color: NovaColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    text: context.tr('Cập nhật mật khẩu', 'Update password'),
                    onPressed: _handleSubmit,
                    isLoading: _isLoading,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Màn hình thành công ────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 88),
        Expanded(
          child: AuthPanel(
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
              decoration: const BoxDecoration(
                color: Color(0xFFEAEFEE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
              child: Column(
                children: [
                  // Icon thành công
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: NovaColors.primaryGreenLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: NovaColors.primaryGreenMid,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      size: 52,
                      color: NovaColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.tr(
                      'Đặt lại mật khẩu thành công!',
                      'Password reset successful!',
                    ),
                    textAlign: TextAlign.center,
                    style: NovaFonts.heading.copyWith(
                      color: NovaColors.textPrimary,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr(
                      'Mật khẩu mới của bạn đã được cập nhật thành công.',
                      'Your new password has been successfully updated.',
                    ),
                    textAlign: TextAlign.center,
                    style: NovaFonts.body.copyWith(
                      color: NovaColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      'Hãy sử dụng mật khẩu mới để đăng nhập vào tài khoản Nova Banking.',
                      'Use your new password to sign in to your Nova Banking account.',
                    ),
                    textAlign: TextAlign.center,
                    style: NovaFonts.body.copyWith(
                      color: NovaColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NovaColors.background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          context.tr('Trạng thái', 'Status'),
                          context.tr('Đã cập nhật', 'Updated'),
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          context.tr('Bảo mật', 'Security'),
                          context.tr(
                            'Mật khẩu mới đã áp dụng',
                            'New password applied',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          context.tr('Bước tiếp theo', 'Next step'),
                          context.tr('Đăng nhập lại', 'Sign in again'),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NovaColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        context.tr('Về trang Đăng nhập', 'Back to Sign in'),
                        style: NovaFonts.heading.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? LucideIcons.badgeCheck : LucideIcons.circle,
            color: isMet ? NovaColors.primaryGreen : NovaColors.primaryGreenMid,
            size: isMet ? 16 : 12,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: NovaFonts.body.copyWith(
              color: isMet ? NovaColors.textPrimary : NovaColors.textSecondary,
              fontSize: 13,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: NovaFonts.body.copyWith(
              color: NovaColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: NovaFonts.body.copyWith(
            color: NovaColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
