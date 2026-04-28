import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/widgets/header.dart';

// ─── Banner model ──────────────────────────────────────────────────────────────
class _BannerItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color accentColor;
  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.accentColor,
  });
}

// ─── Data model ────────────────────────────────────────────────────────────────
class _UtilityItem {
  final String label;
  final IconData icon;
  final String? badge;
  const _UtilityItem({required this.label, required this.icon, this.badge});
}

class _UtilitySection {
  final String title;
  final List<_UtilityItem> items;
  const _UtilitySection({required this.title, required this.items});
}

// ─── Screen ────────────────────────────────────────────────────────────────────
class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen>
    with TickerProviderStateMixin {
  // ── Search ──
  final SearchController _searchController = SearchController();
  String _query = '';
  Timer? _debounce;

  // ── Banner ──
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  // ── Animation ──
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_BannerItem> _banners = const [
    _BannerItem(
      title: 'Flash Sale hôm nay',
      subtitle: 'Giảm đến 50% dịch vụ nạp thẻ',
      icon: LucideIcons.zap,
      bgColor: Color(0xFF1A5C4A),
      accentColor: Color(0xFF4CAF82),
    ),
    _BannerItem(
      title: 'Đặt phòng khách sạn',
      subtitle: 'Ưu đãi cuối tuần — giảm 25%',
      icon: LucideIcons.building2,
      bgColor: Color(0xFF1A3A5C),
      accentColor: Color(0xFF4C82AF),
    ),
    _BannerItem(
      title: 'Thanh toán hóa đơn',
      subtitle: 'Hoàn tiền 2% mọi hóa đơn điện nước',
      icon: LucideIcons.receipt,
      bgColor: Color(0xFF5C3A1A),
      accentColor: Color(0xFFAF824C),
    ),
    _BannerItem(
      title: 'Vé xem phim',
      subtitle: 'Chỉ 75.000đ — áp dụng mọi rạp',
      icon: LucideIcons.film,
      bgColor: Color(0xFF3A1A5C),
      accentColor: Color(0xFF824CAF),
    ),
  ];

  final List<_UtilitySection> _sections = const [
    _UtilitySection(
      title: 'Mua sắm & Ưu đãi',
      items: [
        _UtilityItem(
          label: 'Mua sắm\ntrực tuyến',
          icon: LucideIcons.shoppingCart,
          badge: 'Hot',
        ),
        _UtilityItem(
          label: 'E-Voucher\nưu đãi',
          icon: LucideIcons.tag,
          badge: 'Mới',
        ),
        _UtilityItem(label: 'Hoàn tiền', icon: LucideIcons.refreshCw),
        _UtilityItem(label: 'Flash Sale', icon: LucideIcons.zap, badge: '-50%'),
      ],
    ),
    _UtilitySection(
      title: 'Viễn thông & Nạp thẻ',
      items: [
        _UtilityItem(
          label: 'Nạp điện\nthoại',
          icon: LucideIcons.smartphone,
          badge: '-30%',
        ),
        _UtilityItem(label: 'Thẻ Game', icon: LucideIcons.gamepad2),
        _UtilityItem(label: 'Data 4G/5G', icon: LucideIcons.wifi),
        _UtilityItem(label: 'Thẻ điện\nthoại', icon: LucideIcons.creditCard),
      ],
    ),
    _UtilitySection(
      title: 'Hóa đơn & Thanh toán',
      items: [
        _UtilityItem(label: 'Điện\n(EVN)', icon: LucideIcons.zap),
        _UtilityItem(label: 'Nước', icon: LucideIcons.droplets),
        _UtilityItem(label: 'Internet\n& TV', icon: LucideIcons.tv),
        _UtilityItem(label: 'Bảo hiểm', icon: LucideIcons.shield),
        _UtilityItem(label: 'Học phí', icon: LucideIcons.graduationCap),
        _UtilityItem(label: 'Thuế &\nphí khác', icon: LucideIcons.landmark),
      ],
    ),
    _UtilitySection(
      title: 'Giải trí & Xổ số',
      items: [
        _UtilityItem(
          label: 'Vé xem\nphim',
          icon: LucideIcons.film,
          badge: '75k',
        ),
        _UtilityItem(label: 'Vé sự kiện', icon: LucideIcons.ticket),
        _UtilityItem(label: 'Xổ số', icon: LucideIcons.dices),
        _UtilityItem(label: 'Âm nhạc', icon: LucideIcons.music),
      ],
    ),
    _UtilitySection(
      title: 'Du lịch & Di chuyển',
      items: [
        _UtilityItem(
          label: 'Đặt phòng\nkhách sạn',
          icon: LucideIcons.building2,
          badge: '-25%',
        ),
        _UtilityItem(label: 'Vé máy\nbay', icon: LucideIcons.planeTakeoff),
        _UtilityItem(label: 'Vé tàu', icon: LucideIcons.train),
        _UtilityItem(label: 'Vé xe', icon: LucideIcons.bus),
        _UtilityItem(label: 'Gọi xe', icon: LucideIcons.car, badge: '-50%'),
        _UtilityItem(label: 'Thuê xe\ndu lịch', icon: LucideIcons.mapPin),
      ],
    ),
    _UtilitySection(
      title: 'Sức khỏe & Y tế',
      items: [
        _UtilityItem(label: 'Đặt lịch\nkhám', icon: LucideIcons.stethoscope),
        _UtilityItem(label: 'Nhà thuốc', icon: LucideIcons.pill),
        _UtilityItem(label: 'Bảo hiểm\nsức khỏe', icon: LucideIcons.heartPulse),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Auto-scroll banner mỗi 3.5 giây
    _bannerTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      if (!mounted) return;

      if (!_bannerController.hasClients) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    _debounce?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _query = value);
    });
  }

  List<_UtilitySection> get _filteredSections {
    if (_query.isEmpty) return _sections;
    final q = _query.toLowerCase();
    return _sections
        .map(
          (s) => _UtilitySection(
            title: s.title,
            items: s.items
                .where((i) => i.label.toLowerCase().contains(q))
                .toList(),
          ),
        )
        .where((s) => s.items.isNotEmpty)
        .toList();
  }

  String _sectionTitle(BuildContext context, String value) {
    switch (value) {
      case 'Mua sắm & Ưu đãi':
        return context.tr('Mua sắm & Ưu đãi', 'Shopping & Deals');
      case 'Viễn thông & Nạp thẻ':
        return context.tr('Viễn thông & Nạp thẻ', 'Telecom & Top-up');
      case 'Hóa đơn & Thanh toán':
        return context.tr('Hóa đơn & Thanh toán', 'Bills & Payments');
      case 'Giải trí & Xổ số':
        return context.tr('Giải trí & Xổ số', 'Entertainment & Lottery');
      case 'Du lịch & Di chuyển':
        return context.tr('Du lịch & Di chuyển', 'Travel & Transport');
      case 'Sức khỏe & Y tế':
        return context.tr('Sức khỏe & Y tế', 'Health & Medical');
      default:
        return value;
    }
  }

  String _itemLabel(BuildContext context, String value) {
    switch (value) {
      case 'Mua sắm\ntrực tuyến':
        return context.tr(value, 'Online\nshopping');
      case 'E-Voucher\nưu đãi':
        return context.tr(value, 'Promo\nE-voucher');
      case 'Hoàn tiền':
        return context.tr(value, 'Cashback');
      case 'Flash Sale':
        return context.tr(value, 'Flash Sale');
      case 'Nạp điện\nthoại':
        return context.tr(value, 'Mobile\ntop-up');
      case 'Thẻ Game':
        return context.tr(value, 'Game card');
      case 'Data 4G/5G':
        return context.tr(value, '4G/5G data');
      case 'Thẻ điện\nthoại':
        return context.tr(value, 'Phone\ncard');
      case 'Điện\n(EVN)':
        return context.tr(value, 'Electricity\n(EVN)');
      case 'Nước':
        return context.tr(value, 'Water');
      case 'Internet\n& TV':
        return context.tr(value, 'Internet\n& TV');
      case 'Bảo hiểm':
        return context.tr(value, 'Insurance');
      case 'Học phí':
        return context.tr(value, 'Tuition');
      case 'Thuế &\nphí khác':
        return context.tr(value, 'Tax &\nfees');
      case 'Vé xem\nphim':
        return context.tr(value, 'Movie\ntickets');
      case 'Vé sự kiện':
        return context.tr(value, 'Event tickets');
      case 'Xổ số':
        return context.tr(value, 'Lottery');
      case 'Âm nhạc':
        return context.tr(value, 'Music');
      case 'Đặt phòng\nkhách sạn':
        return context.tr(value, 'Hotel\nbooking');
      case 'Vé máy\nbay':
        return context.tr(value, 'Flight\ntickets');
      case 'Vé tàu':
        return context.tr(value, 'Train tickets');
      case 'Vé xe':
        return context.tr(value, 'Bus tickets');
      case 'Gọi xe':
        return context.tr(value, 'Ride-hailing');
      case 'Thuê xe\ndu lịch':
        return context.tr(value, 'Car rental');
      case 'Đặt lịch\nkhám':
        return context.tr(value, 'Book\ncheck-up');
      case 'Nhà thuốc':
        return context.tr(value, 'Pharmacy');
      case 'Bảo hiểm\nsức khỏe':
        return context.tr(value, 'Health\ninsurance');
      default:
        return value;
    }
  }

  String _bannerTitle(BuildContext context, String value) {
    switch (value) {
      case 'Flash Sale hôm nay':
        return context.tr(value, 'Today\'s flash sale');
      case 'Đặt phòng khách sạn':
        return context.tr(value, 'Hotel booking');
      case 'Thanh toán hóa đơn':
        return context.tr(value, 'Bill payment');
      case 'Vé xem phim':
        return context.tr(value, 'Movie tickets');
      default:
        return value;
    }
  }

  String _bannerSubtitle(BuildContext context, String value) {
    switch (value) {
      case 'Giảm đến 50% dịch vụ nạp thẻ':
        return context.tr(value, 'Up to 50% off mobile top-up services');
      case 'Ưu đãi cuối tuần — giảm 25%':
        return context.tr(value, 'Weekend offer — save 25%');
      case 'Hoàn tiền 2% mọi hóa đơn điện nước':
        return context.tr(value, 'Get 2% cashback on utility bills');
      case 'Chỉ 75.000đ — áp dụng mọi rạp':
        return context.tr(value, 'Only 75,000 VND — all cinemas');
      default:
        return value;
    }
  }

  void _onItemTap(_UtilityItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final t = NovaTheme.watch(sheetContext);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: t.primaryMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: t.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 28, color: t.primary),
              ),
              const SizedBox(height: 16),
              Text(
                _itemLabel(context, item.label).replaceAll('\n', ' '),
                style: NovaFonts.heading.copyWith(
                  fontSize: 18,
                  color: t.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: t.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock, size: 16, color: t.primary),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(
                        'Tính năng đang được phát triển',
                        'This feature is in development',
                      ),
                      style: NovaFonts.body.copyWith(
                        color: t.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  'Chúng tôi đang hoàn thiện tính năng này.\nVui lòng quay lại sau!',
                  'We are still working on this feature.\nPlease check back later!',
                ),
                style: NovaFonts.body.copyWith(
                  color: t.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.tr('Đã hiểu', 'Got it'),
                    style: NovaFonts.heading.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    final filtered = _filteredSections;

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Header.withTitle(
              title: context.tr('Tiện ích cuộc sống', 'Lifestyle utilities'),
              onBack: () => Navigator.pop(context),
            ),

            // ── Search bar — dùng TextField với controller thường để tránh lỗi IME ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [t.cardShadow],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(LucideIcons.search, size: 18, color: t.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        // Dùng TextField thuần, KHÔNG dùng SearchBar/SearchAnchor
                        // để tránh bug IME composition với bộ gõ tiếng Việt
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: NovaFonts.body.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: context.tr(
                            'Tìm kiếm dịch vụ...',
                            'Search services...',
                          ),
                          hintStyle: NovaFonts.body.copyWith(
                            color: t.textSecondary,
                            fontSize: 14,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: t.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ─────────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 40,
                            color: t.primaryMid,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr(
                              'Không tìm thấy dịch vụ',
                              'No service found',
                            ),
                            style: NovaFonts.body.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        children: [
                          // ── Banner carousel ──
                          if (_query.isEmpty) ...[
                            _buildBannerCarousel(context),
                            const SizedBox(height: 16),
                          ],
                          // ── Sections ──
                          ...List.generate(filtered.length, (i) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: i < filtered.length - 1 ? 12 : 0,
                              ),
                              child: _AnimatedSection(
                                delay: Duration(milliseconds: 60 * i),
                                child: _buildSection(context, filtered[i]),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner Carousel ──────────────────────────────────────────────────────────
  Widget _buildBannerCarousel(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemCount: _banners.length,
            itemBuilder: (_, i) => _buildBannerCard(context, _banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final isActive = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? t.primary : t.primaryMid,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, _BannerItem banner) {
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
                  color: banner.accentColor.withOpacity(0.18),
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
                  color: banner.accentColor.withOpacity(0.12),
                ),
              ),
            ),
            // Content
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
                      color: banner.accentColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.tr('Ưu đãi', 'Offer'),
                      style: NovaFonts.body.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bannerTitle(context, banner.title),
                    style: NovaFonts.heading.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bannerSubtitle(context, banner.subtitle),
                    style: NovaFonts.body.copyWith(
                      color: Colors.white.withOpacity(0.75),
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
                    color: banner.accentColor.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    banner.icon,
                    size: 26,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, _UtilitySection section) {
    final t = NovaTheme.watch(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [t.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sectionTitle(context, section.title),
            style: NovaFonts.heading.copyWith(
              fontSize: 14,
              color: t.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: section.items.length,
            itemBuilder: (_, j) => _buildItem(context, section.items[j]),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, _UtilityItem item) {
    final t = NovaTheme.watch(context);
    return GestureDetector(
      onTap: () => _onItemTap(item),
      behavior: HitTestBehavior.opaque, // Đảm bảo bắt sự kiện chạm nhạy hơn
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: t.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 24, color: t.primary),
              ),
              if (item.badge != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge!,
                      style: NovaFonts.body.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            _itemLabel(context, item.label),
            textAlign: TextAlign.center,
            style: NovaFonts.body.copyWith(
              fontSize: 11,
              color: t.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated section ────────────────────
class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _AnimatedSection({required this.child, required this.delay});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─── Animated item ─────────────────────────────────────
class _AnimatedItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedItem({required this.child, required this.onTap});

  @override
  State<_AnimatedItem> createState() => _AnimatedItemState();
}

class _AnimatedItemState extends State<_AnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
