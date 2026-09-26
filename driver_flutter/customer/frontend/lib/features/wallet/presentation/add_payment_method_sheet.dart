import 'package:flutter/material.dart';
import '../../../core/wallet/data/wallet_repository.dart';

class AddPaymentMethodSheet extends StatefulWidget {
  final WalletRepository walletRepository;
  final VoidCallback onAdded;

  const AddPaymentMethodSheet({
    super.key,
    required this.walletRepository,
    required this.onAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required WalletRepository walletRepository,
    required VoidCallback onAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPaymentMethodSheet(
        walletRepository: walletRepository,
        onAdded: onAdded,
      ),
    );
  }

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  String _selectedType = 'UPI'; // 'UPI' or 'CARD'
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _cardNumController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpController = TextEditingController();
  bool _isSaving = false;

  Future<void> _savePaymentMethod() async {
    String title = '';
    String subtitle = '';

    if (_selectedType == 'UPI') {
      final vpa = _upiController.text.trim();
      if (!vpa.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid UPI ID (e.g. user@okicici)')),
        );
        return;
      }
      title = 'UPI Handle';
      subtitle = vpa;
    } else {
      final cardNum = _cardNumController.text.trim();
      final cardName = _cardNameController.text.trim();
      final cardExp = _cardExpController.text.trim();

      if (cardNum.length < 12 || cardName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid card details')),
        );
        return;
      }
      final last4 = cardNum.substring(cardNum.length - 4);
      title = '$cardName Card';
      subtitle = '•••• •••• •••• $last4 (Expires $cardExp)';
    }

    setState(() => _isSaving = true);

    try {
      await widget.walletRepository.addPaymentMethod(
        type: _selectedType,
        title: title,
        subtitle: subtitle,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New payment method saved!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save payment method: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
                  'Add Payment Method',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab selection (UPI vs Card)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'UPI'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'UPI' ? const Color(0xFF00C853).withValues(alpha: 0.2) : const Color(0xFF222B24),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedType == 'UPI' ? const Color(0xFF00C853) : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(
                          'UPI ID',
                          style: TextStyle(
                            color: _selectedType == 'UPI' ? const Color(0xFF00C853) : Colors.white70,
                            fontWeight: _selectedType == 'UPI' ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'CARD'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'CARD' ? const Color(0xFF00C853).withValues(alpha: 0.2) : const Color(0xFF222B24),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedType == 'CARD' ? const Color(0xFF00C853) : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(
                          'Credit / Debit Card',
                          style: TextStyle(
                            color: _selectedType == 'CARD' ? const Color(0xFF00C853) : Colors.white70,
                            fontWeight: _selectedType == 'CARD' ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_selectedType == 'UPI') ...[
              TextField(
                controller: _upiController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'UPI VPA (e.g. mobile@upi)',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                  hintText: 'user@okicici',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF222B24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00C853)),
                  ),
                ),
              ),
            ] else ...[
              TextField(
                controller: _cardNumController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                  hintText: '4532 8910 1123 4829',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF222B24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cardNameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Bank / Card Name',
                        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                        hintText: 'HDFC Visa',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF222B24),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _cardExpController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                        hintText: '08/28',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF222B24),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Payment Method',
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
