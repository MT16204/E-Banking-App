import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../l10n/app_lang.dart';
import '../theme/colors.dart';
import '../theme/fonts.dart';
import '../providers/user_provider.dart';
import '../data/models/models.dart';
import '../widgets/header.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    final provider = context.watch<UserProvider>();
    final userId = provider.user?.$id ?? '';
    final all = provider.transactions;

    final list = all.where((tx) {
      if (_filter == 'sent') return tx.senderId == userId;
      if (_filter == 'received') return tx.receiverId == userId;
      return true;
    }).toList();

    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in list) {
      final key = DateFormat('dd/MM/yyyy').format(tx.createdAt.toLocal());
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: t.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: t.isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: t.background, // ← đổi
        body: SafeArea(
          child: Column(
            children: [
              Header.withTitle(
                title: context.tr('Lịch sử giao dịch', 'Transaction history'),
              ),
              _FilterBar(
                selected: _filter,
                onChanged: (v) => setState(() => _filter = v),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchTransactions(userId),
                  color: t.primary, // ← đổi
                  child: list.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                          itemCount: grouped.length,
                          itemBuilder: (_, i) {
                            final date = grouped.keys.elementAt(i);
                            final items = grouped[date]!;
                            return _DaySection(
                              date: date,
                              items: items,
                              userId: userId,
                            );
                          },
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

// ── _FilterBar ────────────────────────────────────────────────────────────────
// surface (trắng) giữ nguyên — filter bar luôn trắng bất kể theme

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: t.surface, // ← đổi
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _Chip(
              label: context.tr('Tất cả', 'All'),
              value: 'all',
              selected: selected,
              onTap: onChanged,
            ),
            _Chip(
              label: context.tr('Đã gửi', 'Sent'),
              value: 'sent',
              selected: selected,
              onTap: onChanged,
            ),
            _Chip(
              label: context.tr('Đã nhận', 'Received'),
              value: 'received',
              selected: selected,
              onTap: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _Chip ─────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _Chip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    final isActive = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? t.primary : Colors.transparent, // ← đổi
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: t.primary.withOpacity(0.35), // ← đổi
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive ? Colors.white : t.textSecondary, // ← đổi
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── _DaySection ───────────────────────────────────────────────────────────────
// Header ngày tháng: màu muted tint từ primaryMid để hài hoà với theme hiện tại.
// Card trắng (surface) — giữ nguyên màu trắng, đây là card nội dung.

class _DaySection extends StatelessWidget {
  final String date;
  final List<TransactionModel> items;
  final String userId;
  const _DaySection({
    required this.date,
    required this.items,
    required this.userId,
  });

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
    final t = NovaTheme.watch(context); // ← theme động
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            children: [
              Text(
                _label == 'today_key'
                    ? context.tr('Hôm nay', 'Today')
                    : _label == 'yesterday_key'
                    ? context.tr('Hôm qua', 'Yesterday')
                    : date,
                style: NovaFonts.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.primaryMid, // ← đổi (thay 0xFF8A9E99 hardcode)
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: t.primaryMid.withOpacity(
                    0.35,
                  ), // ← đổi (thay 0xFFE4EDEA hardcode)
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: t.surface, // ← đổi
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  _TxRow(t: items[i], userId: userId),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: t.primaryLight, // ← đổi (thay 0xFFF0F4F3 hardcode)
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── _TxRow ────────────────────────────────────────────────────────────────────

class _TxRow extends StatelessWidget {
  final TransactionModel t;
  final String userId;
  const _TxRow({required this.t, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(
      context,
    );
    final isReceived = t.receiverId == userId;
    final fmt = NumberFormat('#,###', 'vi_VN');
    final desc = t.description?.isNotEmpty == true
        ? t.description!
        : (isReceived
              ? context.tr('Nhận tiền', 'Money received')
              : context.tr('Chuyển tiền', 'Money transfer'));
    final amountStr = '${isReceived ? '+' : '-'}${fmt.format(t.amount)} VND';
    final timeStr = DateFormat('HH:mm').format(t.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isReceived
                  ? theme
                        .primaryLight // ← đổi
                  : theme.background, // ← đổi
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isReceived ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              size: 18,
              color: isReceived
                  ? theme
                        .primary // ← đổi
                  : theme.textSecondary, // ← đổi
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary, // ← đổi
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(t.createdAt)}  |  $timeStr',
                  style: NovaFonts.body.copyWith(
                    fontSize: 12,
                    color: theme.textSecondary, // ← đổi
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountStr,
                style: NovaFonts.numbers.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isReceived
                      ? theme
                            .primary 
                      : theme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.tr('Hoàn thành', 'Completed'),
                  style: NovaFonts.body.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: theme.primary, 
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── _EmptyState ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = NovaTheme.watch(context); // ← theme động
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: t.primaryLight, // ← đổi (bỏ const vì giờ là dynamic)
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.inbox,
                  size: 32,
                  color: t.primary, // ← đổi (bỏ const)
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('Chưa có giao dịch nào', 'No transactions yet'),
                style: NovaFonts.body.copyWith(
                  fontSize: 14,
                  color: t.textSecondary, // ← đổi
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
