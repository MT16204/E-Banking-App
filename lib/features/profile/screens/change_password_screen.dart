import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/widgets/header.dart';

// =============================================================================
// ChangePasswordScreen
// Route: '/change-password'
// Luồng: intro → bước 1 (xác minh pass cũ) → bước 2 (nhập + xác nhận pass mới) → done
// =============================================================================

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  _Step _step = _Step.intro;
  String? _currentPassword;

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Header.withTitle(
              title: context.tr('Đổi mật khẩu', 'Change password'),
            ),
            if (_step != _Step.intro && _step != _Step.done)
              _StepIndicator(step: _step),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _Step.intro:
        return _IntroView(
          onProceed: () => setState(() => _step = _Step.current),
        );
      case _Step.current:
        return _CurrentPasswordPage(onSubmit: _handleVerifyCurrent);
      case _Step.newPass:
        return _NewPasswordPage(
          currentPassword: _currentPassword!,
          onSubmit: _handleUpdatePassword,
        );
      case _Step.done:
        return _DoneView(onBack: () => Navigator.pop(context));
    }
  }

  Future<String?> _handleVerifyCurrent(String password) async {
    try {
      await context.read<AuthRepository>().authService.account.updatePassword(
        password: password,
        oldPassword: password,
      );
      _currentPassword = password;
      if (!mounted) return null;
      setState(() => _step = _Step.newPass);
      return null;
    } catch (_) {
      return context.tr(
        'Mật khẩu hiện tại không chính xác.',
        'Current password is incorrect.',
      );
    }
  }

  Future<String?> _handleUpdatePassword(String newPassword) async {
    try {
      await context.read<AuthRepository>().authService.account.updatePassword(
        password: newPassword,
        oldPassword: _currentPassword!,
      );
      if (!mounted) return null;
      setState(() => _step = _Step.done);
      return null;
    } catch (e) {
      return e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AppwriteException: ', '');
    }
  }
}

// =============================================================================
// Step indicator — 2 bước
// =============================================================================
class _StepIndicator extends StatelessWidget {
  final _Step step;
  const _StepIndicator({required this.step});

