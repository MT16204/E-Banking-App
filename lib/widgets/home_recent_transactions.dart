import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeRecentTransactions extends StatelessWidget {
  final String? userId;
  final List<TransactionModel> transactions;
  final bool balanceHidden;
  final VoidCallback onViewAll;

  const HomeRecentTransactions({
    super.key,
    required this.userId,
    required this.transactions,
    required this.balanceHidden,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
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
              onTap: userId != null ? onViewAll : null,
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
                  children: transactions.take(4).map((transaction) {
                    final isReceived = transaction.receiverId == userId;
                    final isLast = transaction == transactions.take(4).last;
                    final description =
                        transaction.description ??
                        (isReceived
                            ? context.tr('Nhận tiền', 'Money received')
                            : context.tr('Chuyển tiền', 'Money transfer'));
                    final dateString = DateFormat(
                      'dd/MM/yyyy',
                    ).format(transaction.createdAt);
                    final amountString = balanceHidden
                        ? '••••••'
                        : '${isReceived ? '+' : '-'}${fmt.format(transaction.amount)} VND';

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
                                      description,
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
                                      dateString,
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
                                      amountString,
                                      key: ValueKey(amountString),
                                      style: NovaFonts.numbers.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isReceived
                                            ? theme.primary
                                            : theme.textPrimary,
                                        letterSpacing: balanceHidden ? 2 : 0,
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
