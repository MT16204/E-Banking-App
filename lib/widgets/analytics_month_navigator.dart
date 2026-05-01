import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticsMonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final bool isCurrentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const AnalyticsMonthNavigator({
    super.key,
    required this.selectedMonth,
    required this.isCurrentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: onPrevious,
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
                    'Tháng ${selectedMonth.month}, ${selectedMonth.year}',
                    'Month ${selectedMonth.month}, ${selectedMonth.year}',
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
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: isCurrentMonth
                    ? theme.primaryMid.withValues(alpha: 0.35)
                    : theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
