import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showLogo = false;
  static const int _gifDurationMs = 2800;
  static const String _novaText = 'NOVA';
  static const int _charDelayMs = 90;

  late List<AnimationController> _charControllers;
  late List<Animation<double>> _charOpacity;
  late List<Animation<Offset>> _charSlide;

  late AnimationController _bankingController;
  late Animation<double> _bankingOpacity;
  late Animation<Offset> _bankingSlide;
  late Animation<double> _bankingScale;
  late Animation<double> _letterSpacing;
  late Animation<double> _lineWidth;
  late Animation<double> _lineOpacity;
  late Animation<double> _lineGlow;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerPosition;

  late AnimationController _glowController;
  late Animation<double> _glowOpacity;

  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    _charControllers = List.generate(
      _novaText.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _charOpacity = _charControllers
        .map(
          (c) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    _charSlide = _charControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    _bankingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _bankingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bankingController,
        curve: const Interval(0.18, 0.72, curve: Curves.easeOut),
      ),
    );

    _bankingSlide =
        Tween<Offset>(begin: const Offset(0, 0.38), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _bankingController,
            curve: const Interval(0.16, 0.78, curve: Curves.easeOutCubic),
          ),
        );

    _bankingScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _bankingController,
        curve: const Interval(0.16, 0.72, curve: Curves.easeOutBack),
      ),
    );

    _letterSpacing = Tween<double>(begin: 11.0, end: 7.0).animate(
      CurvedAnimation(
        parent: _bankingController,
        curve: const Interval(0.22, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bankingController,
        curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _lineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bankingController,
        curve: const Interval(0.18, 0.7, curve: Curves.easeOut),
      ),
    );

    _lineGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bankingController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _shimmerPosition = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowOpacity = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: _gifDurationMs));
    if (!mounted) return;

    setState(() => _showLogo = true);

    _particleController.forward();

    for (int i = 0; i < _novaText.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 0 : _charDelayMs));
      if (!mounted) return;
      _charControllers[i].forward();
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    await _shimmerController.forward();
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    _bankingController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    await _navigateFromSplash();
  }

  Future<void> _navigateFromSplash() async {
    try {
      await account.get();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    for (final c in _charControllers) {
      c.dispose();
    }
    _bankingController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2E24),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A5C4A), Color(0xFF0D2E24)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showLogo ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: Center(
              child: Image.asset('assets/splash.gif', fit: BoxFit.contain),
            ),
          ),
          if (_showLogo) ...[
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (_, __) => CustomPaint(
                  painter: _ParticlePainter(_particleController.value),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Container(
                  width: 260,
                  height: 80,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: NovaColors.primaryGreen.withOpacity(
                          _glowOpacity.value,
                        ),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (_, __) {
                      return ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          final shimmerDone = _shimmerController.value > 0;
                          if (!shimmerDone) {
                            return const LinearGradient(
                              colors: [Colors.white, Colors.white],
                            ).createShader(bounds);
                          }
                          return LinearGradient(
                            colors: const [
                              Colors.white,
                              Color(0xFFB2FFE0),
                              Colors.white,
                              Colors.white,
                            ],
                            stops: [
                              (_shimmerPosition.value - 0.4).clamp(0.0, 1.0),
                              _shimmerPosition.value.clamp(0.0, 1.0),
                              (_shimmerPosition.value + 0.15).clamp(0.0, 1.0),
                              1.0,
                            ],
                          ).createShader(bounds);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_novaText.length, (i) {
                            return FadeTransition(
                              opacity: _charOpacity[i],
                              child: SlideTransition(
                                position: _charSlide[i],
                                child: Text(
                                  _novaText[i],
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 10,
                                    height: 1,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  AnimatedBuilder(
                    animation: _bankingController,
                    builder: (_, __) {
                      const lineColor = NovaColors.primaryGreenMid;
                      final glowColor = NovaColors.primaryGreen.withOpacity(
                        0.28 * _lineGlow.value,
                      );

                      Widget buildLine({required bool isLeft}) {
                        return Opacity(
                          opacity: _lineOpacity.value,
                          child: ClipRect(
                            child: Align(
                              alignment: isLeft
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              widthFactor: _lineWidth.value,
                              child: Container(
                                width: 62,
                                height: 1.2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: isLeft
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    end: isLeft
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    colors: [
                                      lineColor.withOpacity(0.0),
                                      lineColor.withOpacity(0.45),
                                      lineColor,
                                      Colors.white.withOpacity(
                                        0.9 * _lineGlow.value,
                                      ),
                                    ],
                                    stops: const [0.0, 0.35, 0.72, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: glowColor,
                                      blurRadius: 10,
                                      spreadRadius: 0.4,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return FadeTransition(
                        opacity: _bankingOpacity,
                        child: SlideTransition(
                          position: _bankingSlide,
                          child: ScaleTransition(
                            scale: _bankingScale,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                buildLine(isLeft: true),
                                const SizedBox(width: 14),
                                Text(
                                  'BANKING',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: lineColor,
                                    letterSpacing: _letterSpacing.value,
                                    fontWeight: FontWeight.w400,
                                    height: 1,
                                    shadows: [
                                      Shadow(
                                        color: NovaColors.primaryGreen
                                            .withOpacity(
                                              0.22 * _lineGlow.value,
                                            ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                buildLine(isLeft: false),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final List<_Particle> _particles = _generateParticles();

  _ParticlePainter(this.progress);

  static List<_Particle> _generateParticles() {
    final rng = math.Random(42);
    return List.generate(18, (i) {
      final angle = (i / 18) * math.pi * 2 + rng.nextDouble() * 0.4;
      final speed = 60.0 + rng.nextDouble() * 80;
      final size = 2.0 + rng.nextDouble() * 3.0;
      return _Particle(angle: angle, speed: speed, size: size);
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final p in _particles) {
      final ease = Curves.easeOut.transform(progress);
      final dist = p.speed * ease;
      final x = cx + math.cos(p.angle) * dist;
      final y = cy + math.sin(p.angle) * dist * 0.5;
      final opacity = (1.0 - ease).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = NovaColors.primaryGreen.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.size * (1 - ease * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double angle;
  final double speed;
  final double size;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}
