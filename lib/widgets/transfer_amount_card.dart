import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferAmountCard extends StatelessWidget {
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<int> onQuickAmountTap;

  const TransferAmountCard({
    super.key,
    required this.controller,
    required this.inputFormatters,
    required this.onQuickAmountTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('Số tiền chuyển (VND)', 'Transfer amount (VND)'),
                style: NovaFonts.body.copyWith(
                  color: theme.textSecondary,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFF1A5C4A),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('Hạn mức', 'Limit'),
                    style: NovaFonts.body.copyWith(
                      color: theme.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: inputFormatters,
            style: NovaFonts.numbers.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: NovaFonts.numbers.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: theme.primaryMid,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickAmountButton(
                  label: '50K',
                  onTap: () => onQuickAmountTap(50000),
                ),
                const SizedBox(width: 8),
                _QuickAmountButton(
                  label: '100K',
                  onTap: () => onQuickAmountTap(100000),
                ),
                const SizedBox(width: 8),
                _QuickAmountButton(
                  label: '200K',
                  onTap: () => onQuickAmountTap(200000),
                ),
                const SizedBox(width: 8),
                _QuickAmountButton(
                  label: '500K',
                  onTap: () => onQuickAmountTap(500000),
                ),
                const SizedBox(width: 8),
                _QuickAmountButton(
                  label: '1TR',
                  onTap: () => onQuickAmountTap(1000000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryMid),
        ),
        child: Text(
          label,
          style: NovaFonts.body.copyWith(
            color: theme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
