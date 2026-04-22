import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_lang.dart';
import '../../theme/colors.dart';
import '../../theme/fonts.dart';
import '../../widgets/auth_ui.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  void _verifyOTP() async {
    final otpCode = _controllers.map((e) => e.text).join();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String userId = args['userId'];

    if (otpCode.length != 6) return;

    setState(() => _isLoading = true);
    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.authService.account.createSession(
        userId: userId,
        secret: otpCode,
      );

      if (!mounted) return;
      Navigator.pushNamed(context, '/create-password', arguments: args);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Mã OTP không hợp lệ hoặc đã hết hạn',
              'Invalid or expired OTP code',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
    final email = args['email'] ?? context.tr('người dùng', 'user');

    return AuthScene(
      topBar: const AuthTopBar(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AuthHero(
                eyebrow: context.tr('Xác thực OTP', 'OTP Verification'),
                title: context.tr('Xác minh email', 'Verify email'),
                subtitle: email,
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AuthPanel(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _buildOTPBox(index)),
                    ),
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      text: context.tr('Xác nhận', 'Confirm'),
                      onPressed: _verifyOTP,
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
    );
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 46,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        cursorColor: NovaColors.primaryGreen,
        style: NovaFonts.heading.copyWith(
          fontSize: 22,
          color: NovaColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.72),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: NovaColors.primaryGreenMid),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: NovaColors.primaryGreen,
              width: 1.4,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}
