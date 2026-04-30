import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class TransferFastToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const TransferFastToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.tr('Chuyển tiền nhanh', 'Fast transfer'),
              style: NovaFonts.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.primary,
            activeTrackColor: theme.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
