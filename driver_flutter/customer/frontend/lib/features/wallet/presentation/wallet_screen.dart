import 'package:flutter/material.dart';
import '../../../core/wallet/data/wallet_repository.dart';
import '../../../core/wallet/domain/wallet_models.dart';
import 'add_money_sheet.dart';
import 'add_payment_method_sheet.dart';

class WalletScreen extends StatefulWidget {
  final WalletRepository walletRepository;

  const WalletScreen({
    super.key,
    required this.walletRepository,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  WalletSummary? _summary;
  List<WalletTransaction> _transactions = [];
  List<RefundStatusModel> _refunds = [];
  List<PaymentMethodModel> _paymentMethods = [];
  List<PromoCredit> _promos = [];

  bool _isLoading = true;
  final TextEditingController _promoInputController = TextEditingController();
  bool _isRedeemingPromo = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllWalletData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promoInputController.dispose();
    super.dispose();
  }

  Future<void> _loadAllWalletData() async {
    setState(() => _isLoading = true);

    try {
      final summaryRes = await widget.walletRepository.getSummary();
      final txsRes = await widget.walletRepository.getTransactions();
      final refundsRes = await widget.walletRepository.getRefunds();
      final pmsRes = await widget.walletRepository.getPaymentMethods();
      final promosRes = await widget.walletRepository.getPromoCredits();

      if (mounted) {
        setState(() {
          _summary = summaryRes;
          _transactions = txsRes;
          _refunds = refundsRes;
          _paymentMethods = pmsRes;
          _promos = promosRes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _redeemPromoCode() async {
    final code = _promoInputController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid promo code')),
      );
      return;
    }

    setState(() => _isRedeemingPromo = true);

    try {
      final res = await widget.walletRepository.redeemPromo(code);
      if (mounted) {
        _promoInputController.clear();
        await _loadAllWalletData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Promo Code $code redeemed successfully! Added ₹${((res['addedCreditMinor'] ?? 5000) / 100).toInt()} credit.'),
              backgroundColor: const Color(0xFF00C853),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promo redemption failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isRedeemingPromo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1410),
      appBar: AppBar(
        title: const Text('GoRush Wallet & Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF161C18),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
              : RefreshIndicator(
                  color: const Color(0xFF00C853),
                  onRefresh: _loadAllWalletData,
                  child: Column(
                    children: [
                      // Balance Header Banner Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF009624)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C853).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Available Balance',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _summary?.formattedTotalAvailable ?? '₹0.00',
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('GoRush Wallet', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _summary?.formattedWalletBalance ?? '₹0.00',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(width: 1, height: 26, color: Colors.white24),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Promo Credits', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(
                                            _summary?.formattedPromoBalance ?? '₹0.00',
                                            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      AddMoneySheet.show(
                                        context,
                                        walletRepository: widget.walletRepository,
                                        onBalanceUpdated: _loadAllWalletData,
                                      );
                                    },
                                    icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF00C853), size: 18),
                                    label: const Text('Add Money', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Tabs Selector
                      Container(
                        color: const Color(0xFF161C18),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: const Color(0xFF00C853),
                          labelColor: const Color(0xFF00C853),
                          unselectedLabelColor: Colors.white60,
                          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'History'),
                            Tab(text: 'Refunds'),
                            Tab(text: 'Methods'),
                            Tab(text: 'Promos'),
                          ],
                        ),
                      ),

                      // Tab Views
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTransactionsTab(),
                            _buildRefundsTab(),
                            _buildPaymentMethodsTab(),
                            _buildPromosTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // 1. Transactions Tab
  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.white54)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final isDebit = tx.isDebit;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161C18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDebit ? Colors.redAccent.withValues(alpha: 0.15) : const Color(0xFF00C853).withValues(alpha: 0.15),
                child: Icon(
                  isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isDebit ? Colors.redAccent : const Color(0xFF00C853),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(tx.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isDebit ? '-' : '+'}${tx.formattedAmount}',
                    style: TextStyle(
                      color: isDebit ? Colors.redAccent : const Color(0xFF00C853),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.status,
                    style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Refunds Tracker Tab
  Widget _buildRefundsTab() {
    if (_refunds.isEmpty) {
      return const Center(child: Text('No active or recent refunds', style: TextStyle(color: Colors.white54)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _refunds.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = _refunds[index];
        final isProcessed = r.status == 'PROCESSED';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161C18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Refund #${r.refundId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(r.formattedAmount, style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 4),
              Text(r.reason, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              if (r.bankReferenceNumber != null) ...[
                const SizedBox(height: 4),
                Text('Bank Ref: ${r.bankReferenceNumber}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
              const SizedBox(height: 14),

              // Progress Bar / Timeline Indicator
              Row(
                children: [
                  _buildRefundStep('Initiated', true),
                  _buildRefundStepDivider(r.status != 'PENDING'),
                  _buildRefundStep('In Bank', r.status == 'IN_BANK' || isProcessed),
                  _buildRefundStepDivider(isProcessed),
                  _buildRefundStep('Completed', isProcessed),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefundStep(String label, bool active) {
    return Column(
      children: [
        Icon(
          active ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: active ? const Color(0xFF00C853) : Colors.white24,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildRefundStepDivider(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: active ? const Color(0xFF00C853) : Colors.white10,
      ),
    );
  }

  // 3. Saved Payment Methods Tab
  Widget _buildPaymentMethodsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._paymentMethods.map((pm) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161C18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: pm.isDefault ? const Color(0xFF00C853) : Colors.white10),
              ),
              child: Row(
                children: [
                  Icon(
                    pm.type == 'CARD' ? Icons.credit_card_rounded : Icons.account_balance_wallet_rounded,
                    color: pm.isDefault ? const Color(0xFF00C853) : Colors.white60,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(pm.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            if (pm.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF00C853).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                child: const Text('DEFAULT', style: TextStyle(color: Color(0xFF00C853), fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(pm.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white60),
                    color: const Color(0xFF222B24),
                    onSelected: (val) async {
                      if (val == 'default') {
                        await widget.walletRepository.setDefaultPaymentMethod(pm.id);
                        _loadAllWalletData();
                      } else if (val == 'delete') {
                        await widget.walletRepository.deletePaymentMethod(pm.id);
                        _loadAllWalletData();
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (!pm.isDefault)
                        const PopupMenuItem(value: 'default', child: Text('Set as Default', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'delete', child: Text('Remove', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                AddPaymentMethodSheet.show(
                  context,
                  walletRepository: widget.walletRepository,
                  onAdded: _loadAllWalletData,
                );
              },
              icon: const Icon(Icons.add_rounded, color: Color(0xFF00C853)),
              label: const Text('Add New Payment Method', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00C853)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Promo Credits Tab
  Widget _buildPromosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Redeem Coupon Code Input Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161C18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Redeem Promo Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Have a coupon code? Enter it below for instant credits.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoInputController,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Try WELCOME100 or GORUSH50',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF222B24),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isRedeemingPromo ? null : _redeemPromoCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isRedeemingPromo
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Available Promo Offers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),

          ..._promos.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161C18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.local_offer_rounded, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(p.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Code: ${p.code}', style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
