import 'dart:ui';

import 'package:banking_app/providers/appearance_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/colors.dart';
import '../core/theme/fonts.dart';

class AuthScene extends StatelessWidget {
  final Widget child;
  final Widget? topBar;

  const AuthScene({super.key, required this.child, this.topBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackdrop()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (topBar != null) topBar!,
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthTopBar extends StatelessWidget {
  final bool showBack;

  const AuthTopBar({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final palette = _authPaletteFor(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.surfaceTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: palette.surfaceBorder,
                  ),
                ),
                child: Icon(
                  LucideIcons.arrowLeft,
                  color: palette.primaryText,
                  size: 18,
                ),
              ),
            )
          else
            const SizedBox(width: 42, height: 42),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surfaceTint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.surfaceBorder),
            ),
            child: Text(
              'NOVA',
              style: NovaFonts.heading.copyWith(
                fontSize: 12,
                color: palette.primaryText,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final List<String> chips;

  const AuthHero({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.chips = const [],
  });

  @override
  Widget build(BuildContext context) {
    final palette = _authPaletteFor(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: NovaFonts.body.copyWith(
              color: palette.secondaryText,
              fontSize: 12,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: NovaFonts.heading.copyWith(
              color: palette.primaryText,
              fontSize: 30,
              letterSpacing: -0.8,
              height: 1.08,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: NovaFonts.body.copyWith(
                color: palette.secondaryText,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: chips.map((chip) => _HeroChip(label: chip, palette: palette)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class AuthPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AuthPanel({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AuthSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: NovaFonts.heading.copyWith(
            fontSize: 24,
            color: NovaColors.textPrimary,
            letterSpacing: -0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: NovaFonts.body.copyWith(
            color: NovaColors.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const AuthInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: NovaColors.primaryGreen,
      style: NovaFonts.body.copyWith(
        color: NovaColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: NovaColors.primaryGreen, size: 18),
        suffixIcon: suffix,
        labelStyle: NovaFonts.body.copyWith(
          color: NovaColors.textSecondary,
          fontSize: 13,
        ),
        hintStyle: NovaFonts.body.copyWith(
          color: NovaColors.textSecondary.withValues(alpha: 0.75),
          fontSize: 14,
        ),
        errorStyle: NovaFonts.body.copyWith(
          color: NovaColors.error,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: NovaColors.primaryGreenMid),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: NovaColors.primaryGreenMid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: NovaColors.primaryGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: NovaColors.primaryGreen,
          disabledBackgroundColor: NovaColors.primaryGreen.withValues(
            alpha: 0.4,
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: NovaFonts.heading.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class AuthSecondaryTextButton extends StatelessWidget {
  final String leading;
  final String action;
  final VoidCallback onPressed;

  const AuthSecondaryTextButton({
    super.key,
    required this.leading,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: RichText(
        text: TextSpan(
          style: NovaFonts.body.copyWith(
            color: NovaColors.textSecondary,
            fontSize: 13,
          ),
          children: [
            TextSpan(text: leading),
            TextSpan(
              text: action,
              style: NovaFonts.body.copyWith(
                color: NovaColors.primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    final preset = context.watch<AppearanceProvider>().currentBackground;
    final palette = _authPaletteFor(context);
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: preset.colors,
                stops: preset.stops,
                begin: preset.begin,
                end: preset.end,
              ),
            ),
          ),
        ),
        if (preset.pattern != BackgroundPattern.none && preset.patternColor != null)
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _AuthPatternPainter(
                  pattern: preset.pattern,
                  color: preset.patternColor!,
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: palette.topScrim,
                  stops: const [0, 0.52, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -10,
          child: _shape(220, 220, palette.shapeStrong),
        ),
        Positioned(
          top: 110,
          right: 40,
          child: _shape(180, 180, palette.shapeMedium),
        ),
        Positioned(
          top: 180,
          left: -70,
          child: _shape(240, 240, palette.shapeSoft),
        ),
        Positioned(
          bottom: 260,
          right: -50,
          child: _shape(
            160,
            160,
            palette.accentShape,
          ),
        ),
      ],
    );
  }

  Widget _shape(double width, double height, Color color) {
    return Transform.rotate(
      angle: -0.35,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(42),
        ),
      ),
    );
  }
}

class _AuthPatternPainter extends CustomPainter {
  final BackgroundPattern pattern;
  final Color color;

  const _AuthPatternPainter({required this.pattern, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    switch (pattern) {
      case BackgroundPattern.dots:
        _drawDots(canvas, size, paint);
      case BackgroundPattern.lines:
        _drawLines(canvas, size, paint);
      case BackgroundPattern.circles:
        _drawCircles(canvas, size, paint);
      case BackgroundPattern.grid:
        _drawGrid(canvas, size, paint);
      case BackgroundPattern.waves:
        _drawWaves(canvas, size, paint);
      case BackgroundPattern.none:
        break;
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 22.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2.0, paint);
      }
    }
  }

  void _drawLines(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 1;
    const spacing = 20.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    final center = Offset(size.width * 0.7, size.height * 0.25);
    for (double r = 40; r < size.width * 1.2; r += 50) {
      canvas.drawCircle(center, r, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 0.8;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    const amplitude = 8.0;
    const period = 40.0;
    const spacing = 24.0;
    for (
      double yBase = spacing;
      yBase < size.height + spacing;
      yBase += spacing
    ) {
      final path = Path();
      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 2) {
        final t = x / period * 2 * 3.14159;
        final y = yBase + amplitude * _sin(t);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_AuthPatternPainter old) =>
      old.pattern != pattern || old.color != color;
}

double _sin(double x) {
  x = x % (2 * 3.14159);
  return (x - (x * x * x) / 6 + (x * x * x * x * x) / 120).clamp(-1.0, 1.0);
}

class _HeroChip extends StatelessWidget {
  final String label;
  final _AuthPalette palette;

  const _HeroChip({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Text(
        label,
        style: NovaFonts.body.copyWith(
          color: palette.primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AuthPalette {
  final Color primaryText;
  final Color secondaryText;
  final Color surfaceTint;
  final Color surfaceBorder;
  final List<Color> topScrim;
  final Color shapeStrong;
  final Color shapeMedium;
  final Color shapeSoft;
  final Color accentShape;

  const _AuthPalette({
    required this.primaryText,
    required this.secondaryText,
    required this.surfaceTint,
    required this.surfaceBorder,
    required this.topScrim,
    required this.shapeStrong,
    required this.shapeMedium,
    required this.shapeSoft,
    required this.accentShape,
  });
}

_AuthPalette _authPaletteFor(BuildContext context) {
  final preset = context.watch<AppearanceProvider>().currentBackground;
  final avg = _averageColor(preset.colors);
  final isLight = avg.computeLuminance() > 0.62;

  if (isLight) {
    return _AuthPalette(
      primaryText: const Color(0xFF111111),
      secondaryText: const Color(0xCC111111),
      surfaceTint: Colors.white.withValues(alpha: 0.72),
      surfaceBorder: Colors.black.withValues(alpha: 0.08),
      topScrim: [
        Colors.black.withValues(alpha: 0.16),
        Colors.black.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      shapeStrong: Colors.black.withValues(alpha: 0.06),
      shapeMedium: Colors.black.withValues(alpha: 0.045),
      shapeSoft: Colors.black.withValues(alpha: 0.03),
      accentShape: NovaColors.primaryGreen.withValues(alpha: 0.1),
    );
  }

  return _AuthPalette(
    primaryText: Colors.white,
    secondaryText: Colors.white.withValues(alpha: 0.78),
    surfaceTint: Colors.white.withValues(alpha: 0.12),
    surfaceBorder: Colors.white.withValues(alpha: 0.1),
    topScrim: [
      Colors.black.withValues(alpha: 0.2),
      Colors.black.withValues(alpha: 0.07),
      Colors.transparent,
    ],
    shapeStrong: Colors.white.withValues(alpha: 0.1),
    shapeMedium: Colors.white.withValues(alpha: 0.08),
    shapeSoft: Colors.white.withValues(alpha: 0.06),
    accentShape: NovaColors.primaryGreenMid.withValues(alpha: 0.12),
  );
}

Color _averageColor(List<Color> colors) {
  if (colors.isEmpty) return Colors.white;
  var r = 0;
  var g = 0;
  var b = 0;
  for (final c in colors) {
    r += c.r.toInt();
    g += c.g.toInt();
    b += c.b.toInt();
  }
  return Color.fromRGBO(r ~/ colors.length, g ~/ colors.length, b ~/ colors.length, 1);
}
