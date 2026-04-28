import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'package:banking_app/widgets/header.dart';

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ---------------------------------------------------------------------------
// CardScreen
// ---------------------------------------------------------------------------
class CardScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const CardScreen({super.key, this.onBackToHome});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen>
    with SingleTickerProviderStateMixin {
  int _sel = 0;
  late final TabController _tab;
  final Set<String> _revealed = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final uid = context.read<UserProvider>().user?.$id ?? '';
    await context.read<UserProvider>().fetchCards(uid);
  }

  void _toggleReveal(String cardId) => setState(() {
    if (_revealed.contains(cardId)) {
      _revealed.remove(cardId);
    } else {
      _revealed.add(cardId);
    }
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: t.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: t.isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: t.background, // ← đổi
        body: Consumer<UserProvider>(
          builder: (ctx, provider, _) {
            final cards = provider.cards;
            final loading = provider.isLoading && cards.isEmpty;
            if (_sel >= cards.length && cards.isNotEmpty) {
              _sel = cards.length - 1;
            }

            return SafeArea(
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────────
                  Header.withTitle(
                    title: context.tr('Thẻ của tôi', 'My cards'),
                    centerTitle: false,
                    onBack:
                        widget.onBackToHome ??
                        () => Navigator.maybePop(context),
                    action: GestureDetector(
                      onTap: () => _openAdd(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: t.primary, // ← đổi
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: t.primary.withOpacity(0.35), // ← đổi
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('Thêm thẻ', 'Add card'),
                              style: NovaFonts.body.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (loading)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: t.primary, // ← đổi
                        ),
                      ),
                    )
                  else if (cards.isEmpty)
                    Expanded(child: _EmptyState(onAdd: () => _openAdd(context)))
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        color: t.primary, // ← đổi
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 110),
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              _Carousel(
                                cards: cards,
                                selected: _sel,
                                revealed: _revealed,
                                onChanged: (i) => setState(() => _sel = i),
                                onToggleReveal: _toggleReveal,
                              ),
                              const SizedBox(height: 28),
                              _DetailsBlock(
                                card: cards[_sel],
                                tab: _tab,
                                onToggle: () => _toggleStatus(cards[_sel]),
                                onDelete: () => _deleteCard(cards[_sel]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openAdd(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSheet(
        onSave: (name, number, type, exp) async {
          final ok = await ctx.read<UserProvider>().addCard(
            cardName: name,
            cardNumber: number,
            cardType: type,
            expiryDate: exp,
          );
          if (ctx.mounted) Navigator.pop(ctx);
          if (ok == null && ctx.mounted) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(
                  ctx.tr('Thêm thẻ thất bại.', 'Failed to add card.'),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _toggleStatus(CardModel c) async {
    final ok = await context.read<UserProvider>().toggleCardStatus(c);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Cập nhật thất bại.', 'Update failed.')),
        ),
      );
    }
  }

  Future<void> _deleteCard(CardModel c) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('Xóa thẻ?', 'Delete card?')),
        content: Text(
          context.tr(
            'Xóa thẻ "${c.cardName ?? c.maskedNumber}"?',
            'Delete card "${c.cardName ?? c.maskedNumber}"?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('Hủy', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.tr('Xóa', 'Delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      setState(() {
        if (_sel > 0) _sel--;
      });
      await context.read<UserProvider>().deleteCard(c.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Carousel
// ---------------------------------------------------------------------------
class _Carousel extends StatefulWidget {
  final List<CardModel> cards;
  final int selected;
  final Set<String> revealed;
  final ValueChanged<int> onChanged;
  final ValueChanged<String> onToggleReveal;

  const _Carousel({
    required this.cards,
    required this.selected,
    required this.revealed,
    required this.onChanged,
    required this.onToggleReveal,
  });

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.cards.length,
            onPageChanged: widget.onChanged,
            itemBuilder: (_, i) {
              final active = i == widget.selected;
              final card = widget.cards[i];
              final isRevealed = widget.revealed.contains(card.id);
              return AnimatedScale(
                scale: active ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: _CardWidget(
                    card: card,
                    isSelected: active,
                    isRevealed: isRevealed,
                    onToggleReveal: () => widget.onToggleReveal(card.id),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cards.length, (i) {
            final sel = i == widget.selected;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: sel ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: sel ? t.primary : t.primaryMid.withOpacity(0.4), // ← đổi
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card Visual
// ---------------------------------------------------------------------------
class _CardWidget extends StatelessWidget {
  final CardModel card;
  final bool isSelected, isRevealed;
  final VoidCallback onToggleReveal;

  const _CardWidget({
    required this.card,
    required this.isSelected,
    required this.isRevealed,
    required this.onToggleReveal,
  });

  Color get _baseColor {
    final t = card.cardType.toUpperCase();
    if (t.contains('MASTER')) return const Color(0xFF181818);
    if (t.contains('JCB')) return const Color(0xFF0F766E);
    if (t.contains('NAPAS')) return const Color(0xFF1A5C47);
    return const Color(0xFF16567B);
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !card.isActive;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_baseColor, Color.lerp(_baseColor, Colors.black, 0.25)!],
        ),
        boxShadow: [
          BoxShadow(
            color: _baseColor.withOpacity(isSelected ? 0.4 : 0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            if (!isLocked) _ShimmerLayer(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.cardType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.5,
                          height: 1,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.contactless_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 22,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            isRevealed
                                ? _formatFull(card.cardNumber)
                                : card.maskedNumber,
                            key: ValueKey(isRevealed),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontSize: 17,
                              letterSpacing: isRevealed ? 2.5 : 3.5,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onToggleReveal,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              isRevealed ? 0.2 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isRevealed ? LucideIcons.eyeOff : LucideIcons.eye,
                            color: Colors.white.withOpacity(0.85),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _meta(
                        context.tr('TÊN THẺ', 'CARD NAME'),
                        (card.cardName ?? '—').toUpperCase(),
                      ),
                      _meta(
                        context.tr('HẾT HẠN', 'EXPIRES'),
                        card.expiryDate ?? '--/--',
                        align: CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isLocked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.72),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.lock,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('Thẻ đã bị khóa', 'Card is locked'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            'Nhấn "Mở thẻ" để kích hoạt lại',
                            'Tap "Unlock card" to reactivate',
                          ),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFull(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  Widget _meta(
    String label,
    String value, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ShimmerLayer extends StatefulWidget {
  @override
  _ShimmerLayerState createState() => _ShimmerLayerState();
}

class _ShimmerLayerState extends State<_ShimmerLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Positioned.fill(
          child: FractionallySizedBox(
            widthFactor: 2.0,
            alignment: Alignment(_ctrl.value * 3 - 1.5, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.3, 0.5, 0.7],
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Details Block
// ---------------------------------------------------------------------------
class _DetailsBlock extends StatelessWidget {
  final CardModel card;
  final TabController tab;
  final VoidCallback onToggle, onDelete;

  const _DetailsBlock({
    required this.card,
    required this.tab,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: t.surface, // ← đổi
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: t.primaryLight, // ← đổi
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.credit_card_outlined,
                              size: 19,
                              color: t.primary, // ← đổi
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.cardName ??
                                    context.tr('Thẻ của tôi', 'My card'),
                                style: NovaFonts.heading.copyWith(
                                  fontSize: 15,
                                  color: t.textPrimary, // ← đổi
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                card.cardType.toUpperCase(),
                                style: NovaFonts.body.copyWith(
                                  fontSize: 11,
                                  color: t.textSecondary, // ← đổi
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _StatusPill(isActive: card.isActive),
                    ],
                  ),
                ),
                Divider(height: 1, color: t.primaryLight), // ← đổi
                _InfoRow(
                  label: context.tr('Số thẻ', 'Card number'),
                  value: card.maskedNumber,
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: t.primaryLight, // ← đổi
                ),
                _InfoRow(
                  label: context.tr('Ngày hết hạn', 'Expiry date'),
                  value: card.expiryDate ?? '--/--',
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: t.primaryLight, // ← đổi
                ),
                _InfoRow(
                  label: context.tr('Loại thẻ', 'Card type'),
                  value: card.cardType.toUpperCase(),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transaction panel
          Container(
            decoration: BoxDecoration(
              color: t.surface, // ← đổi
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('Giao dịch gần đây', 'Recent transactions'),
                        style: NovaFonts.heading.copyWith(
                          fontSize: 15,
                          color: t.textPrimary, // ← đổi
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          context.tr('Xem thêm', 'See more'),
                          style: NovaFonts.body.copyWith(
                            color: t.primary, // ← đổi
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.background, // ← đổi
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: tab,
                      indicator: BoxDecoration(
                        color: t.surface, // ← đổi
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: NovaFonts.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: NovaFonts.body.copyWith(
                        fontSize: 13,
                      ),
                      labelColor: t.primary, // ← đổi
                      unselectedLabelColor: t.textSecondary, // ← đổi
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: context.tr('Thu nhập', 'Income')),
                        Tab(text: context.tr('Chuyển khoản', 'Transfers')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 180,
                  child: TabBarView(
                    controller: tab,
                    children: const [
                      _TxList(type: 'income'),
                      _TxList(type: 'transfer'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: card.isActive ? LucideIcons.lock : LucideIcons.unlock,
                  label: card.isActive
                      ? context.tr('Khóa thẻ', 'Lock card')
                      : context.tr('Mở thẻ', 'Unlock card'),
                  color: card.isActive
                      ? const Color(0xFFD4580A)
                      : t.primary, // ← đổi
                  bg: card.isActive
                      ? const Color(0xFFFFF0E5)
                      : t.primaryLight, // ← đổi
                  onTap: onToggle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionBtn(
                  icon: LucideIcons.trash2,
                  label: context.tr('Xóa thẻ', 'Delete card'),
                  color: t.error,
                  bg: const Color(0xFFFFEBEB),
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: NovaFonts.body.copyWith(
              fontSize: 14,
              color: t.textSecondary, // ← đổi
            ),
          ),
          Text(
            value,
            style: NovaFonts.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: t.textPrimary, // ← đổi
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;
  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? t
                  .primaryLight // ← đổi
            : const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? t
                        .primary // ← đổi
                  : const Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isActive
                ? context.tr('Hoạt động', 'Active')
                : context.tr('Đã khóa', 'Locked'),
            style: NovaFonts.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? t
                        .primary // ← đổi
                  : const Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 7),
            Text(
              label,
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxList extends StatelessWidget {
  final String type;
  const _TxList({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context); // ← theme động
    final provider = context.watch<UserProvider>();
    final userId = provider.user?.$id ?? '';
    final filtered = provider.transactions
        .where(
          (tx) => type == 'income'
              ? tx.receiverId == userId
              : tx.senderId == userId,
        )
        .take(3)
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == 'income'
                  ? LucideIcons.arrowDownLeft
                  : LucideIcons.arrowUpRight,
              size: 28,
              color: theme.primaryMid.withValues(alpha: 0.5), // ← đổi
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('Chưa có giao dịch', 'No transactions yet'),
              style: NovaFonts.body.copyWith(
                fontSize: 12,
                color: theme.textSecondary, // ← đổi
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: theme.background),
      itemBuilder: (_, i) {
        final tx = filtered[i];
        final isIn = tx.receiverId == userId;
        final desc =
            tx.description ??
            (isIn
                ? context.tr('Nhận tiền', 'Money received')
                : context.tr('Chuyển tiền', 'Money transfer'));
        final amount = '${isIn ? '+' : '-'}${_fmt(tx.amount)} đ';
        final date =
            '${tx.createdAt.day.toString().padLeft(2, '0')}/'
            '${tx.createdAt.month.toString().padLeft(2, '0')}/'
            '${tx.createdAt.year}';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isIn ? theme.primaryLight : theme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIn ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                  size: 18,
                  color: isIn ? theme.primary : theme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NovaFonts.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: NovaFonts.body.copyWith(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: NovaFonts.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isIn ? theme.primary : theme.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: NovaColors.primaryGreenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_off_outlined,
              size: 40,
              color: NovaColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('Bạn chưa có thẻ nào', 'You have no cards yet'),
            style: NovaFonts.heading.copyWith(
              fontSize: 17,
              color: const Color(0xFF0D1B17),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Thêm thẻ để quản lý giao dịch dễ hơn',
              'Add a card to manage transactions more easily',
            ),
            style: NovaFonts.body.copyWith(
              fontSize: 13,
              color: const Color(0xFF8A9E99),
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: NovaColors.primaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: NovaColors.primaryGreen.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                context.tr('+ Thêm thẻ mới', '+ Add new card'),
                style: NovaFonts.body.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Sheet
// ---------------------------------------------------------------------------
String _calcExpiry(String cardType) {
  const yearsMap = {'VISA': 5, 'MASTERCARD': 4, 'JCB': 3, 'NAPAS': 5};
  final years = yearsMap[cardType.toUpperCase()] ?? 5;
  final exp = DateTime(DateTime.now().year + years, DateTime.now().month);
  final mm = exp.month.toString().padLeft(2, '0');
  final yy = (exp.year % 100).toString().padLeft(2, '0');
  return '$mm/$yy';
}

class _AddSheet extends StatefulWidget {
  final Future<void> Function(
    String name,
    String number,
    String type,
    String? exp,
  )
  onSave;
  const _AddSheet({required this.onSave});

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _fk = GlobalKey<FormState>();
  final _namec = TextEditingController();
  final _numc = TextEditingController();
  String _type = 'VISA';
  bool _busy = false;

  static const _types = ['VISA', 'MASTERCARD', 'JCB', 'NAPAS'];
  static const _yearsMap = {'VISA': 5, 'MASTERCARD': 4, 'JCB': 3, 'NAPAS': 5};

  @override
  void dispose() {
    _namec.dispose();
    _numc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.onSave(
        _namec.text.trim(),
        _numc.text.replaceAll(' ', ''),
        _type,
        _calcExpiry(_type),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final autoExpiry = _calcExpiry(_type);
    final years = _yearsMap[_type] ?? 5;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _fk,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.primaryMid,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              context.tr('Thêm thẻ mới', 'Add new card'),
              style: NovaFonts.heading.copyWith(
                fontSize: 19,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _Field(
              ctrl: _namec,
              label: context.tr('Tên thẻ', 'Card name'),
              hint: context.tr('VD: Thẻ Vietcombank', 'e.g. Vietcombank card'),
              validator: (v) => (v == null || v.isEmpty)
                  ? context.tr(
                      'Vui lòng nhập tên thẻ',
                      'Please enter a card name',
                    )
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              ctrl: _numc,
              label: context.tr('Số thẻ', 'Card number'),
              hint: '•••• •••• •••• ••••',
              type: TextInputType.number,
              maxLen: 19,
              inputFormatters: [_CardNumberFormatter()],
              validator: (v) {
                final d = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                if (d.isEmpty) {
                  return context.tr(
                    'Vui lòng nhập số thẻ',
                    'Please enter the card number',
                  );
                }
                if (d.length != 16) {
                  return context.tr(
                    'Số thẻ phải đủ 16 chữ số',
                    'Card number must be 16 digits',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('Loại thẻ', 'Card type'),
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _types.map((type) {
                final sel = type == _type;
                return ChoiceChip(
                  label: Text(type),
                  selected: sel,
                  onSelected: (_) => setState(() => _type = type),
                  showCheckmark: true,
                  checkmarkColor: Colors.white,
                  selectedColor: theme.primary,
                  labelStyle: NovaFonts.body.copyWith(
                    color: sel ? Colors.white : theme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  backgroundColor: theme.background,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('Ngày hết hạn', 'Expiry date'),
                          style: NovaFonts.body.copyWith(
                            fontSize: 11,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            autoExpiry,
                            key: ValueKey(autoExpiry),
                            style: NovaFonts.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(_type),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.tr('$years năm', '$years years'),
                        style: NovaFonts.body.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.tr('Lưu thẻ', 'Save card'),
                        style: NovaFonts.heading.copyWith(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final TextInputType? type;
  final int? maxLen;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.type,
    this.maxLen,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: NovaFonts.body.copyWith(fontSize: 13, color: t.textSecondary),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          maxLength: maxLen,
          inputFormatters: inputFormatters,
          validator: validator,
          style: NovaFonts.body.copyWith(fontSize: 14, color: t.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: NovaFonts.body.copyWith(
              color: t.primaryMid,
              fontSize: 14,
            ),
            counterText: '',
            filled: true,
            fillColor: t.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: t.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: t.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: t.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
