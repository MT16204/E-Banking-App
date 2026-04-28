import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/providers/appearance_provider.dart';
import 'package:banking_app/providers/language_provider.dart';
import 'package:banking_app/widgets/header.dart';

// =============================================================================
// BackgroundPickerScreen
// Trang riêng — điều hướng từ ProfileScreen khi nhấn "Đổi hình nền"
// Scope: chỉ ảnh hưởng màn hình auth (login, signup, forgot password, v.v.)
//
// Cách dùng từ ProfileScreen:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => const BackgroundPickerScreen(),
//   ));
// =============================================================================

class BackgroundPickerScreen extends StatefulWidget {
  const BackgroundPickerScreen({super.key});

  @override
  State<BackgroundPickerScreen> createState() => _BackgroundPickerScreenState();
}

class _BackgroundPickerScreenState extends State<BackgroundPickerScreen> {
  late String _selectedId;
  late String _previewId; 

  @override
  void initState() {
    super.initState();
    _selectedId = context.read<AppearanceProvider>().backgroundId;
    _previewId = _selectedId;
  }

  BackgroundPreset get _previewPreset => kBackgroundPresets.firstWhere(
    (p) => p.id == _previewId,
    orElse: () => kBackgroundPresets.first,
  );

  int get _previewIndex {
    final index = kBackgroundPresets.indexWhere((p) => p.id == _previewId);
    return index < 0 ? 0 : index;
  }

  // bool get _showForwardArrow => _previewIndex < kBackgroundPresets.length - 1;

  // void _stepPreview() {
  //   final nextIndex = _showForwardArrow ? _previewIndex + 1 : _previewIndex - 1;
  //   setState(() => _previewId = kBackgroundPresets[nextIndex].id);
  // }

