import 'dart:math' as math;

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticsSummaryOverview extends StatelessWidget {
  final double totalExpense;
  final double totalIncome;
  final double prevExpense;
  final double prevIncome;
  final String balanceText;
  final Animation<double> animation;
  final String Function(double value) formatShort;

  const AnalyticsSummaryOverview({
    super.key,
    required this.totalExpense,
    required this.totalIncome,
    required this.prevExpense,
    required this.prevIncome,
    required this.balanceText,
    required this.animation,
    required this.formatShort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final expenseChange = prevExpense > 0
        ? (totalExpense - prevExpense) / prevExpense * 100
        : (totalExpense > 0 ? 100.0 : 0.0);
    final incomeChange = prevIncome > 0
        ? (totalIncome - prevIncome) / prevIncome * 100
        : (totalIncome > 0 ? 100.0 : 0.0);

    final maxValue = math.max(totalExpense, totalIncome);
    final expenseHeight = maxValue > 0 ? totalExpense / maxValue : 0.5;
    final incomeHeight = maxValue > 0 ? totalIncome / maxValue : 0.5;
    const maxBarHeight = 140.0;

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
        Text(
          balanceText,
          style: NovaFonts.body.copyWith(
            fontSize: 13,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _AnalyticsBarColumn(
                label: context.tr('Chi tiêu', 'Expense'),
                value: totalExpense,
                change: expenseChange,
                barHeight: maxBarHeight * expenseHeight,
                color: NovaColors.yellow,
                animation: animation,
                formatShort: formatShort,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _AnalyticsBarColumn(
                label: context.tr('Thu nhập', 'Income'),
                value: totalIncome,
                change: incomeChange,
                barHeight: maxBarHeight * incomeHeight,
                color: theme.primary,
                animation: animation,
                formatShort: formatShort,
              ),
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
              Icon(LucideIcons.trendingUp, size: 16, color: theme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  expenseChange >= 0
                      ? context.tr(
                          'Chi tiêu tăng ${expenseChange.toStringAsFixed(0)}% so với tháng trước',
                          'Expenses increased ${expenseChange.toStringAsFixed(0)}% from last month',
                        )
                      : context.tr(
                          'Chi tiêu giảm ${expenseChange.abs().toStringAsFixed(0)}% so với tháng trước',
                          'Expenses decreased ${expenseChange.abs().toStringAsFixed(0)}% from last month',
                        ),
                  style: NovaFonts.body.copyWith(
                    fontSize: 12,
                    color: theme.primary,
                  ),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 14, color: theme.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsBarColumn extends StatelessWidget {
  final String label;
  final double value;
  final double change;
  final double barHeight;
  final Color color;
  final Animation<double> animation;
  final String Function(double value) formatShort;

  const _AnalyticsBarColumn({
    required this.label,
    required this.value,
    required this.change,
    required this.barHeight,
    required this.color,
    required this.animation,
    required this.formatShort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final isUp = change >= 0;
    final height = barHeight.clamp(30.0, 140.0);
    return Column(
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
                formatShort(value),
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
          animation: animation,
          builder: (_, __) => Container(
            width: double.infinity,
            height: height * animation.value,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
    );
  }
}
