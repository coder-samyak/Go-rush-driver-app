import 'package:flutter/material.dart';
import '../../../core/wallet/data/wallet_repository.dart';
import '../../../core/wallet/domain/wallet_models.dart';

class AddMoneySheet extends StatefulWidget {
  final WalletRepository walletRepository;
  final VoidCallback onBalanceUpdated;

  const AddMoneySheet({
    super.key,
    required this.walletRepository,
    required this.onBalanceUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required WalletRepository walletRepository,
    required VoidCallback onBalanceUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMoneySheet(
        walletRepository: walletRepository,
        onBalanceUpdated: onBalanceUpdated,
      ),
    );
  }

  @override
  State<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<AddMoneySheet> {
  final List<int> _quickAmounts = [100, 250, 500, 1000];
  int _selectedAmount = 500;
  final TextEditingController _customAmountController = TextEditingController(text: '500');

  List<PaymentMethodModel> _paymentMethods = [];
  String? _selectedPaymentMethodId;
  bool _isLoadingMethods = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await widget.walletRepository.getPaymentMethods();
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
          if (methods.isNotEmpty) {
            _selectedPaymentMethodId = methods.firstWhere((p) => p.isDefault, orElse: () => methods.first).id;
          }
          _isLoadingMethods = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMethods = false);
    }
  }

  Future<void> _addMoney() async {
    final amountText = _customAmountController.text.trim();
    final amountRupees = int.tryParse(amountText) ?? _selectedAmount;

    if (amountRupees <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      final amountMinor = amountRupees * 100;
      await widget.walletRepository.addMoney(
        amountMinor,
        paymentMethodId: _selectedPaymentMethodId,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onBalanceUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added ₹$amountRupees to your GoRush Wallet!'),
            backgroundColor: const Color(0xFF00C853),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add money: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF161C18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Money to Wallet',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Amount Selector Chips
            const Text(
              'Select Amount',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: _quickAmounts.map((amt) {
                final isSelected = _selectedAmount == amt;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAmount = amt;
                          _customAmountController.text = '$amt';
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00C853).withValues(alpha: 0.2)
                              : const Color(0xFF222B24),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00C853) : Colors.white10,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '₹$amt',
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF00C853) : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom Amount Input
            TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null) {
                  setState(() => _selectedAmount = parsed);
                }
              },
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: Color(0xFF00C853), fontSize: 18, fontWeight: FontWeight.bold),
                labelText: 'Enter Amount (₹)',
                labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF222B24),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF00C853)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Source Selection
            const Text(
              'Payment Source',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            if (_isLoadingMethods)
              const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
            else if (_paymentMethods.isEmpty)
              const Text('No saved payment methods', style: TextStyle(color: Colors.white54, fontSize: 13))
            else
              Column(
                children: _paymentMethods.map((pm) {
                  final isSelected = _selectedPaymentMethodId == pm.id;
                  return InkWell(
                    onTap: () => setState(() => _selectedPaymentMethodId = pm.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00C853).withValues(alpha: 0.15) : const Color(0xFF222B24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00C853) : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            pm.type == 'CARD' ? Icons.credit_card : Icons.account_balance_wallet_rounded,
                            color: isSelected ? const Color(0xFF00C853) : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pm.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  pm.subtitle,
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // Submit Add Money Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isAdding ? null : _addMoney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isAdding
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Proceed to Pay',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
