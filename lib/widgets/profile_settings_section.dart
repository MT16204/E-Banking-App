import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileSettingsItem {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileSettingsItem(
    this.icon,
    this.label, {
    this.trailing,
    this.onTap,
  });
}

class ProfileSettingsSection extends StatelessWidget {
  final String title;
  final List<ProfileSettingsItem> items;

  const ProfileSettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: NovaFonts.heading.copyWith(
                fontSize: 10,
                color: theme.textSecondary,
                letterSpacing: 1.8,
              ),
            ),
          ),
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
            child: Column(
              children: items.asMap().entries.map((entry) {
                final isFirst = entry.key == 0;
                final isLast = entry.key == items.length - 1;
                final item = entry.value;
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.vertical(
                          top: isFirst
                              ? const Radius.circular(20)
                              : Radius.zero,
                          bottom: isLast
                              ? const Radius.circular(20)
                              : Radius.zero,
                        ),
                        onTap: item.onTap ?? () {},
                        splashColor: theme.primaryLight,
                        highlightColor: theme.primaryLight.withValues(alpha: 0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: theme.primaryLight,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 17,
                                  color: theme.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: NovaFonts.body.copyWith(
                                    fontSize: 15,
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              item.trailing ??
                                  Icon(
                                    LucideIcons.chevronRight,
                                    size: 15,
                                    color: theme.textSecondary,
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 68,
                        endIndent: 16,
                        color: NovaColors.divider,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
