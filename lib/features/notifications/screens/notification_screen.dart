import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:banking_app/providers/language_provider.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'package:banking_app/widgets/header.dart';
import 'package:banking_app/widgets/notification_card.dart';
import 'package:banking_app/widgets/notification_empty_state.dart';
import 'package:banking_app/widgets/notification_search_bar.dart';
import 'package:banking_app/widgets/notification_tab_bar.dart';
import 'package:banking_app/widgets/notification_transaction_card.dart';

String _normalize(String s) {
  const map = {
    'à': 'a',
    'á': 'a',
    'ả': 'a',
    'ã': 'a',
    'ạ': 'a',
    'ă': 'a',
    'ắ': 'a',
    'ằ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'ặ': 'a',
    'â': 'a',
    'ấ': 'a',
    'ầ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ậ': 'a',
    'è': 'e',
    'é': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ẹ': 'e',
    'ê': 'e',
    'ế': 'e',
    'ề': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ệ': 'e',
    'ì': 'i',
    'í': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ị': 'i',
    'ò': 'o',
    'ó': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ọ': 'o',
    'ô': 'o',
    'ố': 'o',
    'ồ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ộ': 'o',
    'ơ': 'o',
    'ớ': 'o',
    'ờ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ợ': 'o',
    'ù': 'u',
    'ú': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ụ': 'u',
    'ư': 'u',
    'ứ': 'u',
    'ừ': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ự': 'u',
    'ỳ': 'y',
    'ý': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'ỵ': 'y',
    'đ': 'd',
  };
  final buf = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    buf.write(map[ch] ?? ch);
  }
  return buf.toString();
}

bool _fuzzyMatch(String source, String query) {
  if (query.isEmpty) return true;
  return _normalize(source).contains(_normalize(query));
}

// =============================================================================
// Extension — dịch title/content sang ngôn ngữ hiện tại.
//
// Chiến lược KHÔNG cần thay đổi model hay DB:
//   1. Nếu model có field `params` (doc mới từ auth_repository) → parse JSON.
//   2. Nếu không → regex parse trực tiếp content tiếng Việt để tái tạo câu EN.
//
// Pattern content tiếng Việt (từ auth_repository):
//   "Bạn vừa nhận 500.000 VND từ TK 1234567890. Nội dung: Tiền học"
//   "Bạn vừa nhận 500.000 VND từ TK 1234567890."  (không có note)
// =============================================================================
extension NotificationL10n on NotificationModel {
  // Regex extract tham số từ content tiếng Việt
  static final _transferRx = RegExp(
    r'Bạn vừa nhận ([\d\.,]+) VND từ TK (\S+?)\.(?:\s*Nội dung:\s*(.+))?$',
  );

  String localizedTitle(bool isVietnamese) {
    if (isVietnamese) return title;
    // Dịch title cứng theo type
    switch (type) {
      case 'transfer':
        return 'Transfer received';
      default:
        // Với các type khác chưa có bản dịch → giữ nguyên
        return title;
    }
  }

  String localizedContent(bool isVietnamese) {
    if (isVietnamese) return content;

    // ── Thử parse content tiếng Việt ──────────────────────────────────────
    if (type == 'transfer') {
      final m = _transferRx.firstMatch(content.trim());
      if (m != null) {
        final amount = m.group(1) ?? '';
        final acc = m.group(2) ?? '';
        final note = (m.group(3) ?? '').trim();
        return 'You received $amount VND from account $acc.'
            '${note.isNotEmpty ? ' Note: $note' : ''}';
      }
    }

    // Fallback: không parse được → giữ nguyên
    return content;
  }
}

