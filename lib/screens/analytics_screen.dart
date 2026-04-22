import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../l10n/app_lang.dart';
import '../theme/fonts.dart';
import '../theme/colors.dart';
import '../providers/user_provider.dart';
import '../widgets/header.dart';

// ─── Danh mục ────────────────────────────────────────────
class _Category {
  final String id, label;
  final IconData icon;
  final Color color;
  const _Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const _kCategories = [
  _Category(
    id: 'food',
    label: 'Nhà hàng',
    icon: LucideIcons.utensils,
    color: Color(0xFF00BFA5),
  ),
  _Category(
    id: 'misc',
    label: 'Tiêu vặt',
    icon: LucideIcons.coffee,
    color: Color(0xFFFFB300),
  ),
  _Category(
    id: 'fashion',
    label: 'Quần áo',
    icon: LucideIcons.shoppingBag,
    color: Color(0xFFE91E63),
  ),
  _Category(
    id: 'transport',
    label: 'Di chuyển',
    icon: LucideIcons.car,
    color: Color(0xFF3F51B5),
  ),
  _Category(
    id: 'health',
    label: 'Sức khỏe',
    icon: LucideIcons.heart,
    color: Color(0xFFF44336),
  ),
  _Category(
    id: 'education',
    label: 'Giáo dục',
    icon: LucideIcons.bookOpen,
    color: Color(0xFF9C27B0),
  ),
  _Category(
    id: 'bill',
    label: 'Hóa đơn',
    icon: LucideIcons.fileText,
    color: Color(0xFF2196F3),
  ),
  _Category(
    id: 'other',
    label: 'Khác',
    icon: LucideIcons.grid,
    color: Color(0xFF607D8B),
  ),
];

// ─── Screen ──────────────────────────────────────────────
class AnalyticsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const AnalyticsScreen({super.key, this.onBackToHome});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedMonth;
  bool _isExpense = true;
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _prevMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    _animController.forward(from: 0);
  });

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      return;
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _animController.forward(from: 0);
    });
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MonthPickerSheet(
        selected: _selectedMonth,
        onSelected: (m) => setState(() {
          _selectedMonth = m;
          _animController.forward(from: 0);
        }),
      ),
    );
  }

  String _categoryLabel(BuildContext context, String id) {
    switch (id) {
      case 'food':
        return context.tr('Nhà hàng', 'Food');
      case 'misc':
        return context.tr('Tiêu vặt', 'Misc');
      case 'fashion':
        return context.tr('Quần áo', 'Fashion');
      case 'transport':
        return context.tr('Di chuyển', 'Transport');
      case 'health':
        return context.tr('Sức khỏe', 'Health');
      case 'education':
        return context.tr('Giáo dục', 'Education');
      case 'bill':
        return context.tr('Hóa đơn', 'Bills');
      case 'other':
        return context.tr('Khác', 'Other');
      default:
        return id;
    }
  }

  _MonthData _computeData(UserProvider provider) {
    final userId = provider.user?.$id ?? '';
    final all = provider.transactions;

    final thisMonth = all
        .where(
          (t) =>
              t.createdAt.month == _selectedMonth.month &&
              t.createdAt.year == _selectedMonth.year,
        )
        .toList();

    final prevMonth = all.where((t) {
      final prev = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      return t.createdAt.month == prev.month && t.createdAt.year == prev.year;
    }).toList();

    double totalExpense = 0, totalIncome = 0, prevExpense = 0, prevIncome = 0;
    final expCat = <String, double>{};
    final incCat = <String, double>{};

    for (final t in thisMonth) {
      if (t.senderId == userId) {
        totalExpense += t.amount;
        final cat = t.category.isNotEmpty ? t.category : 'other';
        expCat[cat] = (expCat[cat] ?? 0) + t.amount;
      }
      if (t.receiverId == userId) {
        totalIncome += t.amount;
        final cat = t.category.isNotEmpty ? t.category : 'other';
        incCat[cat] = (incCat[cat] ?? 0) + t.amount;
      }
    }
    for (final t in prevMonth) {
      if (t.senderId == userId) prevExpense += t.amount;
      if (t.receiverId == userId) prevIncome += t.amount;
    }

    final months = List.generate(
      6,
      (i) => DateTime(_selectedMonth.year, _selectedMonth.month - 5 + i),
    );
    final monthExpense = List.filled(6, 0.0);
    final monthIncome = List.filled(6, 0.0);
    for (final t in all) {
      for (int i = 0; i < 6; i++) {
        if (t.createdAt.month == months[i].month &&
            t.createdAt.year == months[i].year) {
          if (t.senderId == userId) monthExpense[i] += t.amount;
          if (t.receiverId == userId) monthIncome[i] += t.amount;
        }
      }
    }

    return _MonthData(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      prevExpense: prevExpense,
      prevIncome: prevIncome,
      expenseByCategory: expCat,
      incomeByCategory: incCat,
      months: months,
      monthExpense: monthExpense,
      monthIncome: monthIncome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final theme = NovaTheme.watch(context);
        final data = _computeData(provider);
        final fmt = NumberFormat('#,###', 'vi_VN');
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

        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ─────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Header.withTitle(
                    title: context.tr('Thống kê', 'Analytics'),
                    centerTitle: false,
                    onBack: widget.onBackToHome,
                    action: GestureDetector(
                      onTap: _showMonthPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.primaryMid),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 14,
                              color: theme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'T${_selectedMonth.month}/${_selectedMonth.year}',
                              style: NovaFonts.body.copyWith(
                                color: theme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 13,
                              color: theme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Month navigator ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildMonthNav(monthNames),
                  ),
                ),

                // ── Summary bars ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildSummaryBars(data, fmt),
                  ),
                ),

                // ── Donut report ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildDonutReport(data, fmt),
                  ),
                ),

                // ── Line chart ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildLineChartSection(data, fmt, monthNames),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Month navigator ──────────────────────────────────
  Widget _buildMonthNav(List<String> monthNames) {
    final theme = NovaTheme.watch(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryMid.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevMonth,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.chevronLeft,
                size: 16,
                color: theme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: NovaColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr(
                    'Tháng ${_selectedMonth.month}, ${_selectedMonth.year}',
                    'Month ${_selectedMonth.month}, ${_selectedMonth.year}',
                  ),
                  style: NovaFonts.heading.copyWith(
                    fontSize: 15,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _nextMonth,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: _isCurrentMonth()
                    ? theme.primaryMid.withValues(alpha: 0.35)
                    : theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  // ─── Summary bars ─────────────────────────────────────
  Widget _buildSummaryBars(_MonthData data, NumberFormat fmt) {
    final theme = NovaTheme.watch(context);
    final expChange = data.prevExpense > 0
        ? (data.totalExpense - data.prevExpense) / data.prevExpense * 100
        : (data.totalExpense > 0 ? 100.0 : 0.0);
    final incChange = data.prevIncome > 0
        ? (data.totalIncome - data.prevIncome) / data.prevIncome * 100
        : (data.totalIncome > 0 ? 100.0 : 0.0);

    final maxVal = math.max(data.totalExpense, data.totalIncome);
    final expH = maxVal > 0 ? data.totalExpense / maxVal : 0.5;
    final incH = maxVal > 0 ? data.totalIncome / maxVal : 0.5;
    const maxBarH = 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Tổng quan thu chi', 'Income and expense overview'),
          style: NovaFonts.heading.copyWith(
            fontSize: 16,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Consumer<UserProvider>(
          builder: (_, provider, __) {
            final balance = provider.wallet?.balance ?? 0;
            return Text(
              context.tr(
                'Số dư: ${_formatShort(balance)} VND',
                'Balance: ${_formatShort(balance)} VND',
              ),
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: theme.textSecondary,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(
              label: context.tr('Chi tiêu', 'Expense'),
              value: data.totalExpense,
              change: expChange,
              barHeight: maxBarH * expH,
              color: NovaColors.yellow,
              fmt: fmt,
            ),
            const SizedBox(width: 20),
            _buildBar(
              label: context.tr('Thu nhập', 'Income'),
              value: data.totalIncome,
              change: incChange,
              barHeight: maxBarH * incH,
              color: theme.primary,
              fmt: fmt,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                size: 16,
                color: theme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  expChange >= 0
                      ? context.tr(
                          'Chi tiêu tăng ${expChange.toStringAsFixed(0)}% so với tháng trước',
                          'Expenses increased ${expChange.toStringAsFixed(0)}% from last month',
                        )
                      : context.tr(
                          'Chi tiêu giảm ${expChange.abs().toStringAsFixed(0)}% so với tháng trước',
                          'Expenses decreased ${expChange.abs().toStringAsFixed(0)}% from last month',
                        ),
                  style: NovaFonts.body.copyWith(
                    fontSize: 12,
                    color: theme.primary,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 14,
                color: theme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required double change,
    required double barHeight,
    required Color color,
    required NumberFormat fmt,
  }) {
    final theme = NovaTheme.watch(context);
    final isUp = change >= 0;
    final h = barHeight.clamp(30.0, 140.0);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 11,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${change.abs().toStringAsFixed(0)}%',
                      style: NovaFonts.body.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatShort(value),
                  style: NovaFonts.numbers.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              width: double.infinity,
              height: h * _anim.value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: NovaFonts.body.copyWith(
              fontSize: 13,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Donut chart ──────────────────────────────────────
  Widget _buildDonutReport(_MonthData data, NumberFormat fmt) {
    final theme = NovaTheme.watch(context);
    final catMap = _isExpense ? data.expenseByCategory : data.incomeByCategory;
    final total = _isExpense ? data.totalExpense : data.totalIncome;
    final segments = <_Segment>[];

    for (final cat in _kCategories) {
      final val = catMap[cat.id] ?? 0;
      if (val > 0) {
        segments.add(
          _Segment(
              label: _categoryLabel(context, cat.id),
            value: val,
            color: cat.color,
            icon: cat.icon,
            percent: total > 0 ? val / total * 100 : 0,
          ),
        );
      }
    }

    final displaySegments = segments.isEmpty
        ? [
            _Segment(
              label: context.tr('Chưa có', 'No data'),
              value: 1,
              color: NovaColors.divider,
              icon: LucideIcons.inbox,
              percent: 100,
            ),
          ]
        : segments;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Báo cáo thu chi', 'Income and expense report'),
            style: NovaFonts.heading.copyWith(
              fontSize: 16,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _tabBtn(context.tr('Chi tiêu', 'Expense'), true),
              const SizedBox(width: 10),
              _tabBtn(context.tr('Thu nhập', 'Income'), false),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(220, 220),
                      painter: _DonutPainter(
                        segments: displaySegments,
                        progress: _anim.value,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpense
                              ? context.tr('Đã tiêu', 'Spent')
                              : context.tr('Đã thu', 'Received'),
                          style: NovaFonts.body.copyWith(
                            fontSize: 12,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatShort(total),
                          style: NovaFonts.numbers.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 10,
                                color: theme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                segments.isEmpty ? '0%' : '100%',
                                style: NovaFonts.body.copyWith(
                                  fontSize: 10,
                                  color: theme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (segments.isEmpty)
            Center(
              child: Text(
                context.tr('Chưa có dữ liệu tháng này', 'No data this month'),
                style: NovaFonts.body.copyWith(
                  color: theme.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...segments.map((s) => _buildCategoryRow(s, fmt)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr('Xem chi tiết báo cáo', 'View detailed report'),
                    style: NovaFonts.body.copyWith(
                      color: theme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    LucideIcons.arrowRight,
                    size: 15,
                    color: theme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool isExpense) {
    final theme = NovaTheme.watch(context);
    final isActive = _isExpense == isExpense;
    return GestureDetector(
      onTap: () => setState(() {
        _isExpense = isExpense;
        _animController.forward(from: 0);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? theme.primary
                : theme.primaryMid,
          ),
        ),
        child: Text(
          label,
          style: NovaFonts.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : theme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(_Segment s, NumberFormat fmt) {
    final theme = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.label,
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: theme.textPrimary,
              ),
            ),
          ),
          Text(
            '${s.percent.toStringAsFixed(0)}%',
            style: NovaFonts.body.copyWith(
              fontSize: 13,
              color: s.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            fmt.format(s.value),
            style: NovaFonts.numbers.copyWith(
              fontSize: 13,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Line chart ───────────────────────────────────────
  Widget _buildLineChartSection(
    _MonthData data,
    NumberFormat fmt,
    List<String> monthNames,
  ) {
    final theme = NovaTheme.watch(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Biến động thu chi', 'Income and expense trends'),
            style: NovaFonts.heading.copyWith(
              fontSize: 16,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              height: 200,
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _LineChartPainter(
                  monthExpense: data.monthExpense,
                  monthIncome: data.monthIncome,
                  months: data.months
                      .map((m) => monthNames[m.month - 1])
                      .toList(),
                  progress: _anim.value,
                  highlightIndex: 5,
                  expenseColor: NovaColors.yellow,
                  incomeColor: theme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _lineLegend(NovaColors.yellow, context.tr('Chi tiêu', 'Expense')),
              const SizedBox(width: 24),
              _lineLegend(
                theme.primary,
                context.tr('Thu nhập', 'Income'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineLegend(Color color, String label) {
    final theme = NovaTheme.watch(context);
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: NovaFonts.body.copyWith(
            fontSize: 12,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatShort(double value) {
    if (value >= 1000000000) {
      return context.tr(
        '${(value / 1000000000).toStringAsFixed(1)} Tỷ',
        '${(value / 1000000000).toStringAsFixed(1)}B',
      );
    }
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)} Tr';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} N';
    return NumberFormat('#,###', 'vi_VN').format(value);
  }
}

// ─── Month Picker ─────────────────────────────────────────
class _MonthPickerSheet extends StatefulWidget {
  final DateTime selected;
  final void Function(DateTime) onSelected;
  const _MonthPickerSheet({required this.selected, required this.onSelected});

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _year, _month;

  @override
  void initState() {
    super.initState();
    _year = widget.selected.year;
    _month = widget.selected.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('Chọn thời gian hiển thị', 'Choose display period'),
                  style: NovaFonts.heading.copyWith(
                    fontSize: 16,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _year--),
                child: const Icon(
                  LucideIcons.chevronLeft,
                  color: NovaColors.textPrimary,
                ),
              ),
              Text(
                context.tr('Năm $_year', 'Year $_year'),
                style: NovaFonts.heading.copyWith(
                  fontSize: 16,
                  color: theme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_year < now.year) setState(() => _year++);
                },
                child: Icon(
                  LucideIcons.chevronRight,
                  color: _year < now.year
                      ? theme.textPrimary
                      : theme.primaryMid.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final m = i + 1;
              final isFuture = _year == now.year && m > now.month;
              final isSel = m == _month && _year == widget.selected.year;
              return GestureDetector(
                onTap: isFuture ? null : () => setState(() => _month = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSel ? theme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel
                          ? theme.primary
                          : isFuture
                          ? theme.primaryMid.withValues(alpha: 0.35)
                          : theme.primaryMid,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      context.tr('Tháng $m', 'Month $m'),
                      style: NovaFonts.body.copyWith(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.normal,
                        color: isSel
                            ? Colors.white
                            : isFuture
                            ? theme.primaryMid.withValues(alpha: 0.35)
                            : theme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.onSelected(DateTime(_year, _month));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(26)),
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
    );
  }
}

// ─── Data models & Painters (không đổi) ─────────────────
class _MonthData {
  final double totalExpense, totalIncome, prevExpense, prevIncome;
  final Map<String, double> expenseByCategory, incomeByCategory;
  final List<DateTime> months;
  final List<double> monthExpense, monthIncome;

  const _MonthData({
    required this.totalExpense,
    required this.totalIncome,
    required this.prevExpense,
    required this.prevIncome,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.months,
    required this.monthExpense,
    required this.monthIncome,
  });
}

class _Segment {
  final String label;
  final double value, percent;
  final Color color;
  final IconData icon;
  const _Segment({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.percent,
  });
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  final double progress;
  _DonutPainter({required this.segments, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0.0, (s, e) => s + e.value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 38.0;
    const gap = 0.03;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * 2 * math.pi * progress - gap;
      if (sweep <= 0) {
        startAngle += (seg.value / total) * 2 * math.pi * progress;
        continue;
      }
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );

      if (seg.percent >= 5 && progress > 0.8) {
        final midAngle = startAngle + sweep / 2;
        final lx = center.dx + radius * math.cos(midAngle);
        final ly = center.dy + radius * math.sin(midAngle);
        final tp = TextPainter(
          text: TextSpan(
            text: '${seg.percent.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }
      startAngle += (seg.value / total) * 2 * math.pi * progress;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.segments != segments;
}

class _LineChartPainter extends CustomPainter {
  final List<double> monthExpense, monthIncome;
  final List<String> months;
  final double progress;
  final int highlightIndex;
  final Color expenseColor, incomeColor;

  _LineChartPainter({
    required this.monthExpense,
    required this.monthIncome,
    required this.months,
    required this.progress,
    required this.highlightIndex,
    required this.expenseColor,
    required this.incomeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allVals = [...monthExpense, ...monthIncome];
    final maxVal = allVals.fold(0.0, (a, b) => a > b ? a : b);

    const padL = 52.0, padR = 16.0, padT = 20.0, padB = 36.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    final n = months.length;

    if (maxVal == 0) {
      _drawGrid(canvas, size, 0);
      _drawLabels(canvas, size, 0);
      return;
    }

    double xOf(int i) => padL + i / (n - 1) * w;
    double yOf(double v) => padT + h - (v / maxVal) * h;

    _drawGrid(canvas, size);

    // Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          incomeColor.withValues(alpha: 0.18),
          incomeColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, padT, size.width, h));
    final fillPath = Path()..moveTo(xOf(0), yOf(monthIncome[0]));
    for (int i = 1; i < n; i++) {
      fillPath.lineTo(xOf(i), yOf(monthIncome[i]));
    }
    fillPath
      ..lineTo(xOf(n - 1), padT + h)
      ..lineTo(xOf(0), padT + h)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    void drawLine(List<double> data, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      final drawUpTo = (n * progress).ceil().clamp(1, n);
      path.moveTo(xOf(0), yOf(data[0]));
      for (int i = 1; i < drawUpTo; i++) {
        path.lineTo(xOf(i), yOf(data[i]));
      }
      canvas.drawPath(path, paint);
      for (int i = 0; i < drawUpTo; i++) {
        final isHL = i == highlightIndex;
        canvas.drawCircle(
          Offset(xOf(i), yOf(data[i])),
          isHL ? 5.0 : 3.5,
          Paint()..color = color,
        );
        if (isHL) {
          canvas.drawCircle(
            Offset(xOf(i), yOf(data[i])),
            8.0,
            Paint()
              ..color = color.withValues(alpha: 0.2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }
    }

    drawLine(monthExpense, expenseColor);
    drawLine(monthIncome, incomeColor);
    _drawLabels(canvas, size, maxVal);
  }

  void _drawGrid(Canvas canvas, Size size, [double maxVal = 1]) {
    const padL = 52.0, padR = 16.0, padT = 20.0, padB = 36.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = padT + h - i / 4 * h;
      canvas.drawLine(Offset(padL, y), Offset(padL + w, y), gridPaint);
      if (maxVal > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: _fmt(maxVal * i / 4),
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(0, y - tp.height / 2));
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size, double maxVal) {
    const padL = 52.0, padR = 16.0, padT = 20.0, padB = 36.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    final n = months.length;
    for (int i = 0; i < n; i++) {
      final x = padL + i / (n - 1) * w;
      final isHL = i == highlightIndex;
      final tp = TextPainter(
        text: TextSpan(
          text: months[i],
          style: TextStyle(
            color: isHL ? incomeColor : const Color(0xFFAAAAAA),
            fontSize: 10,
            fontWeight: isHL ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, padT + h + 8));
    }
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}Tr';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}N';
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.progress != progress ||
      old.monthExpense != monthExpense ||
      old.monthIncome != monthIncome;
}
