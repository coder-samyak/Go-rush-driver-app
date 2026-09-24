import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';
import '../services/wallet_service.dart';
import '../widgets/app_bottom_nav.dart';

class DriverWalletScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final Function(int)? onBottomNavTap;

  const DriverWalletScreen({
    super.key,
    this.onBackTap,
    this.onBottomNavTap,
  });

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen>
    with SingleTickerProviderStateMixin {
  final WalletService _walletService = WalletService.instance;
  late AnimationController _balanceAnimController;
  late Animation<double> _balanceFadeAnim;

  bool _isRechargingCustom = false;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _balanceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _balanceFadeAnim = CurvedAnimation(
      parent: _balanceAnimController,
      curve: Curves.easeOut,
    );
    _walletService.addListener(_onWalletChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWallet();
    });
  }

  @override
  void dispose() {
    _balanceAnimController.dispose();
    _amountController.dispose();
    _walletService.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    if (mounted) setState(() {});
    _balanceAnimController.forward(from: 0);
  }

  Future<void> _loadWallet() async {
    await _walletService.fetchWallet();
    await _walletService.fetchTransactions();
    if (mounted) _balanceAnimController.forward(from: 0);
  }

  Future<void> _showRechargeDialog() async {
    _amountController.clear();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RechargeBottomSheet(
        onRecharge: _processRecharge,
        amountController: _amountController,
      ),
    );
  }

  Future<void> _processRecharge(double amount) async {
    setState(() => _isRechargingCustom = true);
    try {
      final result = await _walletService.recharge(amount);
      if (!mounted) return;
      if (result.success) {
        AppToast.success(context, result.message);
        Navigator.of(context).pop();
        await _walletService.fetchTransactions();
      } else {
        AppToast.error(context, result.message);
      }
    } finally {
      if (mounted) setState(() => _isRechargingCustom = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = _walletService.wallet;
    final isLowBalance = _walletService.hasLowBalance;
    final isLoading = _walletService.isLoading;

    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Wallet',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: QuickServeColors.primaryBlue),
            tooltip: 'Refresh',
            onPressed: _loadWallet,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: isLoading && wallet == null
          ? const Center(
              child: CircularProgressIndicator(
                color: QuickServeColors.primaryBlue,
              ),
            )
          : RefreshIndicator(
              color: QuickServeColors.primaryBlue,
              onRefresh: _loadWallet,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Low Balance Warning ──────────────────────────
                    if (isLowBalance) ...[
                      _LowBalanceBanner(
                        balance: wallet?.balance ?? 0,
                        minimumRequired:
                            _walletService.minimumWalletBalance,
                        onAddMoney: _showRechargeDialog,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Wallet Balance Card ──────────────────────────
                    FadeTransition(
                      opacity: _balanceFadeAnim,
                      child: _WalletBalanceCard(
                        balance: wallet?.balance ?? 0,
                        minimumRequired:
                            _walletService.minimumWalletBalance,
                        currency: wallet?.currency ?? 'INR',
                        isBlocked: wallet?.isBlocked ?? false,
                        isSufficient: wallet?.isSufficient ?? false,
                        companyChargeValue:
                            _walletService.companyChargeValue,
                        companyChargeType:
                            _walletService.companyChargeType,
                        onAddMoney: _showRechargeDialog,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Quick Recharge Chips ─────────────────────────
                    _buildQuickRechargeRow(),

                    const SizedBox(height: 20),

                    // ── Wallet Stats Row ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _StatMiniCard(
                            label: 'Total Recharged',
                            value: WalletService.formatAmount(
                                wallet?.totalRecharged ?? 0),
                            icon: Icons.add_circle_outline_rounded,
                            color: QuickServeColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatMiniCard(
                            label: 'Company Charges',
                            value: WalletService.formatAmount(
                                wallet?.totalCompanyChargesDeducted ?? 0),
                            icon: Icons.account_balance_rounded,
                            color: QuickServeColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── Transaction History Header ───────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_walletService.transactions.length} records',
                          style: const TextStyle(
                            color: QuickServeColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Transaction List ─────────────────────────────
                    if (_walletService.transactions.isEmpty)
                      _buildEmptyTransactions()
                    else
                      ..._walletService.transactions
                          .map((txn) => _TransactionTile(txn: txn))
                          .toList(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: widget.onBottomNavTap ?? (_) {},
      ),
    );
  }

  Widget _buildQuickRechargeRow() {
    const quickAmounts = [100.0, 200.0, 500.0, 1000.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add Money',
          style: TextStyle(
            color: QuickServeColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: quickAmounts
              .map(
                (amt) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _QuickAmountChip(
                      amount: amt,
                      onTap: () async {
                        setState(() => _isRechargingCustom = true);
                        try {
                          final result = await _walletService.recharge(amt);
                          if (!mounted) return;
                          if (result.success) {
                            AppToast.success(context, result.message);
                            await _walletService.fetchTransactions();
                          } else {
                            AppToast.error(context, result.message);
                          }
                        } finally {
                          if (mounted)
                            setState(() => _isRechargingCustom = false);
                        }
                      },
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Column(
        children: const [
          Icon(Icons.receipt_long_outlined,
              size: 40, color: QuickServeColors.textMuted),
          SizedBox(height: 10),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Recharge your wallet or complete a ride\nto see your transactions here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: QuickServeColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wallet Balance Card ────────────────────────────────────────────────────
class _WalletBalanceCard extends StatelessWidget {
  final double balance;
  final double minimumRequired;
  final String currency;
  final bool isBlocked;
  final bool isSufficient;
  final double companyChargeValue;
  final String companyChargeType;
  final VoidCallback onAddMoney;

  const _WalletBalanceCard({
    required this.balance,
    required this.minimumRequired,
    required this.currency,
    required this.isBlocked,
    required this.isSufficient,
    required this.companyChargeValue,
    required this.companyChargeType,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isBlocked ? QuickServeColors.statusRed : isSufficient ? QuickServeColors.accentGreen : QuickServeColors.statusAmber;
    final statusLabel = isBlocked ? 'Blocked' : isSufficient ? 'Active' : 'Low Balance';
    final statusIcon = isBlocked
        ? Icons.block_rounded
        : isSufficient
            ? Icons.check_circle_rounded
            : Icons.warning_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MY WALLET',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Balance
          Text(
            WalletService.formatAmount(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 6),

          // Minimum required
          Row(
            children: [
              Icon(
                balance < minimumRequired
                    ? Icons.warning_amber_rounded
                    : Icons.info_outline_rounded,
                color: balance < minimumRequired
                    ? const Color(0xFFFCD34D)
                    : Colors.white54,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                'Minimum Required: ${WalletService.formatAmount(minimumRequired)}',
                style: TextStyle(
                  color: balance < minimumRequired
                      ? const Color(0xFFFCD34D)
                      : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Company charge info
          Text(
            'Company Charge: ${companyChargeType == 'PERCENTAGE' ? '${companyChargeValue.toStringAsFixed(0)}% of ride fare' : '₹${companyChargeValue.toStringAsFixed(0)} per ride'}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 20),

          // ADD MONEY button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddMoney,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'ADD MONEY',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Low Balance Banner ─────────────────────────────────────────────────────
class _LowBalanceBanner extends StatelessWidget {
  final double balance;
  final double minimumRequired;
  final VoidCallback onAddMoney;

  const _LowBalanceBanner({
    required this.balance,
    required this.minimumRequired,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: QuickServeColors.statusRedLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.statusRed.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: QuickServeColors.statusRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOW WALLET BALANCE',
                  style: TextStyle(
                    color: QuickServeColors.statusRed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current: ${WalletService.formatAmount(balance)} · Minimum: ${WalletService.formatAmount(minimumRequired)}',
                  style: TextStyle(
                    color: QuickServeColors.statusRed.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Add money to continue accepting rides.',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAddMoney,
            style: TextButton.styleFrom(
              foregroundColor: QuickServeColors.statusRed,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor:
                  QuickServeColors.statusRed.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ADD',
                style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Tile ───────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final WalletTxn txn;

  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type == 'CREDIT';
    final amountColor =
        isCredit ? QuickServeColors.accentGreen : QuickServeColors.statusRed;
    final amountPrefix = isCredit ? '+' : '-';

    IconData catIcon;
    Color catColor;
    switch (txn.category) {
      case 'RECHARGE':
        catIcon = Icons.add_circle_rounded;
        catColor = QuickServeColors.accentGreen;
        break;
      case 'REVERSAL':
        catIcon = Icons.replay_rounded;
        catColor = QuickServeColors.statusAmber;
        break;
      case 'BONUS':
        catIcon = Icons.star_rounded;
        catColor = const Color(0xFF8B5CF6);
        break;
      case 'COMPANY_CHARGE':
      default:
        catIcon = Icons.account_balance_rounded;
        catColor = QuickServeColors.primaryBlue;
    }

    final dateStr = _formatDate(txn.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickServeColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(catIcon, color: catColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description ?? _categoryLabel(txn.category),
                  style: const TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    if (txn.rideId != null) ...[
                      const Text(' · ',
                          style: TextStyle(
                              color: QuickServeColors.textMuted,
                              fontSize: 11)),
                      Text(
                        'Ride #${txn.rideId}',
                        style: const TextStyle(
                          color: QuickServeColors.primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Balance: ${WalletService.formatAmount(txn.balanceBefore)} → ${WalletService.formatAmount(txn.balanceAfter)}',
                  style: const TextStyle(
                    color: QuickServeColors.textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${WalletService.formatAmount(txn.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: txn.status == 'SUCCESS'
                      ? QuickServeColors.statusGreenLight
                      : QuickServeColors.statusAmberLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  txn.status,
                  style: TextStyle(
                    color: txn.status == 'SUCCESS'
                        ? QuickServeColors.statusGreen
                        : QuickServeColors.statusAmber,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'RECHARGE':
        return 'Wallet Recharge';
      case 'REVERSAL':
        return 'Charge Reversal';
      case 'BONUS':
        return 'Bonus Credit';
      case 'COMPANY_CHARGE':
      default:
        return 'Company Charge';
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Quick Amount Chip ──────────────────────────────────────────────────────
class _QuickAmountChip extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const _QuickAmountChip({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: QuickServeColors.primaryBlue.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: QuickServeColors.primaryBlue.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '₹${amount.toInt()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: QuickServeColors.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─── Stats Mini Card ────────────────────────────────────────────────────────
class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recharge Bottom Sheet ──────────────────────────────────────────────────
class _RechargeBottomSheet extends StatefulWidget {
  final Future<void> Function(double) onRecharge;
  final TextEditingController amountController;

  const _RechargeBottomSheet({
    required this.onRecharge,
    required this.amountController,
  });

  @override
  State<_RechargeBottomSheet> createState() => _RechargeBottomSheetState();
}

class _RechargeBottomSheetState extends State<_RechargeBottomSheet> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: QuickServeColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Money to Wallet',
            style: TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter the amount you want to add.',
            style: TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: widget.amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: '₹  ',
              prefixStyle: const TextStyle(
                color: QuickServeColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              hintText: '0',
              hintStyle: TextStyle(
                color: QuickServeColors.textMuted.withOpacity(0.5),
                fontSize: 18,
              ),
              filled: true,
              fillColor: QuickServeColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: QuickServeColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: QuickServeColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: QuickServeColors.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final rawText = widget.amountController.text.trim();
                      final amount = double.tryParse(rawText);
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid amount')),
                        );
                        return;
                      }
                      setState(() => _isProcessing = true);
                      await widget.onRecharge(amount);
                      if (mounted) setState(() => _isProcessing = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: QuickServeColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('ADD MONEY',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
