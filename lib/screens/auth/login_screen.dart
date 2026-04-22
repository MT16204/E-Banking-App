import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../l10n/app_lang.dart';
import '../../main.dart';
import '../../providers/user_provider.dart';
import '../../theme/colors.dart';
import '../../theme/fonts.dart';
import '../../widgets/auth_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _isObscure = true;

  late final AuthRepository _authRepo = authRepository;

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    final isValid =
        email.isNotEmpty &&
        RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);

    if (!isValid) {
      setState(
        () => _emailError = context.tr(
          'Vui lòng nhập email hợp lệ trước khi khôi phục mật khẩu.',
          'Please enter a valid email before recovering your password.',
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/forgot-password',
      arguments: {'email': email},
    );
  }

  void _handleSignIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(
        () => _emailError = context.tr(
          'Vui lòng nhập email',
          'Please enter your email',
        ),
      );
    } else if (!RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(email)) {
      setState(
        () => _emailError = context.tr(
          'Định dạng email không hợp lệ',
          'Invalid email format',
        ),
      );
    }

    if (password.isEmpty) {
      setState(
        () => _passwordError = context.tr(
          'Vui lòng nhập mật khẩu',
          'Please enter your password',
        ),
      );
    } else if (password.length < 8) {
      setState(
        () => _passwordError = context.tr(
          'Mật khẩu phải có ít nhất 8 ký tự',
          'Password must be at least 8 characters',
        ),
      );
    }

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    try {
      await _authRepo.signIn(email: email, password: password);

      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      await userProvider.fetchUser(account);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        if (errorMsg.contains('không tồn tại') ||
            errorMsg.contains('does not exist')) {
          _emailError = errorMsg;
        } else {
          _passwordError = errorMsg;
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthScene(
        topBar: const AuthTopBar(showBack: false),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AuthHero(
                  eyebrow: 'Nova Banking',
                  title: context.tr('ĐĂNG NHẬP', 'SIGN IN'),
                  chips: [
                    context.tr('Bảo mật nhiều lớp', 'Multi-layer security'),
                    context.tr('Đăng nhập nhanh', 'Fast sign in'),
                    context.tr('Theo dõi giao dịch', 'Track transactions'),
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
                      AuthSectionTitle(
                        title: context.tr('Xin chào', 'Welcome back'),
                        subtitle: context.tr(
                          'Nhập thông tin tài khoản để tiếp tục sử dụng Nova Banking.',
                          'Enter your account details to continue using Nova Banking.',
                        ),
                      ),
                      const SizedBox(height: 18),
                      AuthInput(
                        controller: _emailController,
                        label: context.tr('Email', 'Email'),
                        hint: 'you@example.com',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (_) => setState(() => _emailError = null),
                      ),
                      const SizedBox(height: 16),
                      AuthInput(
                        controller: _passwordController,
                        label: context.tr('Mật khẩu', 'Password'),
                        hint: context.tr(
                          'Nhập mật khẩu của bạn',
                          'Enter your password',
                        ),
                        icon: LucideIcons.lock,
                        obscureText: _isObscure,
                        errorText: _passwordError,
                        onChanged: (_) => setState(() => _passwordError = null),
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                          icon: Icon(
                            _isObscure ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: t.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: _handleForgotPassword,
                            child: Text(
                              context.tr('Quên mật khẩu?', 'Forgot password?'),
                              style: NovaFonts.body.copyWith(
                                color: NovaColors.primaryGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AuthPrimaryButton(
                        text: context.tr('Đăng nhập', 'Sign in'),
                        isLoading: _isLoading,
                        onPressed: _handleSignIn,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: AuthSecondaryTextButton(
                          leading: context.tr(
                            'Chưa có tài khoản? ',
                            "Don't have an account? ",
                          ),
                          action: context.tr('Đăng ký', 'Sign up'),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
