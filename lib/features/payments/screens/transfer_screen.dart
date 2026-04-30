import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:banking_app/data/models/models.dart';
import 'package:banking_app/data/repositories/wallet_repository.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'package:banking_app/widgets/header.dart';
import 'package:banking_app/widgets/transfer_amount_card.dart';
import 'package:banking_app/widgets/transfer_bottom_bar.dart';
import 'package:banking_app/widgets/transfer_fast_toggle.dart';
import 'package:banking_app/widgets/transfer_note_card.dart';
import 'package:banking_app/widgets/transfer_source_card.dart';
import 'transfer_confirm_screen.dart';

class TransferScreen extends StatefulWidget {
  final String? prefillAccountNumber;
  final UserModel? prefillUser;

  const TransferScreen({
    super.key,
    this.prefillAccountNumber,
    this.prefillUser,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with SingleTickerProviderStateMixin {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _accountFocusNode = FocusNode();

  UserModel? _recipientUser;
  bool _isLoading = false;
  bool _isFastTransfer = true;
  String? _selectedCategoryId;
  String? _errorText;
  bool _showRecentList = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  final Map<String, String> _recipientNames = {};
  bool _loadingRecipientNames = false;

  final List<TransferSpendingCategory> _categories = const [
    TransferSpendingCategory(
      id: 'food',
      label: 'Nhà hàng\nquán ăn',
      icon: LucideIcons.utensils,
    ),
    TransferSpendingCategory(
      id: 'misc',
      label: 'Tiêu vặt',
      icon: LucideIcons.coffee,
    ),
    TransferSpendingCategory(
      id: 'fashion',
      label: 'Quần áo\nvà phụ kiện',
      icon: LucideIcons.shoppingBag,
    ),
    TransferSpendingCategory(
      id: 'transport',
      label: 'Di chuyển',
      icon: LucideIcons.car,
    ),
    TransferSpendingCategory(
      id: 'health',
      label: 'Sức khỏe',
      icon: LucideIcons.heart,
    ),
    TransferSpendingCategory(
      id: 'education',
      label: 'Giáo dục',
      icon: LucideIcons.bookOpen,
    ),
    TransferSpendingCategory(
      id: 'bill',
      label: 'Hóa đơn',
      icon: LucideIcons.fileText,
    ),
    TransferSpendingCategory(id: 'other', label: 'Khác', icon: LucideIcons.grid),
  ];

  DateTime? _lastTyped;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    if (widget.prefillAccountNumber != null) {
      _accountController.text = widget.prefillAccountNumber!;
    }

    _accountController.addListener(_onAccountChanged);

    _accountFocusNode.addListener(() {
      if (!mounted) return;
      if (_accountFocusNode.hasFocus &&
          _recipientUser == null &&
          _accountController.text.trim().isEmpty) {
        setState(() => _showRecentList = true);
        _loadRecipientNames();
      } else if (!_accountFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showRecentList = false);
        });
      }
    });

