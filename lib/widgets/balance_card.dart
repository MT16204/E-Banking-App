import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../theme/colors.dart';
import '../theme/fonts.dart';

class BalanceCard extends StatefulWidget {
  final bool balanceHidden;
  final VoidCallback onToggleHidden;

  const BalanceCard({
    super.key,
    required this.balanceHidden,
    required this.onToggleHidden,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _shimmerAnim = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(
      begin: 0.04,
      end: 0.12,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final balance = provider.wallet?.balance ?? 0.0;
        final accountNum = provider.wallet?.accountNumber ?? '****';
        final fmt = NumberFormat('#,###', 'vi_VN');
        final userId = provider.user?.$id ?? '';
        final now = DateTime.now();
        double totalIn = 0, totalOut = 0;
        for (final t in provider.transactions) {
          if (t.createdAt.month == now.month && t.createdAt.year == now.year) {
            if (t.receiverId == userId) totalIn += t.amount;
            if (t.senderId == userId) totalOut += t.amount;
          }
        }

        return AnimatedBuilder(
          animation: Listenable.merge([_shimmerAnim, _floatAnim, _glowAnim]),
          builder: (context, _) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16 - _floatAnim.value * 0.5,
                20,
                _floatAnim.value * 0.5,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Glow pulse ───────────────────────────────────────
                  Positioned(
                    left: -8,
                    right: -8,
                    top: 4,
                    bottom: -8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(
                              alpha: _glowAnim.value,
                            ),
                            blurRadius: 40,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 28,
                            spreadRadius: -4,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Card body ────────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: NovaColors.cardBlack,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopRow(accountNum),
                            const SizedBox(height: 18),
                            _SlotBalance(
                              balance: balance,
                              hidden: widget.balanceHidden,
                              fmt: fmt,
                            ),
                            const SizedBox(height: 18),
                            Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                            const SizedBox(height: 16),
                            _buildStatsRow(
                              totalIn: totalIn,
                              totalOut: totalOut,
                              fmt: fmt,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Specular highlight ───────────────────────────────
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.12, 0.45, 1.0],
                              colors: [
                                Colors.white.withValues(alpha: 0.09),
                                Colors.white.withValues(alpha: 0.02),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.06),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Shimmer sweep ────────────────────────────────────
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Transform.translate(
                          offset: Offset(
                            _shimmerAnim.value *
                                MediaQuery.of(context).size.width,
                            0,
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 0.35,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.06),
                                    Colors.white.withValues(alpha: 0.10),
                                    Colors.white.withValues(alpha: 0.06),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Top edge shine ───────────────────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.20),
                                Colors.white.withValues(alpha: 0.32),
                                Colors.white.withValues(alpha: 0.20),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Inner stroke ─────────────────────────────────────
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.09),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopRow(String accountNum) {
    final theme = NovaTheme.of(context);
    final isVi = context.read<LanguageProvider>().isVietnamese;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isVi ? 'Số dư hiện tại' : 'Current balance',
              style: NovaFonts.body.copyWith(
                color: Colors.white.withValues(alpha: 0.54),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              widget.balanceHidden
                  ? '•••• ••••'
                  : (isVi ? 'TK $accountNum' : 'ACC $accountNum'),
              style: NovaFonts.body.copyWith(
                color: Colors.white.withValues(alpha: 0.30),
                fontSize: 11,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: widget.onToggleHidden,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: widget.balanceHidden ? 0.15 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.balanceHidden ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6EF5B0),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isVi ? 'Tài khoản chính' : 'Main account',
                    style: NovaFonts.body.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.chevronDown,
                    color: Colors.white54,
                    size: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow({
    required double totalIn,
    required double totalOut,
    required NumberFormat fmt,
  }) {
    final theme = NovaTheme.of(context);
    final isVi = context.read<LanguageProvider>().isVietnamese;
    return Row(
      children: [
        _AnimatedStatChip(
          icon: LucideIcons.arrowDownLeft,
          label: isVi ? 'Thu nhập' : 'Income',
          value: totalIn,
          hidden: widget.balanceHidden,
          fmt: fmt,
          prefix: '+',
          color: theme.primaryLight,
        ),
        Container(
          width: 1,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        _AnimatedStatChip(
          icon: LucideIcons.arrowUpRight,
          label: isVi ? 'Chi tiêu' : 'Spending',
          value: totalOut,
          hidden: widget.balanceHidden,
          fmt: fmt,
          prefix: '-',
          color: Colors.white.withValues(alpha: 0.74),
        ),
      ],
    );
  }
}

// ============================================================================
// SlotBalance — orchestrates per-digit slot machines
// ============================================================================
class _SlotBalance extends StatefulWidget {
  final double balance;
  final bool hidden;
  final NumberFormat fmt;

  const _SlotBalance({
    required this.balance,
    required this.hidden,
    required this.fmt,
  });

  @override
  State<_SlotBalance> createState() => _SlotBalanceState();
}

class _SlotBalanceState extends State<_SlotBalance> {
  String _formatted = '';

  @override
  void initState() {
    super.initState();
    _formatted = widget.fmt.format(widget.balance.round());
  }

  @override
  void didUpdateWidget(_SlotBalance old) {
    super.didUpdateWidget(old);
    if (old.balance != widget.balance) {
      setState(() {
        _formatted = widget.fmt.format(widget.balance.round());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hidden) {
      return Text(
        '••••••••',
        style: NovaFonts.numbers.copyWith(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w300,
          letterSpacing: 4,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ..._formatted.split('').asMap().entries.map((e) {
          final idx = e.key;
          final char = e.value;
          final isDigit = int.tryParse(char) != null;

          if (!isDigit) {
            return Text(
              char,
              style: NovaFonts.numbers.copyWith(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 34,
                fontWeight: FontWeight.w300,
              ),
            );
          }

          // Stagger each digit so they don't all land at the same time
          final staggerDelay = Duration(milliseconds: idx * 60);

          return _SlotDigit(
            targetDigit: int.parse(char),
            staggerDelay: staggerDelay,
            // Key forces a fresh spin when the digit value changes
            key: ValueKey('$idx-$char'),
          );
        }),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'đ',
            style: NovaFonts.body.copyWith(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SlotDigit — spins continuously 0→9 then snaps to targetDigit
// ============================================================================
class _SlotDigit extends StatefulWidget {
  final int targetDigit;
  final Duration staggerDelay;

  const _SlotDigit({
    super.key,
    required this.targetDigit,
    required this.staggerDelay,
  });

  @override
  State<_SlotDigit> createState() => _SlotDigitState();
}

class _SlotDigitState extends State<_SlotDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const int _spinRounds = 2;
  static const double _digitHeight = 42.0;

  @override
  void initState() {
    super.initState();

    // Total scroll distance: spinRounds full cycles + land on target
    final totalSteps = _spinRounds * 10 + widget.targetDigit;

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 900 + widget.staggerDelay.inMilliseconds,
      ),
    );

    // Decelerate: fast spin → slow land
    _anim = Tween<double>(
      begin: 0,
      end: totalSteps.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Wait for stagger then fire
    Future.delayed(widget.staggerDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: _digitHeight,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            // _anim.value is the continuous scroll offset (in digit units)
            // We translate the column of digits upward
            final offset = _anim.value % 10;
            final baseIndex = _anim.value ~/ 1; // integer part

            return Stack(
              children: List.generate(4, (i) {
                // Show 4 digits in the window at any time for smooth roll
                final digitIndex = (baseIndex + i) % 10;
                final yPos =
                    (i - offset % 1) * _digitHeight -
                    (_digitHeight * (offset % 1));

                // Fade out digits near top/bottom edges
                const center = _digitHeight / 2;
                final distFromCenter = (yPos + _digitHeight / 2 - center).abs();
                final opacity = (1.0 - distFromCenter / (_digitHeight * 1.5))
                    .clamp(0.0, 1.0);

                return Positioned(
                  top: yPos,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      height: _digitHeight,
                      child: Center(
                        child: Text(
                          '$digitIndex',
                          style: NovaFonts.numbers.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// Animated Stat Chip — count-up
// ============================================================================
class _AnimatedStatChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final double value;
  final bool hidden;
  final NumberFormat fmt;
  final String prefix;
  final Color color;

  const _AnimatedStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.hidden,
    required this.fmt,
    required this.prefix,
    required this.color,
  });

  @override
  State<_AnimatedStatChip> createState() => _AnimatedStatChipState();
}

class _AnimatedStatChipState extends State<_AnimatedStatChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _display = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() {
      setState(() => _display = widget.value * _anim.value);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void didUpdateWidget(_AnimatedStatChip old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _display = 0;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.of(context);
    final str = widget.hidden
        ? '••••••'
        : '${widget.prefix}${widget.fmt.format(_display.round())} đ';

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.label == 'Thu nhập' || widget.prefix == '+'
                ? theme.primary
                : widget.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(widget.icon, size: 15, color: widget.color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: NovaFonts.body.copyWith(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              str,
              style: NovaFonts.numbers.copyWith(
                color: widget.color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