// =============================================================================
// Screen
// =============================================================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _query = '';

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

  // ── Filter helpers ──────────────────────────────────────────────────────────

  List<TransactionModel> _filterTx(
    List<TransactionModel> list,
    String accountNumber,
  ) {
    if (_query.isEmpty) return list;
    final rawQ = _query.trim();
    final digitsQ = rawQ.replaceAll(RegExp(r'[^\d]'), '');
    final acctDigits = accountNumber.replaceAll(RegExp(r'[^\d]'), '');
    final fmt = NumberFormat('#,###', 'vi_VN');

    return list.where((t) {
      if (_fuzzyMatch(t.description ?? '', rawQ)) return true;
      if (digitsQ.isNotEmpty && acctDigits.contains(digitsQ)) return true;
      if (digitsQ.isNotEmpty && t.amount.toStringAsFixed(0).contains(digitsQ)) {
        return true;
      }
      if (_fuzzyMatch(fmt.format(t.amount), rawQ)) return true;
      if (digitsQ.isNotEmpty &&
          t.balanceAfter.toStringAsFixed(0).contains(digitsQ)) {
        return true;
      }
      if (_fuzzyMatch(fmt.format(t.balanceAfter), rawQ)) return true;
      return false;
    }).toList();
  }

  List<NotificationModel> _filterNotifs(List<NotificationModel> list) {
    if (_query.isEmpty) return list;
    return list
        .where(
          (n) => _fuzzyMatch(n.title, _query) || _fuzzyMatch(n.content, _query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    final provider = context.watch<UserProvider>();
    final userId = provider.user?.$id ?? '';
    final accountNumber = provider.wallet?.accountNumber ?? '';
    final unread = provider.notifications.where((n) => !n.isRead).length;

    final filteredTrans = _filterTx(provider.transactions, accountNumber);
    final filteredNotis = _filterNotifs(provider.notifications);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: t.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: t.isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: t.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Header.withTitle(
                title: context.tr('Thông báo', 'Notifications'),
                action: unread > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.tr('$unread mới', '$unread new'),
                          style: NovaFonts.body.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : null,
              ),

              // ── Tab bar ──────────────────────────────────────────────────────
              NotificationTabBar(controller: _tab),

              // ── Search bar ───────────────────────────────────────────────────
              NotificationSearchBar(
                onChanged: (value) => setState(() => _query = value),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _NotificationTab(
                      list: filteredNotis,
                      userId: userId,
                      onDelete: (n) async =>
                          context.read<UserProvider>().deleteNotification(n.id),
                      onRefresh: () async => context
                          .read<UserProvider>()
                          .fetchNotifications(userId),
                    ),
                    _TransactionTab(
                      list: filteredTrans,
                      userId: userId,
                      wallet: provider.wallet,
                      onRefresh: () async => context
                          .read<UserProvider>()
                          .fetchTransactions(userId),
                    ),
                  ],
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
// Tab 1 — Thông báo cá nhân
// =============================================================================
class _NotificationTab extends StatelessWidget {
  final List<NotificationModel> list;
  final String userId;
  final Future<void> Function(NotificationModel) onDelete;
  final Future<void> Function() onRefresh;

  const _NotificationTab({
    required this.list,
    required this.userId,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    final isVi = context.watch<LanguageProvider>().isVietnamese;
    if (list.isEmpty) {
      return NotificationEmptyState(
        icon: LucideIcons.bellOff,
        message: context.tr('Chưa có thông báo nào', 'No notifications yet'),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: t.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
        itemCount: list.length,
        itemBuilder: (_, i) => NotificationCard(
          notification: list[i],
          isVietnamese: isVi,
          onDelete: () => onDelete(list[i]),
          getTitle: (notification, isVietnamese) =>
              notification.localizedTitle(isVietnamese),
          getContent: (notification, isVietnamese) =>
              notification.localizedContent(isVietnamese),
        ),
      ),
    );
  }
}

// =============================================================================
// Tab 2 — Biến động số dư
// =============================================================================
class _TransactionTab extends StatelessWidget {
  final List<TransactionModel> list;
  final String userId;
  final WalletModel? wallet;
  final Future<void> Function() onRefresh;

  const _TransactionTab({
    required this.list,
    required this.userId,
    required this.wallet,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    if (list.isEmpty) {
      return NotificationEmptyState(
        icon: LucideIcons.trendingUp,
        message: context.tr('Chưa có biến động nào', 'No activity yet'),
      );
    }

    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in list) {
      final key = DateFormat('dd/MM/yyyy').format(t.createdAt.toLocal());
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: t.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
        itemCount: grouped.length,
        itemBuilder: (_, i) {
          final date = grouped.keys.elementAt(i);
          final items = grouped[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationDateBadge(date: date),
              ...items.map(
                (t) => NotificationTransactionCard(
                  transaction: t,
                  userId: userId,
                  wallet: wallet,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
