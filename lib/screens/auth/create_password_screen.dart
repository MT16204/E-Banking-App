import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_lang.dart';
import '../../theme/colors.dart';
import '../../theme/fonts.dart';
import '../../widgets/auth_ui.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool _hasUppercase = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  void _checkPassword(String value) {
    setState(() {
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$&*]'));
      _hasMinLength = value.length >= 8;
    });
  }

  void _handleSubmit() async {
    final password = _passController.text;
    final confirm = _confirmPassController.text;
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    if (!_hasUppercase || !_hasSpecialChar || !_hasMinLength) {
      setState(() => _errorMessage = context.tr('Mật khẩu chưa đủ mạnh', 'Password is not strong enough'));
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = context.tr('Mật khẩu xác nhận không khớp', 'Password confirmation does not match'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<AuthRepository>();
      await repo.finalizePasswordAndPhone(
        newPassword: password,
        phone: args['phone'],
        name: args['name'],
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signup-success',
        (route) => false,
        arguments: args,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthScene(
        topBar: const AuthTopBar(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AuthHero(
                  eyebrow: context.tr('Thiết lập bảo mật', 'Security setup'),
                  title: context.tr('Tạo mật khẩu', 'Create password'),
                  chips: [
                    context.tr('Tối thiểu 8 ký tự', 'Minimum 8 characters'),
                    context.tr('Ít nhất 1 chữ in hoa', 'At least 1 uppercase letter'),
                    context.tr('Có ký tự đặc biệt', 'Contains special character'),
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
                        title: context.tr('Mật khẩu đăng nhập', 'Login password'),
                        subtitle: context.tr(
                          'Thiết lập mật khẩu đủ mạnh để bảo vệ tài khoản và giao dịch của bạn.',
                          'Create a strong password to protect your account and transactions.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthInput(
                        controller: _passController,
                        label: context.tr('Mật khẩu mới', 'New password'),
                        hint: context.tr('Nhập mật khẩu', 'Enter password'),
                        icon: LucideIcons.lock,
                        obscureText: _isObscure,
                        onChanged: _checkPassword,
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                          icon: Icon(
                            _isObscure ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: NovaColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRequirementItem(
                        context.tr('Tối thiểu 8 ký tự', 'Minimum 8 characters'),
                        _hasMinLength,
                      ),
                      _buildRequirementItem(
                        context.tr('Ít nhất 1 chữ in hoa', 'At least 1 uppercase letter'),
                        _hasUppercase,
                      ),
                      _buildRequirementItem(
                        context.tr('Ít nhất 1 ký tự đặc biệt', 'At least 1 special character'),
                        _hasSpecialChar,
                      ),
                      const SizedBox(height: 18),
                      AuthInput(
                        controller: _confirmPassController,
                        label: context.tr('Xác nhận mật khẩu', 'Confirm password'),
                        hint: context.tr('Nhập lại mật khẩu', 'Re-enter password'),
                        icon: LucideIcons.shield,
                        obscureText: _isObscure,
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                          icon: Icon(
                            _isObscure ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: NovaColors.textSecondary,
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: NovaFonts.body.copyWith(
                            color: NovaColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        text: context.tr('Hoàn tất đăng ký', 'Complete sign up'),
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
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
}
