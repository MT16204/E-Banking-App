import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TransferSourceCard extends StatelessWidget {
  final Color primaryColor;
  final String accountLabel;
  final String balanceLabel;
  final num balance;

  const TransferSourceCard({
    super.key,
    required this.primaryColor,
    required this.accountLabel,
    required this.balanceLabel,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.user,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountLabel,
                  style: NovaFonts.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$balanceLabel: ${fmt.format(balance)} VND',
                  style: NovaFonts.body.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronDown, color: Colors.white70),
        ],
      ),
    );
  }
}
