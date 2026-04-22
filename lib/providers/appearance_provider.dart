import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// AppearanceProvider
// Quản lý: avatar preset, theme preset, background preset
// Persist: SharedPreferences — scope theo userId (tránh chéo tài khoản)
// =============================================================================

// ── Avatar Presets ────────────────────────────────────────────────────────────

class AvatarPreset {
  final String id;
  final String emoji;
  final Color bgColor;
  final String label;

  const AvatarPreset({
    required this.id,
    required this.emoji,
    required this.bgColor,
    required this.label,
  });
}

const List<AvatarPreset> kAvatarPresets = [
  AvatarPreset(
    id: 'initial',
    emoji: '',
    bgColor: Color(0xFFE8F5F0),
    label: 'Chữ cái đầu',
  ),
  AvatarPreset(
    id: 'tiger',
    emoji: '🐯',
    bgColor: Color(0xFFFFF3E0),
    label: 'Hổ',
  ),
  AvatarPreset(
    id: 'fox',
    emoji: '🦊',
    bgColor: Color(0xFFFFEBEE),
    label: 'Cáo',
  ),
  AvatarPreset(
    id: 'panda',
    emoji: '🐼',
    bgColor: Color(0xFFF3E5F5),
    label: 'Gấu trúc',
  ),
  AvatarPreset(
    id: 'lion',
    emoji: '🦁',
    bgColor: Color(0xFFFFF8E1),
    label: 'Sư tử',
  ),
  AvatarPreset(
    id: 'wolf',
    emoji: '🐺',
    bgColor: Color(0xFFE8EAF6),
    label: 'Sói',
  ),
  AvatarPreset(
    id: 'bear',
    emoji: '🐻',
    bgColor: Color(0xFFEFEBE9),
    label: 'Gấu',
  ),
  AvatarPreset(
    id: 'cat',
    emoji: '😺',
    bgColor: Color(0xFFF1F8E9),
    label: 'Mèo',
  ),
  AvatarPreset(
    id: 'robot',
    emoji: '🤖',
    bgColor: Color(0xFFE3F2FD),
    label: 'Robot',
  ),
  AvatarPreset(
    id: 'alien',
    emoji: '👽',
    bgColor: Color(0xFFE8F5E9),
    label: 'Alien',
  ),
  AvatarPreset(
    id: 'ninja',
    emoji: '🥷',
    bgColor: Color(0xFF212121),
    label: 'Ninja',
  ),
  AvatarPreset(
    id: 'wizard',
    emoji: '🧙',
    bgColor: Color(0xFFEDE7F6),
    label: 'Phù thuỷ',
  ),
];

// ── Theme Presets ─────────────────────────────────────────────────────────────

class ThemePreset {
  final String id;
  final String label;
  final Color primary;
  final Color primaryLight;
  final Color primaryMid;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color dockBackground;
  final List<Color> gradientColors;

  const ThemePreset({
    required this.id,
    required this.label,
    required this.primary,
    required this.primaryLight,
    required this.primaryMid,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.dockBackground,
    required this.gradientColors,
  });

  // ── Dùng trong MaterialApp.theme — cập nhật toàn app khi đổi theme ──────
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primary,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerColor: const Color(0xFFF0F0F0),
      cardColor: surface,
    );
  }

  /// true nếu nền tối (dark mode) — dùng để set màu StatusBar icon
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark;
}

