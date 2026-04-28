import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 44,
        right: 44,
        top: 12,
        bottom: bottomPadding > 0 ? bottomPadding + 8 : 20,
      ),
      child: _LiquidGlassDock(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liquid Glass Dock — 6 lớp chồng nhau
// ---------------------------------------------------------------------------
class _LiquidGlassDock extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const _LiquidGlassDock({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Layer 1: BackdropFilter blur + màu dock đặc ───────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: NovaColors.dockBackground,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),

        // ── Layer 2: Specular highlight — ánh sáng trên bề mặt kính ───────
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.18, 0.55, 1.0],
                colors: [
                  Colors.white.withValues(alpha: 0.22),
                  Colors.white.withValues(alpha: 0.06),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.06),
                ],
              ),
            ),
          ),
        ),

        // ── Layer 3: Viền trong sáng (inner stroke) ───────────────────────
        Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1.0,
            ),
          ),
        ),

        // ── Layer 4: Viền đáy tối — chiều dày vật lý của kính ────────────
        Positioned(
          left: 1,
          right: 1,
          bottom: 0,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: 0.12),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),

        // ── Layer 5: Outer shadow ─────────────────────────────────────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: -2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ),

        // ── Layer 6: Nav items ────────────────────────────────────────────
        SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: LucideIcons.home,
                index: 0,
                selectedIndex: selectedIndex,
                onTap: onItemTapped,
              ),
              _NavItem(
                icon: LucideIcons.pieChart,
                index: 1,
                selectedIndex: selectedIndex,
                onTap: onItemTapped,
              ),
              _NavItem(
                icon: LucideIcons.creditCard,
                index: 3,
                selectedIndex: selectedIndex,
                onTap: onItemTapped,
              ),
              _NavItem(
                icon: LucideIcons.user,
                index: 4,
                selectedIndex: selectedIndex,
                onTap: onItemTapped,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  bool get _isActive => selectedIndex == index;

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: _isActive ? 48 : 40,
        height: _isActive ? 48 : 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary.withValues(alpha: 0.95),
                    Color.lerp(theme.primary, Colors.black, 0.18)!,
                  ],
                )
              : null,
          color: _isActive ? null : Colors.transparent,
          boxShadow: _isActive
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.50),
                    blurRadius: 18,
                    spreadRadius: -2,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: AnimatedScale(
          scale: _isActive ? 1.0 : 0.88,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          child: Icon(
            icon,
            size: 22,
            color: _isActive ? Colors.white : theme.inactiveIcon,
          ),
        ),
      ),
    );
  }
}
