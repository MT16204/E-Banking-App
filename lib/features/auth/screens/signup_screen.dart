import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/widgets/auth_ui.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  bool _isLoading = false;

  void _handleNext() async {
    setState(() {
      _nameError = _nameController.text.isEmpty
          ? context.tr('Vui lòng nhập họ tên', 'Please enter your full name')
          : null;
      _emailError = !_emailController.text.contains('@')
          ? context.tr('Email không hợp lệ', 'Invalid email')
          : null;
      _phoneError = _phoneController.text.length < 9
          ? context.tr('Số điện thoại không hợp lệ', 'Invalid phone number')
          : null;
    });

    if (_nameError != null || _emailError != null || _phoneError != null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = context.read<AuthRepository>();
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();

      final token = await authRepo.authService.sendEmailOTP(email);
      final userId = token.userId;

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/otp-verify',
        arguments: {
          'name': name,
          'email': email,
          'phone': '+84${_phoneController.text.trim()}',
          'userId': userId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  eyebrow: context.tr('Mở tài khoản mới', 'Open a new account'),
                  title: context.tr('ĐĂNG KÝ TÀI KHOẢN', 'CREATE ACCOUNT'),
                  chips: [
                    context.tr('Xác thực email', 'Email verification'),
                    context.tr('Thiết lập nhanh', 'Quick setup'),
                    context.tr(
                      'Dùng màu thương hiệu sẵn có',
                      'Built-in brand theme',
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AuthPanel(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'Điền thông tin để nhận mã OTP xác thực qua email.',
                          'Fill in your details to receive an OTP by email.',
                        ),
                        style: NovaFonts.body.copyWith(
                          color: NovaColors.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AuthInput(
                        controller: _nameController,
                        label: context.tr('Họ và tên', 'Full name'),
                        hint: context.tr('Nguyễn Văn A', 'John Doe'),
                        icon: LucideIcons.user,
                        errorText: _nameError,
                        onChanged: (_) => setState(() => _nameError = null),
                      ),
                      const SizedBox(height: 14),
                      AuthInput(
                        controller: _emailController,
                        label: context.tr('Email', 'Email'),
                        hint: 'you@example.com',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (_) => setState(() => _emailError = null),
                      ),
                      const SizedBox(height: 14),
                      AuthInput(
                        controller: _phoneController,
                        label: context.tr('Số điện thoại', 'Phone number'),
                        hint: context.tr(
                          'Nhập số điện thoại',
                          'Enter phone number',
                        ),
                        icon: LucideIcons.smartphone,
                        keyboardType: TextInputType.phone,
                        errorText: _phoneError,
                        onChanged: (_) => setState(() => _phoneError = null),
                        suffix: Container(
                          margin: const EdgeInsets.only(
                            right: 12,
                            top: 10,
                            bottom: 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: NovaColors.primaryGreenLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+84',
                            style: NovaFonts.body.copyWith(
                              color: NovaColors.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: NovaColors.background,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: NovaColors.primaryGreenMid),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              LucideIcons.badgeCheck,
                              size: 18,
                              color: NovaColors.primaryGreen,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr(
                                  'Sau bước này, hệ thống sẽ gửi mã OTP để xác nhận email và tiếp tục tạo mật khẩu.',
                                  'After this step, the system will send an OTP to verify your email and continue setting a password.',
                                ),
                                style: NovaFonts.body.copyWith(
                                  color: NovaColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthPrimaryButton(
                        text: context.tr('Tiếp tục', 'Continue'),
                        isLoading: _isLoading,
                        onPressed: _handleNext,
                      ),
                      const Spacer(),
                      Center(
                        child: AuthSecondaryTextButton(
                          leading: context.tr(
                            'Đã có tài khoản? ',
                            'Already have an account? ',
                          ),
                          action: context.tr('Đăng nhập', 'Sign in'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
