import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeQuickActionsSection extends StatelessWidget {
  final VoidCallback onTransferTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onScanTap;
  final VoidCallback onMoreTap;

  const HomeQuickActionsSection({
    super.key,
    required this.onTransferTap,
    required this.onHistoryTap,
    required this.onScanTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
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
            _QuickActionButton(
              icon: LucideIcons.arrowLeftRight,
              label: context.tr('Chuyển\ntiền', 'Transfer'),
              isPrimary: true,
              onTap: onTransferTap,
            ),
            _QuickActionButton(
              icon: LucideIcons.history,
              label: context.tr('Lịch sử', 'History'),
              onTap: onHistoryTap,
            ),
            _QuickActionButton(
              icon: LucideIcons.scanLine,
              label: context.tr('Quét mã', 'Scan'),
              onTap: onScanTap,
            ),
            _QuickActionButton(
              icon: LucideIcons.moreHorizontal,
              label: context.tr('Khác', 'More'),
              onTap: onMoreTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isPrimary ? theme.primary : theme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: isPrimary
                      ? theme.primary.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: isPrimary ? Colors.white : theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: NovaFonts.body.copyWith(
              fontSize: 11,
              color: theme.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
