import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/widgets/app_appearance_widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String greeting;
  final String displayName;
  final String displayEmail;
  final VoidCallback onTap;

  const ProfileAvatarSection({
    super.key,
    required this.greeting,
    required this.displayName,
    required this.displayEmail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              AppAvatar(radius: 44, displayName: displayName),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          greeting,
          style: NovaFonts.body.copyWith(
            color: theme.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          displayName.toUpperCase(),
          style: NovaFonts.heading.copyWith(
            color: theme.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        if (displayEmail.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            displayEmail,
            style: NovaFonts.body.copyWith(
              color: theme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
