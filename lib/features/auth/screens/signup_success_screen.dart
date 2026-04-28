import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/widgets/auth_ui.dart';

class SignupSuccessScreen extends StatefulWidget {
  const SignupSuccessScreen({super.key});

  @override
  State<SignupSuccessScreen> createState() => _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends State<SignupSuccessScreen> {
  late final VideoPlayerController _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/success.mp4')
      ..setLooping(false)
      ..initialize().then((_) {
        if (!mounted) return;
        _videoController.play();
        setState(() => _videoReady = true);
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
    final name = args['name'] ?? context.tr('Khách hàng', 'Customer');
    final email = args['email'] ?? '';

    return AuthScene(
      child: Column(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: _videoReady
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController.value.size.width,
                                  height: _videoController.value.size.height,
                                  child: VideoPlayer(_videoController),
                                ),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: NovaColors.primaryGreen,
                                  strokeWidth: 2.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('Đăng ký thành công', 'Sign up successful'),
                      textAlign: TextAlign.center,
                      style: NovaFonts.heading.copyWith(
                        color: NovaColors.textPrimary,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr(
                        'Chào mừng $name đến với Nova Banking.',
                        'Welcome $name to Nova Banking.',
                      ),
                      textAlign: TextAlign.center,
                      style: NovaFonts.body.copyWith(
                        color: NovaColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        'Tài khoản ${email.isEmpty ? 'của bạn' : email} đã sẵn sàng để đăng nhập và bắt đầu sử dụng.',
                        'Account ${email.isEmpty ? 'yours' : email} is ready for sign in and use.',
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
                            context.tr('Đã kích hoạt', 'Activated'),
                          ),
                          const SizedBox(height: 10),
                          _infoRow(
                            context.tr('Xác thực email', 'Email verification'),
                            context.tr('Hoàn tất', 'Completed'),
                          ),
                          const SizedBox(height: 10),
                          _infoRow(
                            context.tr('Bước tiếp theo', 'Next step'),
                            context.tr(
                              'Đăng nhập vào ứng dụng',
                              'Sign in to the app',
                            ),
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