    if (widget.prefillUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _recipientUser = widget.prefillUser;
          _noteController.text =
              '${context.read<UserProvider>().user?.name.toUpperCase() ?? ''} Chuyen tien';
        });
      });
    }
  }

  @override
  void dispose() {
    _accountController.removeListener(_onAccountChanged);
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _accountFocusNode.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecipientNames() async {
    if (_loadingRecipientNames) return;
    _loadingRecipientNames = true;

    final recentList = _getRecentTransfers();
    final walletRepo = context.read<WalletRepository>();
    final toLoad = recentList
        .where((t) => !_recipientNames.containsKey(t.receiverId))
        .toList();

    for (final t in toLoad) {
      try {
        final result = await walletRepo.lookupAccountByNumber(
          (await walletRepo.getWalletByUserId(t.receiverId))?.accountNumber ??
              '',
        );
        final user = result['user'] as UserModel;
        if (mounted) {
          setState(() => _recipientNames[t.receiverId] = user.fullName);
        }
      } catch (_) {}
    }

    _loadingRecipientNames = false;
  }

  void _onAccountChanged() {
    if (!mounted) return;
    final text = _accountController.text.trim();

    if (widget.prefillUser != null && _recipientUser != null) return;

    if (_recipientUser != null || _errorText != null) {
      setState(() {
        _recipientUser = null;
        _errorText = null;
      });
    }

    final shouldShowRecent =
        text.isEmpty && _accountFocusNode.hasFocus && _recipientUser == null;
    if (shouldShowRecent != _showRecentList) {
      setState(() => _showRecentList = shouldShowRecent);
      if (shouldShowRecent) _loadRecipientNames();
    }

    if (text.length >= 6) {
      final captured = _lastTyped = DateTime.now();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        if (_lastTyped == captured && _recipientUser == null) {
          _lookupAccount();
        }
      });
    }
  }

  List<TransactionModel> _getRecentTransfers() {
    final prov = context.read<UserProvider>();
    final uid = prov.user?.$id ?? '';
    final seen = <String>{};
    final out = <TransactionModel>[];
    for (final t in prov.transactions.where((t) => t.senderId == uid)) {
      if (seen.add(t.receiverId)) out.add(t);
      if (out.length >= 5) break;
    }
    return out;
  }

  Future<void> _selectRecentTransfer(TransactionModel t) async {
    _accountFocusNode.unfocus();
    setState(() {
      _showRecentList = false;
      _isLoading = true;
      _errorText = null;
    });

    try {
      final walletRepo = context.read<WalletRepository>();
      final wallet = await walletRepo.getWalletByUserId(t.receiverId);
      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      _accountController.removeListener(_onAccountChanged);
      _accountController.text = wallet.accountNumber;
      _accountController.addListener(_onAccountChanged);

      final result = await walletRepo.lookupAccountByNumber(
        wallet.accountNumber,
      );
      final user = result['user'] as UserModel;
      if (mounted) {
        setState(() {
          _recipientUser = user;
          _noteController.text =
              '${context.read<UserProvider>().user?.name.toUpperCase() ?? ''} Chuyen tien';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorText = context.tr(
            'Không tìm thấy tài khoản',
            'Account not found',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _lookupAccount() async {
    final number = _accountController.text.trim();
    if (number.isEmpty) return;

    final myNumber = context.read<UserProvider>().wallet?.accountNumber ?? '';
    if (number == myNumber) {
      setState(
        () => _errorText = context.tr(
          'Không thể chuyển tiền cho chính mình',
          'You cannot transfer money to yourself',
        ),
      );
      _shakeCtrl.forward(from: 0);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
      _recipientUser = null;
    });

    try {
      final result = await context.read<WalletRepository>().lookupAccountByNumber(
        number,
      );
      final user = result['user'] as UserModel;
      if (mounted) {
        setState(() {
          _recipientUser = user;
          _noteController.text =
              '${context.read<UserProvider>().user?.name.toUpperCase() ?? ''} Chuyen tien';
        });
      }
    } catch (e) {
      if (mounted) {
        _shakeCtrl.forward(from: 0);
        setState(
          () => _errorText = context.tr(
            'Không tìm thấy tài khoản Nova Banking',
            'Nova Banking account not found',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContinue() {
    final number = _accountController.text.trim();
    final rawAmt = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '');
    final amount = double.tryParse(rawAmt) ?? 0;
    final provider = context.read<UserProvider>();

    if (number.isEmpty) {
      _showSnack(
        context.tr(
          'Vui lòng nhập số tài khoản thụ hưởng',
          'Please enter the recipient account number',
        ),
      );
      return;
    }
    if (_recipientUser == null) {
      _showSnack(
        context.tr(
          'Vui lòng tra cứu tài khoản trước',
          'Please look up the account first',
        ),
      );
      return;
    }
    if (amount <= 0) {
      _showSnack(
        context.tr(
          'Vui lòng nhập số tiền cần chuyển',
          'Please enter an amount to transfer',
        ),
      );
      return;
    }
    if (amount > (provider.wallet?.balance ?? 0)) {
      _showSnack(context.tr('Số dư không đủ', 'Insufficient balance'));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferConfirmScreen(
          senderUserId: provider.user?.$id ?? '',
          sourceAccountNumber: provider.wallet?.accountNumber ?? '',
          recipientAccountNumber: number,
          recipientName: _recipientUser!.fullName.toUpperCase(),
          recipientBank: 'Nova Banking',
          amount: amount,
          note: _noteController.text,
          isFastTransfer: _isFastTransfer,
          categoryId: _selectedCategoryId,
        ),
      ),
    );
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.watch(context);
    return Scaffold(
      backgroundColor: theme.background,
      resizeToAvoidBottomInset: true,
      body: TapRegion(
        onTapOutside: (event) {
          _accountFocusNode.unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              Header.withTitle(
                title: context.tr('Thông tin chuyển tiền', 'Transfer details'),
                onBack: () => Navigator.pop(context),
                action: IconButton(
                  icon: Icon(LucideIcons.home, color: theme.textPrimary),
                  onPressed: () => Navigator.of(
                    context,
                  ).popUntil(ModalRoute.withName('/home')),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    children: [
                      _buildSourceCard(),
                      const SizedBox(height: 16),
                      _buildRecipientCard(),
                      const SizedBox(height: 16),
                      _buildAmountCard(),
                      const SizedBox(height: 16),
                      _buildNoteCard(),
                      const SizedBox(height: 16),
                      _buildFastToggle(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: TransferBottomBar(onContinue: _onContinue),
    );
  }

  Widget _buildSourceCard() => Consumer<UserProvider>(
    builder: (_, prov, __) {
      final theme = NovaTheme.watch(context);
      return TransferSourceCard(
        primaryColor: theme.primary,
        accountLabel: context.tr(
          'TK nguồn: ${prov.wallet?.accountNumber ?? '****'}',
          'Source account: ${prov.wallet?.accountNumber ?? '****'}',
        ),
        balanceLabel: context.tr('Số dư', 'Balance'),
        balance: prov.wallet?.balance ?? 0,
      );
    },
  );

  Widget _buildRecipientCard() {
    final theme = NovaTheme.watch(context);
    final recentList = _showRecentList
        ? _getRecentTransfers()
        : <TransactionModel>[];

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          _shakeAnim.value * ((_shakeCtrl.value * 10).floor().isEven ? 1 : -1),
          0,
        ),
        child: child,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: recentList.isNotEmpty
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : BorderRadius.circular(16),
              border: _errorText != null
                  ? Border.all(color: theme.error.withValues(alpha: 0.55))
                  : null,
            ),
            child: Column(
              children: [
                if (_recipientUser != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.userCheck,
                            color: theme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _recipientUser!.fullName.toUpperCase(),
                                    style: NovaFonts.heading.copyWith(
                                      fontSize: 14,
                                      color: theme.primary,
                                    ),
                                  ),
                                  if (widget.prefillUser != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.qrCode,
                                            size: 10,
                                            color: theme.primary,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'QR',
                                            style: NovaFonts.body.copyWith(
                                              fontSize: 10,
                                              color: theme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${_accountController.text} • Nova Banking',
                                style: NovaFonts.body.copyWith(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _accountController.clear();
                            _recipientUser = null;
                            _errorText = null;
                          }),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_recipientUser == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _accountController,
                            focusNode: _accountFocusNode,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: context.tr(
                                'Nhập số tài khoản thụ hưởng',
                                'Enter recipient account number',
                              ),
                              hintStyle: NovaFonts.body.copyWith(
                                color: theme.textSecondary,
                              ),
                              border: InputBorder.none,
                              errorText: _errorText,
                              errorStyle: TextStyle(
                                fontSize: 12,
                                color: theme.error,
                              ),
                            ),
                            onSubmitted: (_) => _lookupAccount(),
                            style: NovaFonts.body.copyWith(
                              fontSize: 15,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.primary,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(LucideIcons.search, size: 20),
                            color: theme.primary,
                            onPressed: _lookupAccount,
                            tooltip: context.tr('Tra cứu', 'Look up'),
                          ),
                      ],
                    ),
                  ),

                if (_recipientUser != null) const SizedBox(height: 14),
              ],
            ),
          ),

          if (recentList.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    color: theme.primaryMid.withValues(alpha: 0.25),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Text(
                      context.tr('Đã chuyển gần đây', 'Recent transfers'),
                      style: NovaFonts.body.copyWith(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...recentList.map((t) => _buildRecentItem(t)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(TransactionModel t) {
    final theme = NovaTheme.watch(context);
    final fmt = NumberFormat('#,###', 'vi_VN');
    final recipientName = _recipientNames[t.receiverId];

    return InkWell(
      onTap: () => _selectRecentTransfer(t),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5F0),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.user, color: theme.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  recipientName != null
                      ? Text(
                          recipientName.toUpperCase(),
                          style: NovaFonts.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        )
                      : Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy').format(t.createdAt),
                    style: NovaFonts.body.copyWith(
                      color: theme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${fmt.format(t.amount)} VND',
              style: NovaFonts.body.copyWith(
                fontSize: 13,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() => TransferAmountCard(
    controller: _amountController,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      _ThousandsSeparatorFormatter(),
    ],
    onQuickAmountTap: (amount) {
      _amountController.text = NumberFormat('#,###', 'vi_VN').format(amount);
    },
  );

  Widget _buildNoteCard() => TransferNoteCard(
    noteController: _noteController,
    categories: _categories
        .map(
          (category) => TransferSpendingCategory(
            id: category.id,
            label: _localizedCategoryLabel(context, category.id),
            icon: category.icon,
          ),
        )
        .toList(),
    selectedCategoryId: _selectedCategoryId,
    onCategoryChanged: (value) => setState(() => _selectedCategoryId = value),
  );

  Widget _buildFastToggle() => TransferFastToggle(
    value: _isFastTransfer,
    onChanged: (value) => setState(() => _isFastTransfer = value),
  );

  String _localizedCategoryLabel(BuildContext context, String id) {
    switch (id) {
      case 'food':
        return context.tr('Nhà hàng\nquán ăn', 'Food\n& dining');
      case 'misc':
        return context.tr('Tiêu vặt', 'Misc');
      case 'fashion':
        return context.tr('Quần áo\nvà phụ kiện', 'Fashion\n& accessories');
      case 'transport':
        return context.tr('Di chuyển', 'Transport');
      case 'health':
        return context.tr('Sức khỏe', 'Health');
      case 'education':
        return context.tr('Giáo dục', 'Education');
      case 'bill':
        return context.tr('Hóa đơn', 'Bills');
      case 'other':
        return context.tr('Khác', 'Other');
      default:
        return id;
    }
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = NumberFormat('#,###', 'vi_VN').format(int.parse(digits));
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
