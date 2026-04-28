import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/appearance_provider.dart';
import '../core/theme/fonts.dart';

// =============================================================================
// AppBackground
// =============================================================================

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final preset = context.watch<AppearanceProvider>().currentBackground;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: preset.colors,
          stops: preset.stops,
          begin: preset.begin,
          end: preset.end,
        ),
      ),
      child:
          preset.pattern != BackgroundPattern.none &&
              preset.patternColor != null
          ? CustomPaint(
              painter: _BackgroundPatternPainter(
                pattern: preset.pattern,
                color: preset.patternColor!,
              ),
              child: child,
            )
          : child,
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final BackgroundPattern pattern;
  final Color color;

  const _BackgroundPatternPainter({required this.pattern, required this.color});

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
  bool shouldRepaint(_BackgroundPatternPainter old) =>
      old.pattern != pattern || old.color != color;
}

double _sin(double x) {
  x = x % (2 * 3.14159);
  return (x - (x * x * x) / 6 + (x * x * x * x * x) / 120).clamp(-1.0, 1.0);
}

// =============================================================================
// AppAvatar
// =============================================================================

class AppAvatar extends StatelessWidget {
  final double radius;
  final String? displayName;

  const AppAvatar({super.key, this.radius = 44, this.displayName});

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceProvider>();
    final preset = appearance.currentAvatar;
    final themeColor = appearance.currentTheme.primary;

    final initials = _getInitials(displayName);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: themeColor, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: preset.bgColor,
        child: Center(
          child: preset.id == 'initial'
              ? Text(
                  initials,
                  style: NovaFonts.heading.copyWith(
                    fontSize: radius * 0.6,
                    color: themeColor,
                  ),
                )
              : Text(preset.emoji, style: TextStyle(fontSize: radius * 0.68)),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