  Future<void> _apply(String id) async {
    await context.read<AppearanceProvider>().setBackground(id);
    setState(() => _selectedId = id);
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: t.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: t.isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: t.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Builder(
                builder: (ctx) {
                  final isVi = ctx.watch<LanguageProvider>().isVietnamese;
                  return Header.withTitle(
                    title: isVi ? 'Đổi hình nền' : 'Change background',
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionCard(
                        child: Builder(
                          builder: (ctx) {
                            final isVi = ctx
                                .watch<LanguageProvider>()
                                .isVietnamese;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isVi
                                                ? 'Chọn hình nền'
                                                : 'Choose background',
                                            style: NovaFonts.heading.copyWith(
                                              fontSize: 18,
                                              color: t.textPrimary,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isVi
                                                ? 'Lướt qua các preset và chọn bảng màu phù hợp cho màn hình đăng nhập.'
                                                : 'Browse presets and pick a color palette for the login screen.',
                                            style: NovaFonts.body.copyWith(
                                              fontSize: 12,
                                              color: t.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _BackgroundPresetStrip(
                                  selectedId: _previewId,
                                  savedId: _selectedId,
                                  onSelected: (id) {
                                    setState(() => _previewId = id);
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.primaryLight,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '${_previewIndex + 1}/${kBackgroundPresets.length}',
                                        style: NovaFonts.body.copyWith(
                                          fontSize: 11,
                                          color: t.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _previewPreset.label,
                                        style: NovaFonts.body.copyWith(
                                          fontSize: 13,
                                          color: t.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      opacity: _previewId != _selectedId
                                          ? 1
                                          : 0,
                                      child: GestureDetector(
                                        onTap: _previewId != _selectedId
                                            ? () => _apply(_previewId)
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: t.primary,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            isVi ? 'Áp dụng' : 'Apply',
                                            style: NovaFonts.body.copyWith(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        child: _PreviewArea(
                          preset: _previewPreset,
                          themePreset: context
                              .watch<AppearanceProvider>()
                              .currentTheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _PreviewArea
// Preview toàn màn hình mô phỏng trang auth — cập nhật realtime khi chọn
// =============================================================================

class _PreviewArea extends StatelessWidget {
  final BackgroundPreset preset;
  final ThemePreset themePreset;

  const _PreviewArea({required this.preset, required this.themePreset});

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<LanguageProvider>().isVietnamese;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: themePreset.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isVi ? 'Xem trước ' : 'Preview ',
            style: NovaFonts.body.copyWith(
              fontSize: 11,
              color: themePreset.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isVi
              ? 'Màn hình hiên thị trước các preset được chọn.'
              : 'Preview of the login screen with the selected preset.',
          style: NovaFonts.body.copyWith(
            fontSize: 12,
            color: NovaTheme.watch(context).textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: AspectRatio(
              aspectRatio: 10 / 16,
              child: _MiniLoginPreview(
                preset: preset,
                themePreset: themePreset,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: t.primaryLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BackgroundPresetStrip extends StatelessWidget {
  final String selectedId;
  final String savedId;
  final ValueChanged<String> onSelected;

  const _BackgroundPresetStrip({
    required this.selectedId,
    required this.savedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kBackgroundPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final preset = kBackgroundPresets[i];
          final isSelected = preset.id == selectedId;
          final isSaved = preset.id == savedId;

          return _PresetThumbnail(
            preset: preset,
            isSelected: isSelected,
            isSaved: isSaved,
            onTap: () => onSelected(preset.id),
          );
        },
      ),
    );
  }
}

class _PresetThumbnail extends StatelessWidget {
  final BackgroundPreset preset;
  final bool isSelected;
  final bool isSaved;
  final VoidCallback onTap;

  const _PresetThumbnail({
    required this.preset,
    required this.isSelected,
    required this.isSaved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: preset.colors,
                    stops: preset.stops,
                    begin: preset.begin,
                    end: preset.end,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? t.primary : NovaColors.divider,
                    width: isSelected ? 2.2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? t.primary.withOpacity(0.2)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: isSelected ? 14 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      if (preset.pattern != BackgroundPattern.none &&
                          preset.patternColor != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _PatternPainter(
                              pattern: preset.pattern,
                              color: preset.patternColor!,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 6,
                              width: 42,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.66),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: preset.colors.take(3).map((color) {
                                return Expanded(
                                  child: Container(
                                    height: 14,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected || isSaved)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSaved ? t.primary : t.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? LucideIcons.check : LucideIcons.eye,
                              size: 12,
                              color: isSaved ? Colors.white : t.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preset.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NovaFonts.body.copyWith(
                fontSize: 12,
                color: isSelected ? t.primary : t.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _ArrowButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _ArrowButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final t = NovaTheme.watch(context);

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: t.primary,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: t.primary.withOpacity(0.28),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Icon(icon, size: 18, color: Colors.white),
//       ),
//     );
//   }
// }

class _MiniLoginPreview extends StatelessWidget {
  final BackgroundPreset preset;
  final ThemePreset themePreset;

  const _MiniLoginPreview({required this.preset, required this.themePreset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.72), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
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
            if (preset.pattern != BackgroundPattern.none &&
                preset.patternColor != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: _PatternPainter(
                    pattern: preset.pattern,
                    color: preset.patternColor!,
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.04),
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                    ],
                    stops: const [0, 0.46, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -12,
              right: -6,
              child: _PreviewShape(
                size: 112,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Positioned(
              top: 28,
              right: 26,
              child: _PreviewShape(
                size: 92,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Positioned(
              top: 58,
              left: -28,
              child: _PreviewShape(
                size: 138,
                color: Colors.black.withOpacity(0.08),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '05:52',
                          style: NovaFonts.body.copyWith(
                            fontSize: 6.8,
                            color: Colors.black.withOpacity(0.82),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 32,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.signal,
                              size: 6,
                              color: Colors.black.withOpacity(0.65),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              LucideIcons.wifi,
                              size: 7,
                              color: Colors.black.withOpacity(0.65),
                            ),
                            const SizedBox(width: 3),
                            Container(
                              width: 10,
                              height: 5.5,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.65),
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 6.2,
                                  margin: const EdgeInsets.all(0.7),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(1.2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const SizedBox(width: 18, height: 18),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: Text(
                            'NOVA',
                            style: NovaFonts.heading.copyWith(
                              fontSize: 6.6,
                              color: Colors.white.withOpacity(0.92),
                              letterSpacing: 1.7,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'NOVA BANKING',
                        style: NovaFonts.body.copyWith(
                          fontSize: 6.6,
                          color: Colors.white.withOpacity(0.70),
                          letterSpacing: 1.7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('ĐĂNG NHẬP',
                        style: NovaFonts.heading.copyWith(
                          fontSize: 19,
                          color: Colors.white,
                          height: 0.95,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _MockChip(
                          label: 'Bảo mật nhiều lớp',
                          bg: Color(0x2BFFFFFF),
                          fg: Colors.white,
                        ),
                        _MockChip(
                          label: 'Đăng nhập nhanh',
                          bg: Color(0x2BFFFFFF),
                          fg: Colors.white,
                        ),
                        _MockChip(
                          label: 'Theo dõi giao dịch',
                          bg: Color(0x2BFFFFFF),
                          fg: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.62)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xin chào',
                      style: NovaFonts.heading.copyWith(
                        fontSize: 15.5,
                        color: NovaColors.textPrimary,
                        letterSpacing: -0.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nhập thông tin tài khoản để tiếp tục sử dụng Nova Banking.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: NovaFonts.body.copyWith(
                        fontSize: 7.7,
                        color: NovaColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const _MockField(
                      primary: NovaColors.primaryGreen,
                      label: 'Email',
                      hint: 'you@example.com',
                    ),
                    const SizedBox(height: 8),
                    const _MockField(
                      primary: NovaColors.primaryGreen,
                      label: 'Mật khẩu',
                      hint: 'Nhập mật khẩu của bạn',
                      isPassword: true,
                    ),
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Quên mật khẩu?',
                        style: NovaFonts.body.copyWith(
                          fontSize: 7.2,
                          color: NovaColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 28,
                      decoration: BoxDecoration(
                        color: NovaColors.primaryGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Đăng nhập',
                          style: NovaFonts.heading.copyWith(
                            fontSize: 8.8,
                            color: Colors.white,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: NovaFonts.body.copyWith(
                            color: NovaColors.textSecondary,
                            fontSize: 7.1,
                          ),
                          children: [
                            const TextSpan(text: 'Chưa có tài khoản? '),
                            TextSpan(
                              text: 'Đăng ký',
                              style: NovaFonts.body.copyWith(
                                color: NovaColors.primaryGreen,
                                fontSize: 7.1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _MockChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: NovaFonts.body.copyWith(
          fontSize: 6.6,
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MockField extends StatelessWidget {
  final Color primary;
  final String label;
  final String hint;
  final bool isPassword;
  const _MockField({
    required this.primary,
    required this.label,
    required this.hint,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4E6DF)),
      ),
      child: Row(
        children: [
          Icon(
            isPassword ? LucideIcons.lock : LucideIcons.mail,
            size: 10.5,
            color: primary.withOpacity(0.65),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: NovaFonts.body.copyWith(
                    fontSize: 6.6,
                    color: NovaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NovaFonts.body.copyWith(
                    fontSize: 7.4,
                    color: NovaColors.textPrimary.withOpacity(0.78),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isPassword)
            const Icon(LucideIcons.eyeOff, size: 10, color: NovaColors.textSecondary),
        ],
      ),
    );
  }
}

class _PreviewShape extends StatelessWidget {
  final double size;
  final Color color;

  const _PreviewShape({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// =============================================================================
// _PatternPainter — giữ nguyên từ appearance_sheets.dart
// =============================================================================

class _PatternPainter extends CustomPainter {
  final BackgroundPattern pattern;
  final Color color;

  const _PatternPainter({required this.pattern, required this.color});

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
    const spacing = 18.0;
    const radius = 1.8;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _drawLines(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 1;
    const spacing = 16.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    for (double r = 20; r < size.width; r += 28) {
      canvas.drawCircle(center, r, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = 0.8;
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.2;
    const amplitude = 6.0;
    const period = 30.0;
    const spacing = 18.0;
    for (double yBase = spacing; yBase < size.height; yBase += spacing) {
      final path = Path();
      path.moveTo(0, yBase);
      for (double x = 0; x < size.width; x += 2) {
        final t = x / period * 2 * 3.14159;
        final y =
            yBase +
            amplitude *
                (t - (t * t * t) / 6 + (t * t * t * t * t) / 120).clamp(
                  -1.0,
                  1.0,
                );
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) =>
      old.pattern != pattern || old.color != color;
}
