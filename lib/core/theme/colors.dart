import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appearance_provider.dart';

// =============================================================================
// NovaColors — STATIC
// Giữ nguyên 100% — backward-compatible với toàn bộ code hiện tại
// Luôn là màu mặc định nova_green
// =============================================================================

class NovaColors {
  // ─── Nền & Hệ Thống ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF2F5F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldWhite = Color(0xFFFFFFFF);

  // ─── Thương Hiệu ─────────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF1A5C4A);
  static const Color primaryGreenLight = Color(0xFFE8F5F0);
  static const Color primaryGreenMid = Color(0xFFB2D8CC);

  // ─── Typography ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ─── Thành Phần Đặc Biệt ─────────────────────────────────────────────────────
  static const Color dockBackground = Color(0xFF272727);
  static const Color cardBlack = Color(0xFF1A1A1A);
  static const Color inactiveIcon = Color(0xFFABABAB);
  static const Color divider = Color(0xFFF0F0F0);

  // ─── Trạng Thái ──────────────────────────────────────────────────────────────
  static const Color error = Colors.redAccent;
  static const Color errorBg = Color(0xFFFFF0F0);
  static const Color yellow = Color(0xFFB8860B);

  // ─── Shadow helpers ───────────────────────────────────────────────────────────
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static BoxShadow get primaryShadow => BoxShadow(
    color: primaryGreen.withOpacity(0.35),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static BoxShadow get softShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}

// =============================================================================
// NovaTheme — DYNAMIC
// Đọc màu từ ThemePreset hiện tại của AppearanceProvider
//
// CÁCH DÙNG (trong build()):
//   final t = NovaTheme.watch(context);   // subscribe rebuild khi đổi theme
//   color: t.primary                      // thay NovaColors.primaryGreen
//   color: t.background                   // thay NovaColors.background
//   color: t.textPrimary                  // thay NovaColors.textPrimary
//
// Dùng .of() nếu chỉ cần đọc 1 lần không cần rebuild:
//   final t = NovaTheme.of(context);
//
// Ưu tiên dùng NovaTheme.watch() ở các screen chính (home, profile, v.v.)
// Các widget nhỏ ít thay đổi có thể giữ NovaColors cũng không sao
// =============================================================================

class NovaTheme {
  final ThemePreset _preset;
  const NovaTheme._(this._preset);

  /// Subscribe rebuild khi đổi theme — dùng trong build()
  static NovaTheme watch(BuildContext context) {
    final preset = context.watch<AppearanceProvider>().currentTheme;
    return NovaTheme._(preset);
  }

  /// Chỉ đọc, không subscribe — dùng trong callback/handler
  static NovaTheme of(BuildContext context) {
    final preset = context.read<AppearanceProvider>().currentTheme;
    return NovaTheme._(preset);
  }

  // Tất cả màu của theme hiện tại
  Color get primary => _preset.primary;
  Color get primaryLight => _preset.primaryLight;
  Color get primaryMid => _preset.primaryMid;
  Color get background => _preset.background;
  Color get surface => _preset.surface;
  Color get dockBackground => _preset.dockBackground;
  Color get inactiveIcon => NovaColors.inactiveIcon;
  Color get textPrimary => _preset.textPrimary;
  Color get textSecondary => _preset.textSecondary;
  Color get error => NovaColors.error;
  Color get errorBg => NovaColors.errorBg;
  bool get isDark => _preset.isDark;

  // Shadow helpers động theo màu theme
  BoxShadow get primaryShadow => BoxShadow(
    color: primary.withOpacity(0.30),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
}
