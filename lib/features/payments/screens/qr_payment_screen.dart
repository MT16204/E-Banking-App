import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:appwrite/appwrite.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:banking_app/data/repositories/wallet_repository.dart';
import 'package:banking_app/widgets/header.dart';
import 'transfer_screen.dart';

class QRPaymentScreen extends StatefulWidget {
  final Client client;
  final String currentUserId;

  const QRPaymentScreen({
    super.key,
    required this.client,
    required this.currentUserId,
  });

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WalletRepository _walletRepo;
  bool isProcessing = false;
  final MobileScannerController scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Resume/stop scanner theo tab
      if (!_tabController.indexIsChanging) return;
      if (_tabController.index == 1) {
        scannerController.start();
      } else {
        scannerController.stop();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _walletRepo = context.read<WalletRepository>();
  }

  @override
  void dispose() {
    scannerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onQRDetected(String receiverId) async {
    if (isProcessing) return;

    if (receiverId == widget.currentUserId) {
      _showStatusDialog(
        false,
        context.tr(
          'Bạn không thể tự chuyển tiền cho chính mình.',
          'You cannot transfer money to yourself.',
        ),
      );
      return;
    }

    setState(() => isProcessing = true);
    scannerController.stop();

    try {
      final wallet = await _walletRepo.getWalletByUserId(receiverId);
      if (wallet == null) {
        throw Exception(context.tr('Không tìm thấy ví', 'Wallet not found'));
      }

      final result = await _walletRepo.lookupAccountByNumber(
        wallet.accountNumber,
      );
      final user = result['user'] as UserModel;

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransferScreen(
            prefillAccountNumber: wallet.accountNumber,
            prefillUser: user,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showStatusDialog(
          false,
          context.tr(
            'Không tìm thấy tài khoản Nova Banking.',
            'Nova Banking account not found.',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
        // Resume camera khi quay lại tab quét
        if (_tabController.index == 1) scannerController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Header.withTitle(
              title: context.tr('Thanh toán QR', 'QR payment'),
              onBack: () => Navigator.pop(context),
              action: IconButton(
                icon: Icon(LucideIcons.home, color: t.textPrimary),
                onPressed: () => Navigator.of(
                  context,
                ).popUntil(ModalRoute.withName('/home')),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [NovaColors.cardShadow],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: t.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: t.textSecondary,
                  labelStyle: NovaFonts.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: NovaFonts.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: context.tr('Mã của tôi', 'My code')),
                    Tab(text: context.tr('Quét mã', 'Scan code')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildMyQRTab(), _buildScanQRTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: My QR ────────────────────────────────────────────────────────────
  Widget _buildMyQRTab() {
    final t = NovaTheme.watch(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [NovaColors.cardShadow],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: t.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 12, color: t.primary),
                      const SizedBox(width: 5),
                      Text(
                        'Nova Banking',
                        style: NovaFonts.body.copyWith(
                          fontSize: 12,
                          color: t.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.primaryMid, width: 1.5),
                  ),
                  child: QrImageView(
                    data: 'NOVA_PAYMENT:${widget.currentUserId}',
                    version: QrVersions.auto,
                    size: 200.0,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: t.primary,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: t.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: t.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.fingerprint,
                        size: 13,
                        color: t.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ID: ${widget.currentUserId}',
                        style: NovaFonts.body.copyWith(
                          color: t.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                      'Dùng mã này để nhận tiền nhanh từ người dùng Nova khác.',
                      'Use this code to quickly receive money from other Nova users.',
                    ),
                    style: NovaFonts.body.copyWith(
                      color: t.primary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: LucideIcons.download,
                  label: context.tr('Lưu mã', 'Save code'),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionBtn(
                  icon: LucideIcons.share2,
                  label: context.tr('Chia sẻ', 'Share'),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final t = NovaTheme.watch(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [NovaColors.cardShadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: t.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: NovaFonts.body.copyWith(
                color: t.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Scan QR ──────────────────────────────────────────────────────────
  Widget _buildScanQRTab() {
    return Stack(
      children: [
        MobileScanner(
          controller: scannerController,
          onDetect: (capture) {
            if (isProcessing) return;
            final String? code = capture.barcodes.first.rawValue;
            if (code != null && code.startsWith('NOVA_PAYMENT:')) {
              final receiverId = code.split(':')[1];
              _onQRDetected(receiverId);
            }
          },
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ScanOverlayPainter()),
          ),
        ),

        Align(
          alignment: const Alignment(0, -0.55),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.tr(
                'Đưa mã QR vào khung',
                'Align the QR code within the frame',
              ),
              style: NovaFonts.body.copyWith(color: Colors.white, fontSize: 13),
            ),
          ),
        ),

        if (isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    context.tr(
                      'Đang tra cứu tài khoản...',
                      'Looking up account...',
                    ),
                    style: NovaFonts.body.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Status dialog ───────────────────────────────────────
  void _showStatusDialog(bool isSuccess, String message) {
    final t = NovaTheme.watch(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isSuccess ? t.primaryLight : NovaColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess
                      ? LucideIcons.checkCircle2
                      : LucideIcons.alertCircle,
                  size: 36,
                  color: isSuccess ? t.primary : NovaColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isSuccess
                    ? context.tr('Thành công!', 'Success!')
                    : context.tr('Không tìm thấy', 'Not found'),
                style: NovaFonts.heading.copyWith(
                  fontSize: 18,
                  color: t.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: NovaFonts.body.copyWith(
                  color: t.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (_tabController.index == 1) scannerController.start();
                  },
                  child: Text(
                    context.tr('Thử lại', 'Try again'),
                    style: NovaFonts.heading.copyWith(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scan overlay painter ─────────────────────────────────────────────────────
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const scanSize = 240.0;
    const cornerRadius = 24.0;
    const cornerLen = 32.0;
    const strokeW = 3.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: scanSize,
      height: scanSize,
    );

    final dimPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(cornerRadius),
    );
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(rrect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, holePath),
      dimPaint,
    );

    final cornerPaint = Paint()
      ..color = NovaColors.primaryGreen
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final l = rect.left;
    final t = rect.top;
    final r = rect.right;
    final b = rect.bottom;
    const cr = cornerRadius;

    // 4 góc
    canvas.drawPath(
      Path()
        ..moveTo(l + cr, t)
        ..lineTo(l + cr + cornerLen, t)
        ..moveTo(l, t + cr)
        ..lineTo(l, t + cr + cornerLen),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(r - cr - cornerLen, t)
        ..lineTo(r - cr, t)
        ..moveTo(r, t + cr)
        ..lineTo(r, t + cr + cornerLen),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(l + cr, b)
        ..lineTo(l + cr + cornerLen, b)
        ..moveTo(l, b - cr)
        ..lineTo(l, b - cr - cornerLen),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(r - cr - cornerLen, b)
        ..lineTo(r - cr, b)
        ..moveTo(r, b - cr)
        ..lineTo(r, b - cr - cornerLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
