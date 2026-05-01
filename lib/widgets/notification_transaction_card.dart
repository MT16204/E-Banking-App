import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationDateBadge extends StatelessWidget {
  final String date;

  const NotificationDateBadge({super.key, required this.date});

  String get _label {
    final now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final yesterday = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now().subtract(const Duration(days: 1)));
    if (date == now) return 'today_key';
    if (date == yesterday) return 'yesterday_key';
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: theme.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _label == 'today_key'
              ? context.tr('Hôm nay', 'Today')
              : _label == 'yesterday_key'
              ? context.tr('Hôm qua', 'Yesterday')
              : _label,
          style: NovaFonts.body.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.primary,
          ),
        ),
      ),
    );
  }
}

class NotificationTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String userId;
  final WalletModel? wallet;

  const NotificationTransactionCard({
    super.key,
    required this.transaction,
    required this.userId,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final isIn = transaction.receiverId == userId;
    final fmt = NumberFormat('#,###', 'vi_VN');
    final amountString = '${isIn ? '+' : '-'}${fmt.format(transaction.amount)} VND';
    final amountColor = isIn ? theme.primary : NovaColors.error;
    final timeString = DateFormat('HH:mm:ss').format(
      transaction.createdAt.toLocal(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeString,
                  style: NovaFonts.body.copyWith(
                    fontSize: 12,
                    color: theme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.checkCircle2,
                    size: 11,
                    color: theme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              context.tr('Nova Banking thông báo', 'Nova Banking notification'),
              style: NovaFonts.heading.copyWith(
                fontSize: 14,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: theme.primaryLight),
            const SizedBox(height: 10),
            _NotificationInfoRow(
              label: context.tr('Tài khoản', 'Account'),
              value: wallet?.accountNumber ?? 'N/A',
            ),
            _NotificationInfoRow(
              label: context.tr('Số tiền', 'Amount'),
              value: amountString,
              valueColor: amountColor,
              bold: true,
            ),
            _NotificationInfoRow(
              label: context.tr('Số dư cuối', 'Ending balance'),
              value: '${fmt.format(transaction.balanceAfter)} VND',
            ),
            _NotificationInfoRow(
              label: context.tr('Nội dung', 'Description'),
              value: transaction.description?.isNotEmpty == true
                  ? transaction.description!
                  : '—',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _NotificationInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: theme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: valueColor ?? theme.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