  int get _current => step == _Step.current ? 0 : 1;

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    const total = 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(total, (i) {
          final active = i == _current;
          final done = i < _current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active ? t.primary : t.primaryMid,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < total - 1) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// Intro view
// =============================================================================
class _IntroView extends StatelessWidget {
  final VoidCallback onProceed;
  const _IntroView({required this.onProceed});

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: NovaColors.primaryGreenLight,
                ),
              ),
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primary.withValues(alpha: 0.08),
                  border: Border.all(color: t.primaryMid, width: 1.5),
                ),
              ),
              Container(
                width: 88,
                height: 100,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: t.primary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.lock, size: 18, color: t.primary),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 52,
                      height: 6,
                      decoration: BoxDecoration(
                        color: t.primaryMid,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 36,
                      height: 6,
                      decoration: BoxDecoration(
                        color: t.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 26,
                right: 26,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: t.primary,
                    shape: BoxShape.circle,
                    boxShadow: [t.primaryShadow],
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              Positioned(
                bottom: 28,
                left: 26,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.primaryMid),
                    boxShadow: [t.cardShadow],
                  ),
                  child: Icon(LucideIcons.keyRound, color: t.primary, size: 15),
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
          Text(
            context.tr('Đổi mật khẩu', 'Change password'),
            style: NovaFonts.heading.copyWith(
              fontSize: 22,
              color: t.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
              'Bảo vệ tài khoản bằng cách thay đổi mật khẩu định kỳ. Mật khẩu mạnh giúp giao dịch an toàn hơn.',
              'Protect your account by changing your password regularly. A strong password keeps your transactions safe.',
            ),
            style: NovaFonts.body.copyWith(
              fontSize: 14,
              color: t.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip(
                context,
                LucideIcons.shieldCheck,
                'Bảo mật cao',
                'High security',
              ),
              const SizedBox(width: 8),
              _chip(context, LucideIcons.zap, 'Nhanh chóng', 'Quick'),
              const SizedBox(width: 8),
              _chip(context, LucideIcons.lock, 'Mã hoá', 'Encrypted'),
            ],
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                context.tr('Bắt đầu', 'Get started'),
                style: NovaFonts.heading.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String vi, String en) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: NovaTheme.watch(context).primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NovaTheme.watch(context).primaryMid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: NovaTheme.watch(context).primary),
            const SizedBox(width: 5),
            Text(
              context.tr(vi, en),
              style: NovaFonts.body.copyWith(
                fontSize: 11,
                color: NovaTheme.watch(context).primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

// =============================================================================
// Bước 1 — Xác minh mật khẩu hiện tại
// =============================================================================
class _CurrentPasswordPage extends StatefulWidget {
  final Future<String?> Function(String password) onSubmit;
  const _CurrentPasswordPage({required this.onSubmit});

  @override
  State<_CurrentPasswordPage> createState() => _CurrentPasswordPageState();
}

class _CurrentPasswordPageState extends State<_CurrentPasswordPage> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text;
    if (value.isEmpty) {
      setState(
        () => _error = context.tr(
          'Vui lòng nhập mật khẩu.',
          'Please enter your password.',
        ),
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await widget.onSubmit(value);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepBadge(context, context.tr('Bước 1 / 2', 'Step 1 / 2')),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: t.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.keyRound, size: 28, color: t.primary),
            ),
            const SizedBox(height: 18),
            Text(
              context.tr('Mật khẩu hiện tại', 'Current password'),
              style: NovaFonts.heading.copyWith(
                fontSize: 22,
                color: t.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Nhập mật khẩu đăng nhập hiện tại của bạn để xác minh danh tính.',
                'Enter your current login password to verify your identity.',
              ),
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: t.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            _buildInput(
              context: context,
              controller: _controller,
              hint: context.tr('Mật khẩu hiện tại', 'Current password'),
              obscure: _obscure,
              hasError: _error != null,
              onToggle: () => setState(() => _obscure = !_obscure),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _errorRow(context, _error!),
            ],
            const SizedBox(height: 36),
            _submitButton(
              context: context,
              label: context.tr('Tiếp theo', 'Next'),
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Bước 2 — Nhập mật khẩu mới + xác nhận trong cùng 1 trang
// =============================================================================
class _NewPasswordPage extends StatefulWidget {
  final String currentPassword;
  final Future<String?> Function(String newPassword) onSubmit;

  const _NewPasswordPage({
    required this.currentPassword,
    required this.onSubmit,
  });

  @override
  State<_NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<_NewPasswordPage> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _newError;
  String? _confirmError;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;

  void _checkStrength(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$&*]'));
    });
  }

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPass = _newCtrl.text;
    final confirmPass = _confirmCtrl.text;

    String? newErr;
    String? confirmErr;

    if (newPass.isEmpty) {
      newErr = context.tr(
        'Vui lòng nhập mật khẩu mới.',
        'Please enter a new password.',
      );
    } else if (newPass.length < 8) {
      newErr = context.tr(
        'Mật khẩu phải có ít nhất 8 ký tự.',
        'Password must be at least 8 characters.',
      );
    } else if (!newPass.contains(RegExp(r'[A-Z]'))) {
      newErr = context.tr(
        'Mật khẩu phải có ít nhất 1 chữ in hoa.',
        'Password must contain at least one uppercase letter.',
      );
    } else if (!newPass.contains(RegExp(r'[!@#$&*]'))) {
      newErr = context.tr(
        'Mật khẩu phải có ít nhất 1 ký tự đặc biệt (!@#\$&*).',
        'Password must contain at least one special character (!@#\$&*).',
      );
    } else if (newPass == widget.currentPassword) {
      newErr = context.tr(
        'Mật khẩu mới phải khác mật khẩu hiện tại.',
        'New password must differ from current password.',
      );
    }

    if (confirmPass.isEmpty) {
      confirmErr = context.tr(
        'Vui lòng xác nhận mật khẩu mới.',
        'Please confirm your new password.',
      );
    } else if (confirmPass != newPass) {
      confirmErr = context.tr(
        'Mật khẩu xác nhận không khớp.',
        'Passwords do not match.',
      );
    }

    setState(() {
      _newError = newErr;
      _confirmError = confirmErr;
    });
    if (newErr != null || confirmErr != null) return;

    setState(() => _loading = true);
    final error = await widget.onSubmit(newPass);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _newError = error;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepBadge(context, context.tr('Bước 2 / 2', 'Step 2 / 2')),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: t.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.lock, size: 28, color: t.primary),
            ),
            const SizedBox(height: 18),
            Text(
              context.tr('Mật khẩu mới', 'New password'),
              style: NovaFonts.heading.copyWith(
                fontSize: 22,
                color: t.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Nhập mật khẩu mới và xác nhận lại bên dưới.',
                'Enter your new password and confirm it below.',
              ),
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: t.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // ── Field mật khẩu mới ─────────────────────────────────────────
            Text(
              context.tr('Mật khẩu mới', 'New password'),
              style: NovaFonts.body.copyWith(
                fontSize: 12,
                color: t.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            _buildInput(
              context: context,
              controller: _newCtrl,
              hint: context.tr('Nhập mật khẩu mới', 'Enter new password'),
              obscure: _obscureNew,
              hasError: _newError != null,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              onChanged: _checkStrength,
            ),
            if (_newError != null) ...[
              const SizedBox(height: 8),
              _errorRow(context, _newError!),
            ],

            // Checklist độ mạnh
            const SizedBox(height: 14),
            _requirementItem(
              context,
              context.tr('Tối thiểu 8 ký tự', 'At least 8 characters'),
              _hasMinLength,
            ),
            const SizedBox(height: 6),
            _requirementItem(
              context,
              context.tr('Ít nhất 1 chữ in hoa', 'At least 1 uppercase letter'),
              _hasUppercase,
            ),
            const SizedBox(height: 6),
            _requirementItem(
              context,
              context.tr(
                'Ít nhất 1 ký tự đặc biệt (!@#\$&*)',
                'At least 1 special character (!@#\$&*)',
              ),
              _hasSpecialChar,
            ),

            const SizedBox(height: 22),

            // ── Field xác nhận ─────────────────────────────────────────────
            Text(
              context.tr('Xác nhận mật khẩu mới', 'Confirm new password'),
              style: NovaFonts.body.copyWith(
                fontSize: 12,
                color: t.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            _buildInput(
              context: context,
              controller: _confirmCtrl,
              hint: context.tr(
                'Nhập lại mật khẩu mới',
                'Re-enter new password',
              ),
              obscure: _obscureConfirm,
              hasError: _confirmError != null,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              onSubmitted: (_) => _submit(),
            ),
            if (_confirmError != null) ...[
              const SizedBox(height: 8),
              _errorRow(context, _confirmError!),
            ],

            const SizedBox(height: 36),
            _submitButton(
              context: context,
              label: context.tr('Cập nhật mật khẩu', 'Update password'),
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Done view
// =============================================================================
class _DoneView extends StatelessWidget {
  final VoidCallback onBack;
  const _DoneView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primaryLight,
                ),
              ),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primary.withValues(alpha: 0.15),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primary,
                ),
                child: const Icon(
                  LucideIcons.checkCircle2,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(flex: 1),
          Text(
            context.tr('Đổi mật khẩu thành công!', 'Password changed!'),
            style: NovaFonts.heading.copyWith(
              fontSize: 24,
              color: t.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
              'Mật khẩu mới đã được cập nhật. Lần đăng nhập tiếp theo hãy dùng mật khẩu mới.',
              'Your new password has been updated. Use it the next time you log in.',
            ),
            style: NovaFonts.body.copyWith(
              fontSize: 14,
              color: t.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.primaryMid),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: t.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr(
                      'Không chia sẻ mật khẩu với bất kỳ ai kể cả nhân viên ngân hàng.',
                      'Do not share your password with anyone, including bank staff.',
                    ),
                    style: NovaFonts.body.copyWith(
                      fontSize: 13,
                      color: t.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                context.tr('Hoàn thành', 'Done'),
                style: NovaFonts.heading.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared helpers (top-level functions để dùng trong các widget class khác nhau)
// =============================================================================

Widget _stepBadge(BuildContext context, String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: NovaTheme.watch(context).primaryLight,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: NovaTheme.watch(context).primaryMid),
  ),
  child: Text(
    label,
    style: NovaFonts.body.copyWith(
      fontSize: 12,
      color: NovaTheme.watch(context).primary,
      fontWeight: FontWeight.w700,
    ),
  ),
);

Widget _buildInput({
  required BuildContext context,
  required TextEditingController controller,
  required String hint,
  required bool obscure,
  required bool hasError,
  required VoidCallback onToggle,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
}) => Container(
  decoration: BoxDecoration(
    color: NovaTheme.watch(context).surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: hasError ? NovaColors.error : NovaTheme.watch(context).primaryMid,
      width: hasError ? 1.2 : 1,
    ),
    boxShadow: [NovaTheme.watch(context).cardShadow],
  ),
  child: TextField(
    controller: controller,
    obscureText: obscure,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    cursorColor: NovaTheme.watch(context).primary,
    style: NovaFonts.body.copyWith(
      color: NovaTheme.watch(context).textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: NovaFonts.body.copyWith(
        color: NovaColors.textSecondary.withValues(alpha: 0.7),
        // keep secondary text dynamic
        fontSize: 14,
      ),
      prefixIcon: Icon(
        LucideIcons.lock,
        size: 18,
        color: NovaTheme.watch(context).primary,
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? LucideIcons.eyeOff : LucideIcons.eye,
          size: 18,
          color: NovaTheme.watch(context).textSecondary,
        ),
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
  ),
);

Widget _errorRow(BuildContext context, String message) => Row(
  children: [
    const Icon(Icons.error_outline, size: 14, color: NovaColors.error),
    const SizedBox(width: 6),
    Expanded(
      child: Text(
        message,
        style: NovaFonts.body.copyWith(fontSize: 12, color: NovaColors.error),
      ),
    ),
  ],
);

Widget _requirementItem(BuildContext context, String text, bool isMet) => Row(
  children: [
    Icon(
      isMet ? LucideIcons.badgeCheck : LucideIcons.circle,
      color: isMet
          ? NovaTheme.watch(context).primary
          : NovaTheme.watch(context).primaryMid,
      size: isMet ? 16 : 12,
    ),
    const SizedBox(width: 10),
    Text(
      text,
      style: NovaFonts.body.copyWith(
        color: isMet
            ? NovaTheme.watch(context).textPrimary
            : NovaTheme.watch(context).textSecondary,
        fontSize: 13,
        fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  ],
);

Widget _submitButton({
  required BuildContext context,
  required String label,
  required bool loading,
  required VoidCallback onPressed,
}) => SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: loading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: NovaTheme.watch(context).primary,
      disabledBackgroundColor: NovaTheme.watch(
        context,
      ).primary.withValues(alpha: 0.4),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    child: loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        : Text(
            label,
            style: NovaFonts.heading.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
  ),
);

enum _Step { intro, current, newPass, done }
