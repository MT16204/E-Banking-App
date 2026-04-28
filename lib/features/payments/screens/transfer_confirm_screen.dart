import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/data/repositories/transfer_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/main.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'transfer_screen.dart';
import 'package:banking_app/data/services/otp_service.dart';

// ─── Confirm Screen ───────────────────────────────────────
class TransferConfirmScreen extends StatelessWidget {
  final String senderUserId;
  final String sourceAccountNumber;
  final String recipientAccountNumber;
  final String recipientName;
  final String recipientBank;
  final double amount;
  final String note;
  final bool isFastTransfer;
  final String? categoryId;

  const TransferConfirmScreen({
    super.key,
    required this.senderUserId,
    required this.sourceAccountNumber,
    required this.recipientAccountNumber,
    required this.recipientName,
    required this.recipientBank,
    required this.amount,
    required this.note,
    required this.isFastTransfer,
    this.categoryId,
  });

  void _showOtpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpBottomSheet(
        senderUserId: senderUserId,
        sourceAccountNumber: sourceAccountNumber,
        recipientAccountNumber: recipientAccountNumber,
        recipientName: recipientName,
        amount: amount,
        note: note,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final fmt = NumberFormat('#,###', 'vi_VN');
    final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('Xác nhận giao dịch', 'Confirm transaction'),
          style: NovaFonts.heading.copyWith(
            fontSize: 18,
            color: theme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.home, color: theme.textPrimary),
            onPressed: () =>
                Navigator.of(context).popUntil(ModalRoute.withName('/home')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.primaryMid.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'i',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr(
                        'Vui lòng kiểm tra thông tin trước khi xác nhận giao dịch',
                        'Please review the information before confirming the transaction',
                      ),
                      style: NovaFonts.body.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _row(
                    context,
                    context.tr('Tài khoản nguồn', 'Source account'),
                    sourceAccountNumber,
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Tài khoản thụ hưởng', 'Recipient account'),
                    recipientAccountNumber,
                    valueColor: NovaColors.yellow,
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Tên người thụ hưởng', 'Recipient name'),
                    recipientName,
                    valueColor: NovaColors.yellow,
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Ngân hàng thụ hưởng', 'Recipient bank'),
                    recipientBank,
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Hình thức chuyển tiền', 'Transfer type'),
                    isFastTransfer
                        ? context.tr('Chuyển nhanh', 'Fast transfer')
                        : context.tr('Chuyển thường', 'Standard transfer'),
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Phí giao dịch', 'Transaction fee'),
                    context.tr('Miễn phí', 'Free'),
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Số tiền trích nợ', 'Debited amount'),
                    '${fmt.format(amount)} VND',
                    valueColor: NovaColors.yellow,
                    valueFontSize: 16,
                    valueBold: true,
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Ngày giao dịch', 'Transaction date'),
                    dateStr,
                  ),
                  _divider(context),
                  _row(
                    context,
                    context.tr('Nội dung', 'Description'),
                    note,
                    multiLine: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: theme.surface,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => _showOtpModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: Text(
              context.tr('Xác nhận', 'Confirm'),
              style: NovaFonts.heading.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    double valueFontSize = 14,
    bool valueBold = false,
    bool multiLine = false,
  }) {
    // Keep this helper pure; read theme from context where needed.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: multiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: NovaFonts.body.copyWith(
                color: NovaTheme.of(context).textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: NovaFonts.body.copyWith(
                fontSize: valueFontSize,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? NovaTheme.of(context).textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    color: NovaTheme.of(context).primaryMid.withValues(alpha: 0.18),
    thickness: 1,
    height: 0,
  );
}

// ─── OTP Bottom Sheet ─────────────────────────────────────
class OtpBottomSheet extends StatefulWidget {
  final String senderUserId;
  final String sourceAccountNumber;
  final String recipientAccountNumber;
  final String recipientName;
  final double amount;
  final String note;
  final String? categoryId;

  const OtpBottomSheet({
    super.key,
    required this.senderUserId,
    required this.sourceAccountNumber,
    required this.recipientAccountNumber,
    required this.recipientName,
    required this.amount,
    required this.note,
    this.categoryId,
  });

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  static const int _otpLength = 6;

  final List<String> _digits = List.filled(_otpLength, '');
  int _currentIndex = 0;
  bool _isObscure = true;
  bool _isProcessing = false;
  bool _hasError = false;
  bool _transferDone = false;
  final FocusNode _keyboardFocus = FocusNode();

  void _onKeyTap(String key) {
    if (_isProcessing) return;

    bool shouldVerify = false;

    setState(() {
      _hasError = false;
      if (key == 'del') {
        if (_currentIndex > 0) {
          _currentIndex--;
          _digits[_currentIndex] = '';
        }
      } else if (_currentIndex < _otpLength) {
        _digits[_currentIndex] = key;
        _currentIndex++;
        if (_currentIndex == _otpLength) shouldVerify = true;
      }
    });

    if (shouldVerify) _verifyOtp();
  }

  Future<void> _verifyOtp() async {
    if (_isProcessing) return;

    final entered = _digits.join();
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final isCorrect = await OtpService.verifyPin(widget.senderUserId, entered);

    if (!mounted) return;

    if (isCorrect) {
      await _executeTransfer();
    } else {
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _digits.fillRange(0, _otpLength, '');
        _currentIndex = 0;
      });
    }
  }

  Future<void> _executeTransfer() async {
    if (_transferDone) return;
    _transferDone = true;
    try {
      await context.read<TransferRepository>().transferMoney(
        senderUserId: widget.senderUserId,
        senderAccountNumber: widget.sourceAccountNumber,
        recipientAccountNumber: widget.recipientAccountNumber,
        amount: widget.amount,
        note: widget.note,
        categoryId: widget.categoryId,
      );

      if (!mounted) return;
      await context.read<UserProvider>().fetchUser(account);
      if (!mounted) return;
      context.read<UserProvider>().queueTransferSuccessNotification(
        recipientName: widget.recipientName,
        amount: widget.amount,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => TransferSuccessScreen(
            recipientName: widget.recipientName,
            recipientAccountNumber: widget.recipientAccountNumber,
            amount: widget.amount,
            note: widget.note,
          ),
        ),
        ModalRoute.withName('/home'),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _digits.fillRange(0, _otpLength, '');
        _currentIndex = 0;
        _transferDone = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Giao dịch thất bại: ${e.toString()}',
              'Transaction failed: ${e.toString()}',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _keyboardFocus.requestFocus();
    });

    return KeyboardListener(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        if (_isProcessing || _transferDone) return;

        final key = event.logicalKey;
        final digits = {
          LogicalKeyboardKey.digit0: '0',
          LogicalKeyboardKey.digit1: '1',
          LogicalKeyboardKey.digit2: '2',
          LogicalKeyboardKey.digit3: '3',
          LogicalKeyboardKey.digit4: '4',
          LogicalKeyboardKey.digit5: '5',
          LogicalKeyboardKey.digit6: '6',
          LogicalKeyboardKey.digit7: '7',
          LogicalKeyboardKey.digit8: '8',
          LogicalKeyboardKey.digit9: '9',
          LogicalKeyboardKey.numpad0: '0',
          LogicalKeyboardKey.numpad1: '1',
          LogicalKeyboardKey.numpad2: '2',
          LogicalKeyboardKey.numpad3: '3',
          LogicalKeyboardKey.numpad4: '4',
          LogicalKeyboardKey.numpad5: '5',
          LogicalKeyboardKey.numpad6: '6',
          LogicalKeyboardKey.numpad7: '7',
          LogicalKeyboardKey.numpad8: '8',
          LogicalKeyboardKey.numpad9: '9',
        };
        if (digits.containsKey(key)) {
          _onKeyTap(digits[key]!);
        } else if (key == LogicalKeyboardKey.backspace ||
            key == LogicalKeyboardKey.delete) {
          _onKeyTap('del');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.primaryMid.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            'Xác nhận giao dịch',
                            'Confirm transaction',
                          ),
                          style: NovaFonts.heading.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr(
                            'Nhập mã Smart OTP của bạn để xác nhận giao dịch',
                            'Enter your Smart OTP to confirm the transaction',
                          ),
                          style: NovaFonts.body.copyWith(
                            color: theme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // OTP dots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ...List.generate(6, (i) {
                    final filled = i < _currentIndex;
                    final isCurrent = i == _currentIndex;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          decoration: BoxDecoration(
                            color: _hasError
                                ? theme.errorBg
                                : isCurrent
                                ? theme.primaryLight
                                : theme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _hasError
                                  ? theme.error
                                  : isCurrent
                                  ? theme.primary
                                  : theme.primaryMid.withValues(alpha: 0.45),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: filled
                                ? _isObscure
                                      ? Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: _hasError
                                                ? theme.error
                                                : theme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : Text(
                                          _digits[i],
                                          style: NovaFonts.numbers.copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: _hasError
                                                ? theme.error
                                                : theme.primary,
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
                    onTap: () => setState(() => _isObscure = !_isObscure),
                    child: Container(
                      width: 44,
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isObscure ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: theme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_hasError) ...[
              const SizedBox(height: 10),
              Text(
                context.tr(
                  'Mã PIN không đúng. Vui lòng thử lại.',
                  'Incorrect PIN. Please try again.',
                ),
                style: NovaFonts.body.copyWith(
                  color: theme.error,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 28),

            _isProcessing
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: NovaColors.primaryGreen,
                    ),
                  )
                : _buildNumpad(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final theme = NovaTheme.watch(context);
    return Container(
      color: theme.background,
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
    children: keys.map((key) {
      return Expanded(
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
      );
    }).toList(),
  );
}

// ─── Success Screen ───────────────────────────────────────
class TransferSuccessScreen extends StatelessWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final double amount;
  final String note;

  const TransferSuccessScreen({
    super.key,
    required this.recipientName,
    required this.recipientAccountNumber,
    required this.amount,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final fmt = NumberFormat('#,###', 'vi_VN');
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.checkCircle,
                    color: theme.primary,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  context.tr('Chuyển tiền thành công!', 'Transfer successful!'),
                  style: NovaFonts.heading.copyWith(
                    fontSize: 22,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: NovaFonts.body.copyWith(
                    color: theme.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 36),

                // Summary card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.primaryMid.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${fmt.format(amount)} VND',
                        style: NovaFonts.numbers.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _summaryRow(
                        context.tr('Người nhận', 'Recipient'),
                        recipientName,
                        valueColor: theme.primary,
                      ),
                      Divider(
                        height: 24,
                        color: theme.primaryMid.withValues(alpha: 0.25),
                      ),
                      _summaryRow(
                        context.tr('Số tài khoản', 'Account number'),
                        recipientAccountNumber,
                      ),
                      Divider(
                        height: 24,
                        color: theme.primaryMid.withValues(alpha: 0.25),
                      ),
                      _summaryRow(context.tr('Nội dung', 'Description'), note),
                      Divider(
                        height: 24,
                        color: theme.primaryMid.withValues(alpha: 0.25),
                      ),
                      _summaryRow(
                        context.tr('Phí giao dịch', 'Transaction fee'),
                        context.tr('Miễn phí', 'Free'),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).popUntil(ModalRoute.withName('/home'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.tr('Về trang chủ', 'Back to home'),
                      style: NovaFonts.heading.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).popUntil(ModalRoute.withName('/home'));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransferScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      context.tr('Chuyển tiền tiếp', 'Make another transfer'),
                      style: NovaFonts.heading.copyWith(
                        color: theme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: NovaFonts.body.copyWith(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: NovaFonts.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
