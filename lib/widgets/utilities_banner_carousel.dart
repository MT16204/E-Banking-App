import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class UtilitiesBannerItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color accentColor;

  const UtilitiesBannerItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.accentColor,
  });
}

class UtilitiesBannerCarousel extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  final List<UtilitiesBannerItem> banners;
  final ValueChanged<int> onPageChanged;
  final String offerLabel;

  const UtilitiesBannerCarousel({
    super.key,
    required this.controller,
    required this.currentIndex,
    required this.banners,
    required this.onPageChanged,
    required this.offerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: banners.length,
            itemBuilder: (_, i) => _UtilitiesBannerCard(
              banner: banners[i],
              offerLabel: offerLabel,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final isActive = i == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? theme.primary : theme.primaryMid,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _UtilitiesBannerCard extends StatelessWidget {
  final UtilitiesBannerItem banner;
  final String offerLabel;

  const _UtilitiesBannerCard({
    required this.banner,
    required this.offerLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          color: banner.bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: banner.accentColor.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: banner.accentColor.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 100, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: banner.accentColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offerLabel,
                      style: NovaFonts.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.title,
                    style: NovaFonts.heading.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle,
                    style: NovaFonts.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: banner.accentColor.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    banner.icon,
                    size: 26,
                    color: Colors.white.withValues(alpha: 0.9),
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
