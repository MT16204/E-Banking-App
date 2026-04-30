import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/widgets/auth_ui.dart';

/// Trang Nhập OTP cho luồng quên mật khẩu.
/// Layout giống OTPScreen (otp_screen.dart).
///
/// Nhận arguments: {'userId': String, 'email': String}
/// Điều hướng ra:  '/reset-password' với {'userId': String, 'email': String}

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;
  bool _isResending = false;
  String? _otpError;

  late Map _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    // Resolve TẤT CẢ context.tr trước return/await
    final errInvalid = context.tr(
      'Mã OTP không đúng. Vui lòng kiểm tra lại.',
      'Incorrect OTP. Please check again.',
    );
    final errExpired = context.tr(
      'Mã OTP đã hết hạn. Vui lòng gửi lại.',
      'OTP has expired. Please resend.',
    );
    final repo = context.read<AuthRepository>();

    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) return;

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      final verifiedUserId = await repo.verifyResetOTP(
        _args['userId'] as String,
        otp,
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/reset-password',
        arguments: {'userId': verifiedUserId, 'email': _args['email']},
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().replaceAll('Exception: ', '');
      String message;
      if (raw.contains('không đúng') || raw.contains('invalid')) {
        message = errInvalid;
      } else if (raw.contains('hết hạn') || raw.contains('expired')) {
        message = errExpired;
      } else {
        message = raw;
      }
      setState(() => _otpError = message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    // Resolve TẤT CẢ context.tr và context.read trước await
    final errMsg = context.tr(
      'Không thể gửi lại mã. Vui lòng thử lại.',
      'Could not resend code. Please try again.',
    );
    final successMsg = context.tr('Đã gửi lại mã OTP.', 'OTP code resent.');
    final repo = context.read<AuthRepository>();

    if (_isResending) return;
    final email = _args['email'] as String;

    setState(() => _isResending = true);
    try {
      final userId = await repo.sendPasswordResetOTP(email);
      if (!mounted) return;
      // Cập nhật userId mới
      _args = {..._args, 'userId': userId};
      // Xoá các ô OTP
      for (final c in _controllers) {
        c.clear();
      }
      setState(() => _otpError = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successMsg,
            style: NovaFonts.body.copyWith(color: Colors.white),
          ),
          backgroundColor: NovaColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errMsg,
            style: NovaFonts.body.copyWith(color: Colors.white),
          ),
          backgroundColor: NovaColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _args['email'] ?? context.tr('người dùng', 'user');

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
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      context.tr(
                        'Nhập mã 6 chữ số đã được gửi đến email của bạn.',
                        'Enter the 6-digit code sent to your email.',
                      ),
                      style: NovaFonts.body.copyWith(
                        color: NovaColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── 6 ô OTP ─────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) => _buildOTPBox(i)),
                    ),
                    // Error message
                    if (_otpError != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 14,
                            color: NovaColors.error,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _otpError!,
                              style: NovaFonts.body.copyWith(
                                color: NovaColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      text: context.tr('Xác nhận', 'Confirm'),
                      onPressed: _verifyOTP,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    // Gửi lại OTP
                    Center(
                      child: GestureDetector(
                        onTap: _isResending ? null : _resendOTP,
                        child: _isResending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: NovaColors.primaryGreen,
                                ),
                              )
                            : Text(
                                context.tr('Gửi lại mã OTP', 'Resend OTP'),
                                style: NovaFonts.body.copyWith(
                                  color: NovaColors.primaryGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: NovaColors.error, width: 1.2),
          ),
        ),
        onChanged: (value) {
          setState(() => _otpError = null);
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
