import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/widgets/auth_ui.dart';

/// Trang Quên Mật Khẩu — xác nhận email trước khi gửi OTP.
///
/// Nhận arguments: {'email': String}  ← email đã nhập sẵn từ LoginScreen
/// Điều hướng ra:  '/reset-verify-otp' với {'userId': String, 'email': String}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  String? _emailError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['email'] != null) {
        _emailController.text = args['email'] as String;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    // Resolve TẤT CẢ context.tr trước bất kỳ return hoặc await nào
    final errEmpty = context.tr(
      'Vui lòng nhập email.',
      'Please enter your email.',
    );
    final errFormat = context.tr(
      'Định dạng email không hợp lệ.',
      'Invalid email format.',
    );
    final errFallback = context.tr(
      'Không thể gửi email. Vui lòng thử lại.',
      'Unable to send email. Please try again.',
    );
    final repo = context.read<AuthRepository>();

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = errEmpty);
      return;
    }
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = errFormat);
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      final userId = await repo.sendPasswordResetOTP(email);
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/reset-verify-otp',
        arguments: {'userId': userId, 'email': email},
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().replaceAll('Exception: ', '');
      setState(() => _emailError = raw.isNotEmpty ? raw : errFallback);
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
                  eyebrow: context.tr(
                    'Khôi phục tài khoản',
                    'Account recovery',
                  ),
                  title: context.tr('Quên mật khẩu', 'Forgot password'),
                  chips: [
                    context.tr('Xác thực qua email', 'Verify via email'),
                    context.tr('Đặt lại mật khẩu', 'Reset password'),
                    context.tr('Bảo mật tuyệt đối', 'Fully secured'),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AuthPanel(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthSectionTitle(
                        title: context.tr(
                          'Xác nhận email',
                          'Confirm your email',
                        ),
                        subtitle: context.tr(
                          'Chúng tôi sẽ gửi mã OTP đến email bên dưới để xác minh danh tính.',
                          'We will send an OTP to the email below to verify your identity.',
                        ),
                      ),
                      const SizedBox(height: 22),
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
                              LucideIcons.info,
                              size: 17,
                              color: NovaColors.primaryGreen,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr(
                                  'Mã OTP có hiệu lực trong 15 phút. Kiểm tra cả hộp thư Spam nếu không nhận được email.',
                                  'OTP is valid for 15 minutes. Check your Spam folder if you don\'t receive the email.',
                                ),
                                style: NovaFonts.body.copyWith(
                                  color: NovaColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        text: context.tr(
                          'Gửi mã xác thực',
                          'Send verification code',
                        ),
                        isLoading: _isLoading,
                        onPressed: _handleSendOTP,
                      ),
                      const Spacer(),
                      Center(
                        child: AuthSecondaryTextButton(
                          leading: context.tr(
                            'Nhớ mật khẩu rồi? ',
                            'Remember your password? ',
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
}
