import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../l10n/app_lang.dart';
import '../providers/language_provider.dart';
import '../theme/colors.dart';
import '../theme/fonts.dart';
import '../providers/user_provider.dart';
import '../data/models/models.dart';
import '../widgets/header.dart';

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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tab,
                    indicator: BoxDecoration(
                      color: t.primary,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: t.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: t.textSecondary,
                    labelStyle: NovaFonts.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: NovaFonts.body.copyWith(fontSize: 13),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    tabs: [
                      Tab(text: context.tr('Của tôi', 'Mine')),
                      Tab(text: context.tr('Biến động', 'Activity')),
                    ],
                  ),
                ),
              ),

              // ── Search bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    style: NovaFonts.body.copyWith(
                      fontSize: 14,
                      color: t.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'Tìm kiếm thông báo, giao dịch...',
                        'Search notifications, transactions...',
                      ),
                      hintStyle: NovaFonts.body.copyWith(
                        color: t.textSecondary,
                        fontSize: 13,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Icon(
                          LucideIcons.search,
                          size: 18,
                          color: t.textSecondary,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 44),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
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
      return _EmptyState(
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
        itemBuilder: (_, i) => _NotificationCard(
          notification: list[i],
          isVietnamese: isVi,
          onDelete: () => onDelete(list[i]),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isVietnamese;
  final Future<void> Function() onDelete;

  const _NotificationCard({
    required this.notification,
    required this.isVietnamese,
    required this.onDelete,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NovaTheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final t = NovaTheme.watch(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: t.primaryMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(LucideIcons.copy, color: t.textPrimary, size: 20),
                title: Text(
                  context.tr('Sao chép nội dung', 'Copy content'),
                  style: NovaFonts.body.copyWith(fontSize: 14),
                ),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: notification.localizedContent(isVietnamese),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  LucideIcons.trash2,
                  color: NovaColors.error,
                  size: 20,
                ),
                title: Text(
                  context.tr('Xoá thông báo', 'Delete notification'),
                  style: NovaFonts.body.copyWith(
                    fontSize: 14,
                    color: NovaColors.error,
                  ),
                ),
                onTap: () async {
                  await onDelete();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    final isUnread = !notification.isRead;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: isUnread
            ? Border.all(color: t.primary.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.primaryLight,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(LucideIcons.bell, size: 20, color: t.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.localizedTitle(isVietnamese),
                          style: NovaFonts.heading.copyWith(
                            fontSize: 13,
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: t.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.localizedContent(isVietnamese),
                    style: NovaFonts.body.copyWith(
                      fontSize: 13,
                      color: t.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'HH:mm • dd/MM/yyyy',
                    ).format(notification.createdAt),
                    style: NovaFonts.body.copyWith(
                      fontSize: 11,
                      color: t.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showOptions(context),
              child: Icon(
                LucideIcons.moreVertical,
                size: 18,
                color: t.textSecondary,
              ),
            ),
          ],
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
      return _EmptyState(
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
              _DateBadge(date: date),
              ...items.map(
                (t) => _TxCard(t: t, userId: userId, wallet: wallet),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String date;
  const _DateBadge({required this.date});

  String get _label {
    final now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final yesterday = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now().subtract(const Duration(days: 1)));
    if (date == now) return 'today_key';
    if (date == yesterday) return 'yesterday_key';
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: t.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _label == 'today_key'
              ? context.tr('Hôm nay', 'Today')
              : _label == 'yesterday_key'
              ? context.tr('Hôm qua', 'Yesterday')
              : _label,
          style: NovaFonts.body.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: t.primary,
          ),
        ),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  final TransactionModel t;
  final String userId;
  final WalletModel? wallet;

  const _TxCard({required this.t, required this.userId, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    final isIn = t.receiverId == userId;
    final fmt = NumberFormat('#,###', 'vi_VN');
    final amountStr = '${isIn ? '+' : '-'}${fmt.format(t.amount)} VND';
    final amtColor = isIn ? theme.primary : NovaColors.error;
    final timeStr = DateFormat('HH:mm:ss').format(t.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeStr,
                  style: NovaFonts.body.copyWith(
                    fontSize: 12,
                    color: theme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.checkCircle2,
                    size: 11,
                    color: theme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              context.tr('Nova Banking thông báo', 'Nova Banking notification'),
              style: NovaFonts.heading.copyWith(
                fontSize: 14,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: theme.primaryLight),
            const SizedBox(height: 10),
            _InfoRow(
              label: context.tr('Tài khoản', 'Account'),
              value: wallet?.accountNumber ?? 'N/A',
            ),
            _InfoRow(
              label: context.tr('Số tiền', 'Amount'),
              value: amountStr,
              valueColor: amtColor,
              bold: true,
            ),
            _InfoRow(
              label: context.tr('Số dư cuối', 'Ending balance'),
              value: '${fmt.format(t.balanceAfter)} VND',
            ),
            _InfoRow(
              label: context.tr('Nội dung', 'Description'),
              value: t.description?.isNotEmpty == true ? t.description! : '—',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: t.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: valueColor ?? t.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared
// =============================================================================
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: t.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: t.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: NovaFonts.body.copyWith(
              fontSize: 14,
              color: t.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
