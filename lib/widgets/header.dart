import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/colors.dart';
import '../core/theme/fonts.dart';

/// - [Header.withTitle]
/// - [Header.iconOnly] 
class Header extends StatelessWidget {
  final VoidCallback? onBack;
  final String? title;
  final Widget? action;
  final bool _iconOnly;
  final bool _centerTitle;

  const Header._({
    required this.onBack,
    this.title,
    this.action,
    required bool iconOnly,
    required bool centerTitle,
  }) : _iconOnly = iconOnly,
       _centerTitle = centerTitle;

  factory Header.withTitle({
    required String title,
    VoidCallback? onBack,
    Widget? action,
    bool centerTitle = true,
  }) => Header._(
    onBack: onBack,
    title: title,
    action: action,
    iconOnly: false,
    centerTitle: centerTitle,
  );

  factory Header.iconOnly({VoidCallback? onBack, Widget? action}) =>
      Header._(
        onBack: onBack,
        action: action,
        iconOnly: true,
        centerTitle: false,
      );

  factory Header.inline({
    required String title,
    VoidCallback? onBack,
    Widget? action,
    bool centerTitle = true,
  }) => Header._(
    onBack: onBack,
    title: title,
    action: action,
    iconOnly: false,
    centerTitle: centerTitle,
  );

  @override
  Widget build(BuildContext context) {
    const double sideMinWidth = 48;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: _centerTitle ? _buildCenteredHeader(context, sideMinWidth) : _buildLeadingHeader(context, sideMinWidth),
    );
  }

  Widget _buildCenteredHeader(BuildContext context, double sideMinWidth) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: sideMinWidth),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                  ),
                ),
              ),
              const Spacer(),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: sideMinWidth),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: action,
                ),
              ),
            ],
          ),
          if (!_iconOnly && title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Text(
                title!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NovaFonts.heading.copyWith(
                  fontSize: 18,
                  color: NovaColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeadingHeader(BuildContext context, double sideMinWidth) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: sideMinWidth),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                onPressed: onBack ?? () => Navigator.maybePop(context),
              ),
            ),
          ),
          if (!_iconOnly && title != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NovaFonts.heading.copyWith(
                  fontSize: 18,
                  color: NovaColors.textPrimary,
                ),
              ),
            ),
          ] else
            const Spacer(),
          if (action != null) ...[
            const SizedBox(width: 12),
            action!,
          ],
        ],
      ),
    );
  }
}
