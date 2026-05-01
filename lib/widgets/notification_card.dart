import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isVietnamese;
  final Future<void> Function() onDelete;
  final String Function(NotificationModel notification, bool isVietnamese)
  getTitle;
  final String Function(NotificationModel notification, bool isVietnamese)
  getContent;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isVietnamese,
    required this.onDelete,
    required this.getTitle,
    required this.getContent,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = NovaTheme.watch(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.primaryMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(LucideIcons.copy, color: theme.textPrimary, size: 20),
                title: Text(
                  context.tr('Sao chép nội dung', 'Copy content'),
                  style: NovaFonts.body.copyWith(fontSize: 14),
                ),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: getContent(notification, isVietnamese)),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  LucideIcons.trash2,
                  color: NovaColors.error,
                  size: 20,
                ),
                title: Text(
                  context.tr('Xoá thông báo', 'Delete notification'),
                  style: NovaFonts.body.copyWith(
                    fontSize: 14,
                    color: NovaColors.error,
                  ),
                ),
                onTap: () async {
                  await onDelete();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final isUnread = !notification.isRead;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isUnread
            ? Border.all(color: theme.primary.withValues(alpha: 0.3), width: 1)
            : null,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.primaryLight,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(LucideIcons.bell, size: 20, color: theme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          getTitle(notification, isVietnamese),
                          style: NovaFonts.heading.copyWith(
                            fontSize: 13,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getContent(notification, isVietnamese),
                    style: NovaFonts.body.copyWith(
                      fontSize: 13,
                      color: theme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'HH:mm • dd/MM/yyyy',
                    ).format(notification.createdAt),
                    style: NovaFonts.body.copyWith(
                      fontSize: 11,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showOptions(context),
              child: Icon(
                LucideIcons.moreVertical,
                size: 18,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
