import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const NotificationSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          style: NovaFonts.body.copyWith(
            fontSize: 14,
            color: theme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: context.tr(
              'Tìm kiếm thông báo, giao dịch...',
              'Search notifications, transactions...',
            ),
            hintStyle: NovaFonts.body.copyWith(
              color: theme.textSecondary,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                LucideIcons.search,
                size: 18,
                color: theme.textSecondary,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }
}