const List<ThemePreset> kThemePresets = [
  ThemePreset(
    id: 'nova_green',
    label: 'Nova Green',
    primary: Color(0xFF1A5C4A),
    primaryLight: Color(0xFFE8F5F0),
    primaryMid: Color(0xFFB2D8CC),
    background: Color(0xFFF2F5F4),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF888888),
    dockBackground: Color(0xFF272727),
    gradientColors: [Color(0xFF216E5A), Color(0xFF1A5C4A)],
  ),
  ThemePreset(
    id: 'ocean_blue',
    label: 'Ocean Blue',
    primary: Color(0xFF1565C0),
    primaryLight: Color(0xFFE3F2FD),
    primaryMid: Color(0xFF90CAF9),
    background: Color(0xFFF3F6FA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0D1B2A),
    textSecondary: Color(0xFF7B8FA1),
    dockBackground: Color(0xFF1A237E),
    gradientColors: [Color(0xFF1976D2), Color(0xFF1565C0)],
  ),
  ThemePreset(
    id: 'royal_purple',
    label: 'Royal Purple',
    primary: Color(0xFF6A1B9A),
    primaryLight: Color(0xFFF3E5F5),
    primaryMid: Color(0xFFCE93D8),
    background: Color(0xFFF7F3FA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A0030),
    textSecondary: Color(0xFF8E6FAF),
    dockBackground: Color(0xFF2E0A4F),
    gradientColors: [Color(0xFF7B1FA2), Color(0xFF6A1B9A)],
  ),
  ThemePreset(
    id: 'sunset_orange',
    label: 'Sunset Orange',
    primary: Color(0xFFBF360C),
    primaryLight: Color(0xFFFBE9E7),
    primaryMid: Color(0xFFFFAB91),
    background: Color(0xFFFAF5F3),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A0A00),
    textSecondary: Color(0xFF9E7060),
    dockBackground: Color(0xFF3E2723),
    gradientColors: [Color(0xFFD84315), Color(0xFFBF360C)],
  ),
  ThemePreset(
    id: 'rose_gold',
    label: 'Rose Gold',
    primary: Color(0xFFC2185B),
    primaryLight: Color(0xFFFCE4EC),
    primaryMid: Color(0xFFF48FB1),
    background: Color(0xFFFAF4F7),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2D0013),
    textSecondary: Color(0xFFAA7090),
    dockBackground: Color(0xFF4A0025),
    gradientColors: [Color(0xFFD81B60), Color(0xFFC2185B)],
  ),
  ThemePreset(
    id: 'midnight',
    label: 'Midnight',
    primary: Color(0xFF37474F),
    primaryLight: Color(0xFFECEFF1),
    primaryMid: Color(0xFFB0BEC5),
    background: Color(0xFFF4F6F7),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF102027),
    textSecondary: Color(0xFF607D8B),
    dockBackground: Color(0xFF102027),
    gradientColors: [Color(0xFF455A64), Color(0xFF37474F)],
  ),
];

// ── Background Presets ────────────────────────────────────────────────────────

class BackgroundPreset {
  final String id;
  final String label;
  final List<Color> colors;
  final List<double>? stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Color? patternColor;
  final BackgroundPattern pattern;

  const BackgroundPreset({
    required this.id,
    required this.label,
    required this.colors,
    this.stops,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.patternColor,
    this.pattern = BackgroundPattern.none,
  });
}

enum BackgroundPattern { none, dots, lines, circles, grid, waves }

