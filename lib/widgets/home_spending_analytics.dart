import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeSpendingAnalytics extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String userId;
  final DateTime analyticsMonth;
  final bool balanceHidden;
  final VoidCallback onMonthTap;
  final VoidCallback onDetailsTap;

  const HomeSpendingAnalytics({
    super.key,
    required this.transactions,
    required this.userId,
    required this.analyticsMonth,
    required this.balanceHidden,
    required this.onMonthTap,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final fmt = NumberFormat('#,###', 'vi_VN');
    final months = List.generate(
      6,
      (i) => DateTime(analyticsMonth.year, analyticsMonth.month - 5 + i),
    );
    final income = List.filled(6, 0.0);
    final expense = List.filled(6, 0.0);

    for (final transaction in transactions) {
      for (int i = 0; i < 6; i++) {
        if (transaction.createdAt.month == months[i].month &&
            transaction.createdAt.year == months[i].year) {
          if (transaction.receiverId == userId) income[i] += transaction.amount;
          if (transaction.senderId == userId) expense[i] += transaction.amount;
        }
      }
    }

    final thisMonthIncome = income.last;
    final thisMonthExpense = expense.last;
    final maxValue = [...income, ...expense].fold(
      0.0,
      (a, b) => a > b ? a : b,
    );
    const monthNames = [
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
                        balanceHidden
                            ? '••••••'
                            : '${fmt.format(thisMonthExpense)} đ',
                        key: ValueKey(balanceHidden),
                        style: NovaFonts.numbers.copyWith(
                          fontSize: 22,
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w300,
                          letterSpacing: balanceHidden ? 3 : 0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onMonthTap,
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
                        'T${analyticsMonth.month}/${analyticsMonth.year}',
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
                final isCurrent = i == 5;
                final incomeHeight = maxValue > 0
                    ? (income[i] / maxValue) * 100
                    : 4.0;
                final expenseHeight = maxValue > 0
                    ? (expense[i] / maxValue) * 100
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
                              duration: Duration(milliseconds: 400 + i * 60),
                              curve: Curves.easeOut,
                              width: 8,
                              height: incomeHeight.clamp(4, 88),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? theme.primary
                                    : theme.primary.withValues(alpha: 0.25),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 400 + i * 60),
                              curve: Curves.easeOut,
                              width: 8,
                              height: expenseHeight.clamp(4, 88),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? NovaColors.yellow
                                    : NovaColors.yellow.withValues(alpha: 0.12),
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
                            color: isCurrent ? theme.primary : theme.textSecondary,
                            fontWeight: isCurrent
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
          Container(height: 1, color: theme.primaryMid.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Row(
            children: [
              _LegendDot(
                color: NovaColors.primaryGreen,
                label: context.tr('Thu nhập', 'Income'),
              ),
              const SizedBox(width: 16),
              _LegendDot(
                color: NovaColors.yellow,
                label: context.tr('Chi tiêu', 'Expense'),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDetailsTap,
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
                child: _SummaryChip(
                  icon: LucideIcons.arrowDownLeft,
                  label: context.tr('Thu nhập', 'Income'),
                  value: balanceHidden
                      ? '••••••'
                      : '+${fmt.format(thisMonthIncome)} đ',
                  color: theme.primary,
                  backgroundColor: theme.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  icon: LucideIcons.arrowUpRight,
                  label: context.tr('Chi tiêu', 'Expense'),
                  value: balanceHidden
                      ? '••••••'
                      : '-${fmt.format(thisMonthExpense)} đ',
                  color: theme.textPrimary,
                  backgroundColor: theme.background,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
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
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
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
}
