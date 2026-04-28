import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../providers/appearance_provider.dart';
import '../providers/language_provider.dart';
import '../core/theme/colors.dart';
import '../core/theme/fonts.dart';

Future<void> showAvatarSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _AvatarSheet(),
  );
}

Future<void> showThemeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ThemeSheet(),
  );
}

// =============================================================================
// Shared bottom sheet wrapper
// =============================================================================

class _SheetWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double maxHeightFactor;

  const _SheetWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
    this.maxHeightFactor = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NovaColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NovaFonts.heading.copyWith(
                    fontSize: 20,
                    color: t.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: NovaFonts.body.copyWith(
                    fontSize: 13,
                    color: t.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: t.primaryLight),
          Flexible(child: child),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

// =============================================================================
// Avatar Sheet
// =============================================================================

class _AvatarSheet extends StatefulWidget {
  const _AvatarSheet();

  @override
  State<_AvatarSheet> createState() => _AvatarSheetState();
}

class _AvatarSheetState extends State<_AvatarSheet> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = context.read<AppearanceProvider>().avatarId;
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    final isVi = context.watch<LanguageProvider>().isVietnamese;
    return _SheetWrapper(
      title: isVi ? 'Đổi ảnh đại diện' : 'Change avatar',
      subtitle: isVi
          ? 'Chọn một avatar phù hợp với phong cách của bạn.'
          : 'Pick an avatar that matches your style.',
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemCount: kAvatarPresets.length,
        itemBuilder: (context, i) {
          final preset = kAvatarPresets[i];
          final selected = preset.id == _selectedId;

          return GestureDetector(
            onTap: () async {
              setState(() => _selectedId = preset.id);
              await context.read<AppearanceProvider>().setAvatar(preset.id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: preset.bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? t.primary : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: t.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: preset.id == 'initial'
                        ? Text(
                            'A',
                            style: NovaFonts.heading.copyWith(
                              fontSize: 24,
                              color: t.primary,
                            ),
                          )
                        : Text(
                            preset.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  preset.label,
                  style: NovaFonts.body.copyWith(
                    fontSize: 11,
                    color: selected ? t.primary : t.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Theme Sheet
// =============================================================================

class _ThemeSheet extends StatefulWidget {
  const _ThemeSheet();

  @override
  State<_ThemeSheet> createState() => _ThemeSheetState();
}

class _ThemeSheetState extends State<_ThemeSheet> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = context.read<AppearanceProvider>().themeId;
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    final isVi = context.watch<LanguageProvider>().isVietnamese;
    return _SheetWrapper(
      title: isVi ? 'Đổi giao diện' : 'Change theme',
      subtitle: isVi
          ? 'Chọn màu sắc chủ đạo cho trải nghiệm của bạn.'
          : 'Choose the primary color palette for your experience.',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        itemCount: kThemePresets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final preset = kThemePresets[i];
          final selected = preset.id == _selectedId;

          return GestureDetector(
            onTap: () async {
              setState(() => _selectedId = preset.id);
              await context.read<AppearanceProvider>().setTheme(preset.id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected ? preset.primaryLight : t.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? preset.primary : NovaColors.divider,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: preset.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: preset.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Label + color dots
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.label,
                          style: NovaFonts.body.copyWith(
                            fontSize: 15,
                            color: t.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _colorDot(preset.primary),
                            const SizedBox(width: 6),
                            _colorDot(preset.primaryLight),
                            const SizedBox(width: 6),
                            _colorDot(preset.primaryMid),
                            const SizedBox(width: 6),
                            _colorDot(preset.background),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: preset.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: t.textSecondary,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _colorDot(Color color) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
    ),
  );
}
