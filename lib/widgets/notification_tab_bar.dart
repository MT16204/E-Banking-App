import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class NotificationTabBar extends StatelessWidget {
  final TabController controller;

  const NotificationTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: theme.textSecondary,
          labelStyle: NovaFonts.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: NovaFonts.body.copyWith(fontSize: 13),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          tabs: [
            Tab(text: context.tr('Của tôi', 'Mine')),
            Tab(text: context.tr('Biến động', 'Activity')),
          ],
        ),
      ),
    );
  }
}