const List<BackgroundPreset> kBackgroundPresets = [
  BackgroundPreset(
    id: 'default',
    label: 'Mặc định',
    colors: [Color(0xFF2F836F), Color(0xFF216B58), Color(0xFF184E41)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    patternColor: Color(0x0FFFFFFF),
    pattern: BackgroundPattern.none,
  ),
  BackgroundPreset(
    id: 'mint_fresh',
    label: 'Mint Fresh',
    colors: [Color(0xFFE8F5F0), Color(0xFFD0EDE4), Color(0xFFF2F5F4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    patternColor: Color(0x0F1A5C4A),
    pattern: BackgroundPattern.dots,
  ),
  BackgroundPreset(
    id: 'aurora',
    label: 'Aurora',
    colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  BackgroundPreset(
    id: 'golden_hour',
    label: 'Golden Hour',
    colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    patternColor: Color(0x0FB8860B),
    pattern: BackgroundPattern.circles,
  ),
  BackgroundPreset(
    id: 'dusk',
    label: 'Dusk',
    colors: [Color(0xFFEDE7F6), Color(0xFFE8EAF6), Color(0xFFF3F4F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    patternColor: Color(0x0F6A1B9A),
    pattern: BackgroundPattern.lines,
  ),
  BackgroundPreset(
    id: 'sakura',
    label: 'Sakura',
    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFFFF0F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    patternColor: Color(0x10C2185B),
    pattern: BackgroundPattern.dots,
  ),
  BackgroundPreset(
    id: 'ocean_mist',
    label: 'Ocean Mist',
    colors: [Color(0xFFE3F2FD), Color(0xFFE0F7FA), Color(0xFFF0F9FF)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    patternColor: Color(0x0C1565C0),
    pattern: BackgroundPattern.waves,
  ),
  BackgroundPreset(
    id: 'forest',
    label: 'Forest',
    colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9), Color(0xFFF9FBF9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    patternColor: Color(0x0C2E7D32),
    pattern: BackgroundPattern.grid,
  ),
  BackgroundPreset(
    id: 'charcoal',
    label: 'Charcoal',
    colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC), Color(0xFFF5F5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    patternColor: Color(0x0C37474F),
    pattern: BackgroundPattern.lines,
  ),
];

// =============================================================================
// AppearanceProvider
// =============================================================================

class AppearanceProvider extends ChangeNotifier {
  // Keys scope theo userId — mỗi tài khoản lưu riêng, không bị chéo
  static String _kAvatar(String uid) =>
      'appearance_avatar_${uid.isEmpty ? 'guest' : uid}';
  static String _kTheme(String uid) =>
      'appearance_theme_${uid.isEmpty ? 'guest' : uid}';
  static String _kBackground(String uid) =>
      'appearance_bg_${uid.isEmpty ? 'guest' : uid}';

  String _userId = '';
  String _avatarId = 'initial';
  String _themeId = 'nova_green';
  String _backgroundId = 'default';

  // ── Getters ──────────────────────────────────────────────────────────────────
  String get avatarId => _avatarId;
  String get themeId => _themeId;
  String get backgroundId => _backgroundId;

  AvatarPreset get currentAvatar => kAvatarPresets.firstWhere(
    (a) => a.id == _avatarId,
    orElse: () => kAvatarPresets.first,
  );

  ThemePreset get currentTheme => kThemePresets.firstWhere(
    (t) => t.id == _themeId,
    orElse: () => kThemePresets.first,
  );

  BackgroundPreset get currentBackground => kBackgroundPresets.firstWhere(
    (b) => b.id == _backgroundId,
    orElse: () => kBackgroundPresets.first,
  );

  /// ThemeData để truyền vào MaterialApp.theme
  /// MaterialApp.watch() provider này → toàn app rebuild realtime khi đổi theme
  ThemeData get themeData => currentTheme.toThemeData();

  // ── Load ──────────────────────────────────────────────────────────────────────

  /// Gọi trong main() khi app start mà chưa biết userId
  Future<void> load() async {
    await _loadPrefs('');
  }

  /// Gọi ngay sau khi login thành công
  /// userId = Appwrite user.$id
  Future<void> loadForUser(String userId) async {
    if (userId.isEmpty) return;
    _userId = userId;
    await _loadPrefs(userId);
  }

  Future<void> _loadPrefs(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    _avatarId = prefs.getString(_kAvatar(uid)) ?? 'initial';
    _themeId = prefs.getString(_kTheme(uid)) ?? 'nova_green';
    _backgroundId = prefs.getString(_kBackground(uid)) ?? 'default';
    notifyListeners();
  }

  // ── Setters ───────────────────────────────────────────────────────────────────

  Future<void> setAvatar(String id) async {
    if (_avatarId == id) return;
    _avatarId = id;
    notifyListeners(); // AppAvatar rebuild ngay
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatar(_userId), id);
  }

  Future<void> setTheme(String id) async {
    if (_themeId == id) return;
    _themeId = id;
    notifyListeners(); // MaterialApp rebuild → toàn app đổi màu ngay
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme(_userId), id);
  }

  Future<void> setBackground(String id) async {
    if (_backgroundId == id) return;
    _backgroundId = id;
    notifyListeners(); // AppBackground rebuild ngay
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBackground(_userId), id);
  }

  /// Gọi khi logout — reset về mặc định, xoá userId
  // void clearSession() {
  //   _userId = '';
  //   _avatarId = 'initial';
  //   _themeId = 'nova_green';
  //   _backgroundId = 'default';
  //   notifyListeners();
  // }
}
