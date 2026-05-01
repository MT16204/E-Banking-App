import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class NotificationEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const NotificationEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: theme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: NovaFonts.body.copyWith(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
