import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/providers/appearance_provider.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;

  const HomeHeader({super.key, required this.onNotificationsTap});

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? context.tr('Chào buổi sáng', 'Good morning')
        : hour < 18
        ? context.tr('Chào buổi chiều', 'Good afternoon')
        : context.tr('Chào buổi tối', 'Good evening');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Consumer2<UserProvider, AppearanceProvider>(
              builder: (context, userProvider, appearanceProvider, _) {
                final fullName = userProvider.user?.name ?? 'User';
                final firstName = fullName.trim().split(' ').last;
                final currentAvatar = kAvatarPresets.firstWhere(
                  (a) => a.id == appearanceProvider.avatarId,
                  orElse: () => kAvatarPresets.first,
                );
                return Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: currentAvatar.bgColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primary, width: 1.5),
                      ),
                      child: Center(
                        child: currentAvatar.id == 'initial'
                            ? Text(
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : 'U',
                                style: NovaFonts.heading.copyWith(
                                  fontSize: 17,
                                  color: theme.primary,
                                ),
                              )
                            : Text(
                                currentAvatar.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting...',
                          style: NovaFonts.body.copyWith(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          firstName,
                          style: NovaFonts.heading.copyWith(
                            fontSize: 17,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, provider, _) {
              final hasUnread = provider.notifications.any((n) => !n.isRead);
              return _AnimatedNotificationBell(
                hasUnread: hasUnread,
                onTap: onNotificationsTap,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedNotificationBell extends StatefulWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _AnimatedNotificationBell({
    required this.hasUnread,
    required this.onTap,
  });

  @override
  State<_AnimatedNotificationBell> createState() =>
      _AnimatedNotificationBellState();
}

class _AnimatedNotificationBellState extends State<_AnimatedNotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconSwing;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _iconSwing = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.07), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.07, end: 0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(0), weight: 8),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(
      begin: 1,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _AnimatedNotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasUnread != widget.hasUnread) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.hasUnread) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: widget.hasUnread
                          ? theme.primary.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: widget.hasUnread ? 14 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: widget.hasUnread ? _iconSwing.value : 0,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      LucideIcons.bell,
                      size: 19,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ),
              if (widget.hasUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.background, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.error.withValues(alpha: 0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
