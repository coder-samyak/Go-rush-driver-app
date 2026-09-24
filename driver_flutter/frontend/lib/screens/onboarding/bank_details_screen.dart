import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/token_storage_service.dart';

class BankDetailsScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBackTap;

  const BankDetailsScreen({
    super.key,
    this.onNext,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Bank Details / UPI',
          style: TextStyle(color: QuickServeColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Direct Payout Account',
                style: TextStyle(color: QuickServeColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your trip fares and daily incentives will be deposited directly to this bank account or UPI ID.',
                style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 24),

              _buildField('Bank Name', 'HDFC Bank Limited', Icons.account_balance),
              const SizedBox(height: 16),
              _buildField(
                'Account Holder Name',
                (TokenStorageService.instance.driverProfile?['name'] as String?)?.isNotEmpty == true
                    ? TokenStorageService.instance.driverProfile!['name'] as String
                    : 'Partner Driver',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildField('Account Number', '50100428914092', Icons.numbers),
              const SizedBox(height: 16),
              _buildField('IFSC Code', 'HDFC0001234', Icons.pin),
              const SizedBox(height: 16),
              _buildField(
                'Primary UPI ID',
                '${((TokenStorageService.instance.driverProfile?['name'] as String?)?.isNotEmpty == true ? (TokenStorageService.instance.driverProfile!['name'] as String).toLowerCase().replaceAll(RegExp(r'\s+'), '.') : 'partner.driver')}@okhdfcbank',
                Icons.payment,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Save & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: QuickServeColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(icon, color: QuickServeColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: QuickServeColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.check_circle, color: QuickServeColors.statusGreen, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
