import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_lang.dart';
import '../theme/colors.dart';
import '../theme/fonts.dart';
import '../providers/user_provider.dart';
import '../data/services/otp_service.dart';
import '../widgets/header.dart';
import '../main.dart';

class SmartOtpScreen extends StatefulWidget {
  const SmartOtpScreen({super.key});

  @override
  State<SmartOtpScreen> createState() => _SmartOtpScreenState();
}

class _SmartOtpScreenState extends State<SmartOtpScreen> {
  _Step _step = _Step.loading;
  bool _isSetup = false;
  String _pendingPin = '';

  String get _userId => context.read<UserProvider>().user?.$id ?? '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final hasPin = await OtpService.isSetup(_userId);
    if (!mounted) return;
    setState(() {
      _isSetup = hasPin;
      _step = _Step.intro;
    });
  }

  Future<String?> _onEnterOld(String pin) async {
    final ok = await OtpService.verifyPin(_userId, pin);
    if (!mounted) return null;
    if (ok) {
      setState(() => _step = _Step.enterNew);
      return null;
    }
    return context.tr('Mã PIN không đúng', 'Incorrect PIN');
  }

  String? _onEnterNew(String pin) {
    _pendingPin = pin;
    setState(() => _step = _Step.confirmNew);
    return null;
  }

  Future<String?> _onConfirmNew(String pin) async {
    if (pin != _pendingPin) {
      _pendingPin = '';
      setState(() => _step = _Step.enterNew);
      return context.tr(
        'Hai mã PIN không khớp, vui lòng nhập lại',
        'PINs do not match, please try again',
      );
    }
    await OtpService.setupPin(_userId, pin);
    if (!mounted) return null;
    setState(() => _step = _Step.done);
    return null;
  }

  void _onForgotPin() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForgotPinSheet(
        onVerified: () {
          OtpService.clearPin(_userId).then((_) {
            if (mounted) setState(() => _step = _Step.enterNew);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Header.withTitle(title: 'Smart OTP'),

            if (_step != _Step.loading &&
                _step != _Step.intro &&
                _step != _Step.done)
              _StepIndicator(step: _step, isSetup: _isSetup),

            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _Step.loading:
        return Center(
          child: CircularProgressIndicator(
            color: NovaTheme.watch(context).primary,
          ),
        );
      case _Step.intro:
        return _IntroView(
          isSetup: _isSetup,
          onProceed: () => setState(
            () => _step = _isSetup ? _Step.enterOld : _Step.enterNew,
          ),
        );
      case _Step.enterOld:
        return _PinInputPage(
          key: const ValueKey('enterOld'),
          title: context.tr('Nhập mã PIN hiện tại', 'Enter current PIN'),
          subtitle: context.tr(
            'Xác nhận danh tính trước khi đổi mã',
            'Verify your identity before changing the PIN',
          ),
          onSubmit: _onEnterOld,
          showForgot: true,
          onForgot: _onForgotPin,
        );
      case _Step.enterNew:
        return _PinInputPage(
          key: const ValueKey('enterNew'),
          title: _isSetup
              ? context.tr('Nhập mã PIN mới', 'Enter new PIN')
              : context.tr('Tạo mã PIN', 'Create PIN'),
          subtitle: context.tr(
            'Mã PIN 6 chữ số dùng để xác nhận giao dịch',
            'A 6-digit PIN used to confirm transactions',
          ),
          onSubmit: (pin) async => _onEnterNew(pin),
        );
      case _Step.confirmNew:
        return _PinInputPage(
          key: const ValueKey('confirmNew'),
          title: context.tr('Xác nhận mã PIN', 'Confirm PIN'),
          subtitle: context.tr(
            'Nhập lại mã PIN vừa tạo',
            'Re-enter the PIN you just created',
          ),
          onSubmit: _onConfirmNew,
        );
      case _Step.done:
        return _DoneView(
          isNew: !_isSetup,
          onBack: () => Navigator.pop(context),
        );
    }
  }
}

// =============================================================================
// Step indicator
// =============================================================================
class _StepIndicator extends StatelessWidget {
  final _Step step;
  final bool isSetup;
  const _StepIndicator({required this.step, required this.isSetup});

  int get _current {
    switch (step) {
      case _Step.enterOld:
        return 0;
      case _Step.enterNew:
        return isSetup ? 1 : 0;
      case _Step.confirmNew:
        return isSetup ? 2 : 1;
      default:
        return 0;
    }
  }

  int get _total => isSetup ? 3 : 2;

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(_total, (i) {
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
                if (i < _total - 1) const SizedBox(width: 6),
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
  final bool isSetup;
  final VoidCallback onProceed;
  const _IntroView({required this.isSetup, required this.onProceed});

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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primaryLight,
                ),
              ),
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primary.withValues(alpha: 0.1),
                  border: Border.all(color: t.primaryMid, width: 1.5),
                ),
              ),
              Container(
                width: 88,
                height: 110,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: t.primary.withValues(alpha: 0.18),
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
                      child: Icon(
                        LucideIcons.shieldCheck,
                        size: 18,
                        color: t.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (i) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < 3 ? t.primary : t.primaryMid,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 52,
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
                top: 24,
                right: 24,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: t.primary,
                    shape: BoxShape.circle,
                    boxShadow: [t.primaryShadow],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
              Positioned(
                bottom: 28,
                left: 28,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.primaryMid),
                    boxShadow: [t.cardShadow],
                  ),
                  child: Icon(LucideIcons.lock, color: t.primary, size: 15),
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
          Text(
            isSetup
                ? context.tr('Quản lý Smart OTP', 'Manage Smart OTP')
                : context.tr('Tạo mã PIN Smart OTP', 'Create Smart OTP PIN'),
            style: NovaFonts.heading.copyWith(
              fontSize: 22,
              color: t.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isSetup
                ? context.tr(
                    'Mã PIN Smart OTP đã được tích hợp. Bạn có thể đổi mã PIN bất cứ lúc nào.',
                    'Smart OTP PIN is already set up. You can change it anytime.',
                  )
                : context.tr(
                    'Vui lòng tạo mã PIN để hoàn tất tích hợp Smart OTP và bảo mật giao dịch.',
                    'Create a PIN to complete Smart OTP setup and secure transactions.',
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
                LucideIcons.zap,
                'Xác nhận nhanh',
                'Confirm instantly',
              ),
              const SizedBox(width: 8),
              _chip(
                context,
                LucideIcons.shieldCheck,
                'Bảo mật cao',
                'High security',
              ),
              const SizedBox(width: 8),
              _chip(
                context,
                LucideIcons.smartphone,
                'Trên thiết bị',
                'On device',
              ),
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
                isSetup
                    ? context.tr('Đổi mã PIN', 'Change PIN')
                    : context.tr('Tạo mã PIN', 'Create PIN'),
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
// PIN Input Page
// =============================================================================
class _PinInputPage extends StatefulWidget {
  final String title, subtitle;
  final Future<String?> Function(String pin) onSubmit;
  final bool showForgot;
  final VoidCallback? onForgot;

  const _PinInputPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSubmit,
    this.showForgot = false,
    this.onForgot,
  });

  @override
  State<_PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<_PinInputPage>
    with SingleTickerProviderStateMixin {
  final List<String> _digits = List.filled(6, '');
  int _currentIndex = 0;
  bool _isObscure = true;
  bool _submitting = false;
  String? _errorMsg;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _reset() {
    _digits.fillRange(0, 6, '');
    _currentIndex = 0;
    _submitting = false;
  }

  void _onKeyTap(String key) async {
    if (_submitting) return;
    bool shouldSubmit = false;

    setState(() {
      _errorMsg = null;
      if (key == 'del') {
        if (_currentIndex > 0) {
          _currentIndex--;
          _digits[_currentIndex] = '';
        }
      } else if (_currentIndex < 6) {
        _digits[_currentIndex] = key;
        _currentIndex++;
        if (_currentIndex == 6) shouldSubmit = true;
      }
    });

    if (!shouldSubmit) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 250));

    final error = await widget.onSubmit(_digits.join());
    if (!mounted) return;

    if (error != null) {
      _shakeCtrl.forward(from: 0);
      setState(() {
        _reset();
        _errorMsg = error;
      });
    } else {
      setState(_reset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _keyboardFocus.requestFocus();
    });

    return KeyboardListener(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent || _submitting) return;
        final key = event.logicalKey;
        final map = {
          LogicalKeyboardKey.digit0: '0',
          LogicalKeyboardKey.numpad0: '0',
          LogicalKeyboardKey.digit1: '1',
          LogicalKeyboardKey.numpad1: '1',
          LogicalKeyboardKey.digit2: '2',
          LogicalKeyboardKey.numpad2: '2',
          LogicalKeyboardKey.digit3: '3',
          LogicalKeyboardKey.numpad3: '3',
          LogicalKeyboardKey.digit4: '4',
          LogicalKeyboardKey.numpad4: '4',
          LogicalKeyboardKey.digit5: '5',
          LogicalKeyboardKey.numpad5: '5',
          LogicalKeyboardKey.digit6: '6',
          LogicalKeyboardKey.numpad6: '6',
          LogicalKeyboardKey.digit7: '7',
          LogicalKeyboardKey.numpad7: '7',
          LogicalKeyboardKey.digit8: '8',
          LogicalKeyboardKey.numpad8: '8',
          LogicalKeyboardKey.digit9: '9',
          LogicalKeyboardKey.numpad9: '9',
        };
        if (map.containsKey(key)) {
          _onKeyTap(map[key]!);
        } else if (key == LogicalKeyboardKey.backspace ||
            key == LogicalKeyboardKey.delete) {
          _onKeyTap('del');
        }
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: t.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.shieldCheck,
                      size: 30,
                      color: t.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    style: NovaFonts.heading.copyWith(
                      fontSize: 20,
                      color: t.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: NovaFonts.body.copyWith(
                      fontSize: 13,
                      color: t.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP boxes
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(
                        _shakeAnim.value *
                            ((_shakeCtrl.value * 10).floor().isEven ? 1 : -1),
                        0,
                      ),
                      child: Row(
                        children: [
                          ...List.generate(6, (i) {
                            final filled = i < _currentIndex;
                            final isCurrent =
                                i == _currentIndex && !_submitting;
                            final hasError = _errorMsg != null;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: hasError
                                        ? Colors.red.shade50
                                        : isCurrent
                                        ? t.primaryLight
                                        : t.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasError
                                          ? Colors.red
                                          : isCurrent
                                          ? t.primary
                                          : t.primaryMid,
                                      width: isCurrent ? 2 : 1,
                                    ),
                                    boxShadow: isCurrent
                                        ? [t.cardShadow]
                                        : null,
                                  ),
                                  child: Center(
                                    child: filled
                                        ? _isObscure
                                              ? Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: hasError
                                                        ? Colors.red
                                                        : t.primary,
                                                  ),
                                                )
                                              : Text(
                                                  _digits[i],
                                                  style: NovaFonts.numbers
                                                      .copyWith(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: hasError
                                                            ? Colors.red
                                                            : t.primary,
                                                      ),
                                                )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isObscure = !_isObscure),
                            child: Container(
                              width: 48,
                              height: 54,
                              decoration: BoxDecoration(
                                color: t.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: t.primaryMid),
                              ),
                              child: Icon(
                                _isObscure
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                                color: t.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AnimatedOpacity(
                    opacity: _errorMsg != null ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _errorMsg ?? '',
                            style: NovaFonts.body.copyWith(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (widget.showForgot) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onForgot,
                      child: Text(
                        context.tr('Quên mã PIN?', 'Forgot PIN?'),
                        style: NovaFonts.body.copyWith(
                          color: t.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_submitting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: CircularProgressIndicator(color: t.primary),
            )
          else
            _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      color: NovaTheme.of(context).background,
      child: Column(
        children: [
          _numRow(['1', '2\nABC', '3\nDEF']),
          _numRow(['4\nGHI', '5\nJKL', '6\nMNO']),
          _numRow(['7\nPQRS', '8\nTUV', '9\nWXYZ']),
          _numRow(['', '0', 'del']),
        ],
      ),
    );
  }

  Widget _numRow(List<String> keys) => Row(
    children: keys
        .map(
          (key) => Expanded(
            child: GestureDetector(
              onTap: key.isEmpty
                  ? null
                  : () => _onKeyTap(key == 'del' ? 'del' : key[0]),
              child: Container(
                height: 72,
                margin: const EdgeInsets.all(0.5),
                color: NovaTheme.of(context).surface,
                child: Center(
                  child: key == 'del'
                      ? Icon(
                          Icons.backspace_outlined,
                          size: 22,
                          color: NovaTheme.of(context).textPrimary,
                        )
                      : key.isEmpty
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              key.split('\n')[0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (key.contains('\n'))
                              Text(
                                key.split('\n')[1],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: NovaTheme.of(context).textSecondary,
                                  letterSpacing: 1,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

// =============================================================================
// Forgot PIN Sheet
// =============================================================================
class _ForgotPinSheet extends StatefulWidget {
  final VoidCallback onVerified;
  const _ForgotPinSheet({required this.onVerified});

  @override
  State<_ForgotPinSheet> createState() => _ForgotPinSheetState();
}

class _ForgotPinSheetState extends State<_ForgotPinSheet> {
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final pass = _passCtrl.text;
    if (pass.isEmpty) {
      setState(
        () => _error = context.tr(
          'Vui lòng nhập mật khẩu',
          'Please enter your password',
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 2. Mẹo: Sử dụng chức năng "Update Password" để verify (Nếu pass sai nó sẽ báo lỗi ngay)
      await account.updatePassword(password: pass, oldPassword: pass);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onVerified();
    } catch (e) {
      if (!mounted) return;
      debugPrint('Auth Error: $e');

      setState(() {
        _error = context.tr(
          'Mật khẩu không chính xác, vui lòng thử lại',
          'Incorrect password, please try again',
        );
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: t.primaryMid,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: t.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.keyRound, size: 28, color: t.primary),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('Xác minh danh tính', 'Verify identity'),
            style: NovaFonts.heading.copyWith(
              fontSize: 18,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Nhập mật khẩu đăng nhập để xác minh\ntrước khi đặt lại mã PIN',
              'Enter your login password to verify\nbefore resetting the PIN',
            ),
            textAlign: TextAlign.center,
            style: NovaFonts.body.copyWith(
              fontSize: 13,
              color: t.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: t.background,
              borderRadius: BorderRadius.circular(14),
              border: _error != null
                  ? Border.all(color: Colors.red, width: 1.2)
                  : null,
            ),
            child: TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: NovaFonts.body.copyWith(
                fontSize: 15,
                color: t.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: context.tr('Mật khẩu đăng nhập', 'Login password'),
                hintStyle: NovaFonts.body.copyWith(
                  color: t.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                    color: t.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          ),
          if (_error != null && _error!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: NovaFonts.body.copyWith(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.tr('Xác nhận', 'Confirm'),
                      style: NovaFonts.heading.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.tr('Hủy', 'Cancel'),
              style: NovaFonts.body.copyWith(
                color: t.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Done view
// =============================================================================
class _DoneView extends StatelessWidget {
  final bool isNew;
  final VoidCallback onBack;
  const _DoneView({required this.isNew, required this.onBack});

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
                  color: t.primary.withOpacity(0.15),
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
            isNew
                ? context.tr('Tích hợp thành công!', 'Setup successful!')
                : context.tr('Đổi mã thành công!', 'PIN changed successfully!'),
            style: NovaFonts.heading.copyWith(
              fontSize: 24,
              color: t.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isNew
                ? context.tr(
                    'Mã PIN Smart OTP đã được lưu trên thiết bị này.\nDùng mã này để xác nhận mọi giao dịch.',
                    'Your Smart OTP PIN has been saved on this device.\nUse it to confirm all transactions.',
                  )
                : context.tr(
                    'Mã PIN mới đã được cập nhật thành công.',
                    'Your new PIN has been updated successfully.',
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
                      'Giữ bí mật mã PIN. Không chia sẻ với bất kỳ ai kể cả nhân viên ngân hàng.',
                      'Keep your PIN secret. Do not share it with anyone, including bank staff.',
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

enum _Step { loading, intro, enterOld, enterNew, confirmNew, done }
