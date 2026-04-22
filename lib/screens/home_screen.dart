import 'package:banking_app/providers/appearance_provider.dart';
import 'package:banking_app/screens/card_screen.dart';
import 'package:banking_app/screens/transfer_screen.dart';
import 'package:banking_app/screens/utilities_screen.dart';
import 'package:banking_app/widgets/balance_card.dart';
import 'package:banking_app/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../l10n/app_lang.dart';
import '../main.dart';
import '../theme/fonts.dart';
import '../theme/colors.dart';
import '../data/repositories/auth_repository.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';
import 'analytics_screen.dart';

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

  AuthRepository get _authRepo => context.read<AuthRepository>();

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

  Future<void> _handleLogout() async {
    try {
      await _authRepo.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (e.toString().contains('401') && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('Lỗi', 'Error')}: ${e.toString()}'),
          ),
        );
      }
    }
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
            SliverToBoxAdapter(child: _buildHeader()),
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
                child: _buildQuickActions(),
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

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final theme = NovaTheme.watch(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? context.tr('Chào buổi sáng', 'Good morning')
        : hour < 18
        ? context.tr('Chào buổi chiều', 'Good afternoon')
        : context.tr('Chào buổi tối', 'Good evening');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Consumer2<UserProvider, AppearanceProvider>(
              builder: (context, userProvider, appearanceProvider, _) {
                final fullName = userProvider.user?.name ?? 'User';
                final firstName = fullName.trim().split(' ').last;
                final currentAvatar = kAvatarPresets.firstWhere(
                  (a) => a.id == appearanceProvider.avatarId,
                  orElse: () => kAvatarPresets
                      .first, 
                );
                return Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: currentAvatar.bgColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primary, width: 1.5),
                      ),
                      child: Center(
                        child: currentAvatar.id == 'initial'
                            ? Text(
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : 'U',
                                style: NovaFonts.heading.copyWith(
                                  fontSize: 17,
                                  color: theme.primary,
                                ),
                              )
                            : Text(
                                currentAvatar.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting...',
                          style: NovaFonts.body.copyWith(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          firstName,
                          style: NovaFonts.heading.copyWith(
                            fontSize: 17,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, provider, _) {
              final hasUnread = provider.notifications.any((n) => !n.isRead);
              return _AnimatedNotificationBell(
                hasUnread: hasUnread,
                onTap: () {
                  final uid = provider.user?.$id;
                  if (uid != null) {
                    Navigator.pushNamed(
                      context,
                      '/notification_screen',
                      arguments: uid,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Quick actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final theme = NovaTheme.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Chức năng nhanh', 'Quick actions'),
          style: NovaFonts.heading.copyWith(
            fontSize: 15,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quickBtn(
              icon: LucideIcons.arrowLeftRight,
              label: context.tr('Chuyển\ntiền', 'Transfer'),
              isPrimary: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferScreen()),
              ),
            ),
            _quickBtn(
              icon: LucideIcons.history,
              label: context.tr('Lịch sử', 'History'),
              onTap: () {
                final uid = context.read<UserProvider>().user?.$id;
                if (uid != null) {
                  Navigator.pushNamed(
                    context,
                    '/transaction_screen',
                    arguments: uid,
                  );
                }
              },
            ),
            _quickBtn(
              icon: LucideIcons.scanLine,
              label: context.tr('Quét mã', 'Scan'),
              onTap: _openQRScanner,
            ),
            _quickBtn(
              icon: LucideIcons.moreHorizontal,
              label: context.tr('Khác', 'More'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UtilitiesScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickBtn({
    required IconData icon,
    required String label,
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isPrimary
                  ? NovaTheme.of(context).primary
                  : NovaTheme.of(context).surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: isPrimary
                      ? NovaTheme.of(context).primary.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: isPrimary
                  ? Colors.white
                  : NovaTheme.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: NovaFonts.body.copyWith(
              fontSize: 11,
              color: NovaTheme.of(context).textSecondary,
              height: 1.3,
            ),
          ),
        ],
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
    final theme = NovaTheme.watch(context);
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final userId = provider.user?.$id ?? '';
        final transactions = provider.transactions;
        final fmt = NumberFormat('#,###', 'vi_VN');

        final months = List.generate(
          6,
          (i) => DateTime(_analyticsMonth.year, _analyticsMonth.month - 5 + i),
        );
        final income = List.filled(6, 0.0);
        final expense = List.filled(6, 0.0);

        for (final t in transactions) {
          for (int i = 0; i < 6; i++) {
            if (t.createdAt.month == months[i].month &&
                t.createdAt.year == months[i].year) {
              if (t.receiverId == userId) income[i] += t.amount;
              if (t.senderId == userId) expense[i] += t.amount;
            }
          }
        }

        final thisMonthIncome = income.last;
        final thisMonthExpense = expense.last;
        final maxVal = [
          ...income,
          ...expense,
        ].fold(0.0, (a, b) => a > b ? a : b);
        final monthNames = [
          'T1',
          'T2',
          'T3',
          'T4',
          'T5',
          'T6',
          'T7',
          'T8',
          'T9',
          'T10',
          'T11',
          'T12',
        ];
        final monthLabels = months.map((m) => monthNames[m.month - 1]).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('Thống kê chi tiêu', 'Spending analytics'),
                          style: NovaFonts.heading.copyWith(
                            fontSize: 15,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _balanceHidden
                                ? '••••••'
                                : '${fmt.format(thisMonthExpense)} đ',
                            key: ValueKey(_balanceHidden),
                            style: NovaFonts.numbers.copyWith(
                              fontSize: 22,
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w300,
                              letterSpacing: _balanceHidden ? 3 : 0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAnalyticsMonthPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: NovaColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'T${_analyticsMonth.month}/${_analyticsMonth.year}',
                            style: NovaFonts.body.copyWith(
                              color: theme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            LucideIcons.chevronDown,
                            size: 11,
                            color: NovaColors.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(6, (i) {
                    final isNow = i == 5;
                    final incomeH = maxVal > 0
                        ? (income[i] / maxVal) * 100
                        : 4.0;
                    final expenseH = maxVal > 0
                        ? (expense[i] / maxVal) * 100
                        : 4.0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 400 + i * 60,
                                  ),
                                  curve: Curves.easeOut,
                                  width: 8,
                                  height: incomeH.clamp(4, 88),
                                  decoration: BoxDecoration(
                                    color: isNow
                                        ? theme.primary
                                        : theme.primary.withValues(alpha: 0.25),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 400 + i * 60,
                                  ),
                                  curve: Curves.easeOut,
                                  width: 8,
                                  height: expenseH.clamp(4, 88),
                                  decoration: BoxDecoration(
                                    color: isNow
                                        ? NovaColors.yellow
                                        : NovaColors.yellow.withOpacity(0.12),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              monthLabels[i],
                              style: NovaFonts.body.copyWith(
                                fontSize: 10,
                                color: isNow
                                    ? theme.primary
                                    : theme.textSecondary,
                                fontWeight: isNow
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: theme.primaryMid.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _legendDot(
                    NovaColors.primaryGreen,
                    context.tr('Thu nhập', 'Income'),
                  ),
                  const SizedBox(width: 16),
                  _legendDot(
                    NovaColors.yellow,
                    context.tr('Chi tiêu', 'Expense'),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 1),
                    child: Row(
                      children: [
                        Text(
                          context.tr('Chi tiết', 'Details'),
                          style: NovaFonts.body.copyWith(
                            color: theme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          LucideIcons.arrowRight,
                          size: 13,
                          color: NovaColors.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _summaryChip(
                      icon: LucideIcons.arrowDownLeft,
                      label: context.tr('Thu nhập', 'Income'),
                      value: _balanceHidden
                          ? '••••••'
                          : '+${fmt.format(thisMonthIncome)} đ',
                      color: theme.primary,
                      bgColor: theme.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryChip(
                      icon: LucideIcons.arrowUpRight,
                      label: context.tr('Chi tiêu', 'Expense'),
                      value: _balanceHidden
                          ? '••••••'
                          : '-${fmt.format(thisMonthExpense)} đ',
                      color: theme.textPrimary,
                      bgColor: theme.background,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color, String label) {
    final theme = NovaTheme.watch(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: NovaFonts.body.copyWith(
            color: theme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: NovaFonts.body.copyWith(
                    color: NovaTheme.of(context).textSecondary,
                    fontSize: 10,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: NovaFonts.numbers.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent transactions ───────────────────────────────────────────────────
  Widget _buildRecentTransactions() {
    final theme = NovaTheme.watch(context);
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.user?.$id;
    final transactions = userProvider.transactions;
    final fmt = NumberFormat('#,###', 'vi_VN');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('Giao dịch gần đây', 'Recent transactions'),
              style: NovaFonts.heading.copyWith(
                fontSize: 15,
                color: theme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (userId != null) {
                  Navigator.pushNamed(
                    context,
                    '/transaction_screen',
                    arguments: userId,
                  );
                }
              },
              child: Text(
                context.tr('Tất cả', 'All'),
                style: NovaFonts.body.copyWith(
                  color: transactions.isNotEmpty
                      ? theme.primary
                      : theme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: transactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.inbox,
                          size: 32,
                          color: theme.primaryMid.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr(
                            'Chưa có giao dịch',
                            'No transactions yet',
                          ),
                          style: NovaFonts.body.copyWith(
                            color: theme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: transactions.take(4).map((tx) {
                    final isReceived = tx.receiverId == userId;
                    final isLast = tx == transactions.take(4).last;
                    final desc =
                        tx.description ??
                        (isReceived
                            ? context.tr('Nhận tiền', 'Money received')
                            : context.tr('Chuyển tiền', 'Money transfer'));
                    final dateStr = DateFormat(
                      'dd/MM/yyyy',
                    ).format(tx.createdAt);
                    final amountStr = _balanceHidden
                        ? '••••••'
                        : '${isReceived ? '+' : '-'}${fmt.format(tx.amount)} VND';

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isReceived
                                      ? theme.primaryLight
                                      : theme.background,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  isReceived
                                      ? LucideIcons.arrowDownLeft
                                      : LucideIcons.arrowUpRight,
                                  size: 18,
                                  color: isReceived
                                      ? theme.primary
                                      : theme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      desc,
                                      style: NovaFonts.body.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      dateStr,
                                      style: NovaFonts.body.copyWith(
                                        fontSize: 12,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: Text(
                                      amountStr,
                                      key: ValueKey(amountStr),
                                      style: NovaFonts.numbers.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isReceived
                                            ? theme.primary
                                            : theme.textPrimary,
                                        letterSpacing: _balanceHidden ? 2 : 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      context.tr('Hoàn thành', 'Completed'),
                                      style: NovaFonts.body.copyWith(
                                        fontSize: 9,
                                        color: theme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: 72,
                            endIndent: 16,
                            color: theme.primaryMid.withValues(alpha: 0.3),
                          ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _AnimatedNotificationBell extends StatefulWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _AnimatedNotificationBell({
    required this.hasUnread,
    required this.onTap,
  });

  @override
  State<_AnimatedNotificationBell> createState() =>
      _AnimatedNotificationBellState();
}

class _AnimatedNotificationBellState extends State<_AnimatedNotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconSwing;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _iconSwing = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.07), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.07, end: 0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(0), weight: 8),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _pulse = Tween<double>(
      begin: 1,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _AnimatedNotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasUnread != widget.hasUnread) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.hasUnread) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: widget.hasUnread
                          ? theme.primary.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: widget.hasUnread ? 14 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: widget.hasUnread ? _iconSwing.value : 0,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      LucideIcons.bell,
                      size: 19,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ),
              if (widget.hasUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.background, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.error.withValues(alpha: 0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
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
