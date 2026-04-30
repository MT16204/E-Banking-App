import 'package:banking_app/features/analytics/screens/analytics_screen.dart';
import 'package:banking_app/features/cards/screens/card_screen.dart';
import 'package:banking_app/features/payments/screens/transfer_screen.dart';
import 'package:banking_app/features/profile/screens/profile_screen.dart';
import 'package:banking_app/features/utilities/screens/utilities_screen.dart';
import 'package:banking_app/widgets/balance_card.dart';
import 'package:banking_app/widgets/home_header.dart';
import 'package:banking_app/widgets/home_recent_transactions.dart';
import 'package:banking_app/widgets/home_quick_actions_section.dart';
import 'package:banking_app/widgets/home_spending_analytics.dart';
import 'package:banking_app/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/main.dart';
import 'package:banking_app/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _balanceHidden = false;
  _TransferPushBannerData? _banner;

  DateTime _analyticsMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUser(account);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<UserProvider>().fetchUser(account);
  }

  void _onItemTapped(int index) {
    if (index != 2) setState(() => _selectedIndex = index);
  }

  void _openQRScanner() {
    final userId = context.read<UserProvider>().user?.$id;
    if (userId != null) {
      Navigator.pushNamed(context, '/qr_payment', arguments: userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Vui lòng đợi trong giây lát...',
              'Please wait a moment...',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final pendingTransfer = context
        .watch<UserProvider>()
        .pendingTransferNotification;
    if (pendingTransfer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final payload = context
            .read<UserProvider>()
            .consumeTransferSuccessNotification();
        if (payload != null) {
          _showTransferPushBanner(payload);
        }
      });
    }

    void backToHome() => setState(() => _selectedIndex = 0);

    final pages = [
      _buildHomeContent(),
      AnalyticsScreen(onBackToHome: backToHome),
      const SizedBox(),
      CardScreen(onBackToHome: backToHome),
      ProfileScreen(onBackToHome: backToHome),
    ];

    return Scaffold(
      backgroundColor: theme.background,
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: pages),
          _TransferPushBanner(
            data: _banner,
            onDismissed: () {
              if (mounted) {
                setState(() => _banner = null);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTransferPushBanner(TransferSuccessNotification notification) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final amount = fmt.format(notification.amount);

    setState(() {
      _banner = _TransferPushBannerData(
        id: notification.createdAt.microsecondsSinceEpoch.toString(),
        title: 'Nova Banking',
        message: context.tr(
          'Chuyển tiền thành công tới ${notification.recipientName} • $amount VND',
          'Transfer successful to ${notification.recipientName} • $amount VND',
        ),
        timestamp: DateFormat('HH:mm').format(notification.createdAt),
      );
    });
  }

  // ─── Home content ──────────────────────────────────────────────────────────
  Widget _buildHomeContent() {
    final theme = NovaTheme.watch(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeHeader(
                onNotificationsTap: () {
                  final uid = context.read<UserProvider>().user?.$id;
                  if (uid != null) {
                    Navigator.pushNamed(
                      context,
                      '/notification_screen',
                      arguments: uid,
                    );
                  }
                },
              ),
            ),
            SliverToBoxAdapter(
              child: BalanceCard(
                balanceHidden: _balanceHidden,
                onToggleHidden: () =>
                    setState(() => _balanceHidden = !_balanceHidden),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: HomeQuickActionsSection(
                  onTransferTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  ),
                  onHistoryTap: () {
                    final uid = context.read<UserProvider>().user?.$id;
                    if (uid != null) {
                      Navigator.pushNamed(
                        context,
                        '/transaction_screen',
                        arguments: uid,
                      );
                    }
                  },
                  onScanTap: _openQRScanner,
                  onMoreTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UtilitiesScreen()),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildSpendingAnalytics(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildRecentTransactions(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // ─── Month picker ───────────────────────────────────────────────────────────
  void _showAnalyticsMonthPicker() {
    final now = DateTime.now();
    int pickerYear = _analyticsMonth.year;
    int pickerMonth = _analyticsMonth.month;

    showModalBottomSheet(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('Chọn tháng hiển thị', 'Choose display month'),
                      style: NovaFonts.heading.copyWith(fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: NovaTheme.of(context).background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: NovaTheme.of(context).textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setModal(() => pickerYear--),
                    child: const Icon(
                      Icons.chevron_left,
                      color: NovaColors.textPrimary,
                    ),
                  ),
                  Text(
                    context.tr('Năm $pickerYear', 'Year $pickerYear'),
                    style: NovaFonts.heading.copyWith(fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (pickerYear < now.year) {
                        setModal(() => pickerYear++);
                      }
                    },
                    child: Icon(
                      Icons.chevron_right,
                      color: pickerYear < now.year
                          ? NovaColors.textPrimary
                          : NovaColors.divider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final m = i + 1;
                  final isFuture = pickerYear == now.year && m > now.month;
                  final isSel = m == pickerMonth;
                  return GestureDetector(
                    onTap: isFuture
                        ? null
                        : () => setModal(() => pickerMonth = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSel
                            ? NovaTheme.of(context).primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel
                              ? NovaTheme.of(context).primary
                              : isFuture
                              ? NovaColors.divider
                              : NovaTheme.of(context).primaryMid,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'T$m',
                          style: NovaFonts.body.copyWith(
                            fontSize: 12,
                            fontWeight: isSel
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isSel
                                ? Colors.white
                                : isFuture
                                ? NovaColors.divider
                                : NovaTheme.of(context).textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(
                      () => _analyticsMonth = DateTime(pickerYear, pickerMonth),
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NovaTheme.of(context).primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.tr('Áp dụng', 'Apply'),
                    style: NovaFonts.heading.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Spending Analytics ────────────────────────────────────────────────────
  Widget _buildSpendingAnalytics() {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        return HomeSpendingAnalytics(
          transactions: provider.transactions,
          userId: provider.user?.$id ?? '',
          analyticsMonth: _analyticsMonth,
          balanceHidden: _balanceHidden,
          onMonthTap: _showAnalyticsMonthPicker,
          onDetailsTap: () => setState(() => _selectedIndex = 1),
        );
      },
    );
  }

  // ─── Recent transactions ───────────────────────────────────────────────────
  Widget _buildRecentTransactions() {
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.user?.$id;
    return HomeRecentTransactions(
      userId: userId,
      transactions: userProvider.transactions,
      balanceHidden: _balanceHidden,
      onViewAll: () {
        if (userId != null) {
          Navigator.pushNamed(
            context,
            '/transaction_screen',
            arguments: userId,
          );
        }
      },
    );
  }
}

class _TransferPushBannerData {
  final String id;
  final String title;
  final String message;
  final String timestamp;

  const _TransferPushBannerData({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });
}

class _TransferPushBanner extends StatefulWidget {
  final _TransferPushBannerData? data;
  final VoidCallback onDismissed;

  const _TransferPushBanner({required this.data, required this.onDismissed});

  @override
  State<_TransferPushBanner> createState() => _TransferPushBannerState();
}

class _TransferPushBannerState extends State<_TransferPushBanner> {
  bool _visible = false;
  String? _activeId;

  @override
  void didUpdateWidget(covariant _TransferPushBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    final data = widget.data;
    if (data != null && data.id != _activeId) {
      _activeId = data.id;
      _visible = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || widget.data?.id != data.id) return;
        setState(() => _visible = true);
        await Future.delayed(const Duration(milliseconds: 2600));
        if (!mounted || widget.data?.id != data.id) return;
        setState(() => _visible = false);
        await Future.delayed(const Duration(milliseconds: 280));
        if (!mounted || widget.data?.id != data.id) return;
        widget.onDismissed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final data = widget.data;
    if (data == null) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !_visible,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              offset: _visible ? Offset.zero : const Offset(0, -1.1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _visible ? 1 : 0,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: theme.primaryLight.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: theme.primaryLight.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            LucideIcons.bellRing,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: NovaFonts.body.copyWith(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    data.timestamp,
                                    style: NovaFonts.body.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: NovaFonts.body.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
