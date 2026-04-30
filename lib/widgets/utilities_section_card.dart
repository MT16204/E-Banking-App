import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class UtilitiesGridItem {
  final String label;
  final IconData icon;
  final String? badge;

  const UtilitiesGridItem({
    required this.label,
    required this.icon,
    this.badge,
  });
}

class UtilitiesGridSection {
  final String title;
  final List<UtilitiesGridItem> items;

  const UtilitiesGridSection({
    required this.title,
    required this.items,
  });
}

class UtilitiesSectionCard extends StatelessWidget {
  final UtilitiesGridSection section;
  final void Function(UtilitiesGridItem item) onItemTap;

  const UtilitiesSectionCard({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [theme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: NovaFonts.heading.copyWith(
              fontSize: 14,
              color: theme.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: section.items.length,
            itemBuilder: (_, j) => _UtilitiesGridItemButton(
              item: section.items[j],
              onTap: () => onItemTap(section.items[j]),
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilitiesGridItemButton extends StatelessWidget {
  final UtilitiesGridItem item;
  final VoidCallback onTap;

  const _UtilitiesGridItemButton({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 24, color: theme.primary),
              ),
              if (item.badge != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge!,
                      style: NovaFonts.body.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: NovaFonts.body.copyWith(
              fontSize: 11,
              color: theme.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
