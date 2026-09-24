import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';

class InstantCashOutScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onWithdrawSuccess;

  const InstantCashOutScreen({
    super.key,
    this.onBackTap,
    this.onWithdrawSuccess,
  });

  @override
  State<InstantCashOutScreen> createState() => _InstantCashOutScreenState();
}

class _InstantCashOutScreenState extends State<InstantCashOutScreen> {
  final TextEditingController _amountController = TextEditingController(text: '2,500');
  int _selectedChip = 2; // index of ₹2,000

  final List<String> _chips = ['₹500', '₹1,000', '₹2,000', '₹5,000'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Instant Cash Out',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Available Balance Card (Phone 15)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₹2,500',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.account_balance, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'HDFC Bank •••• 4092 (Primary)',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Amount Select Chips
              const Text(
                'Select Amount',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_chips.length, (index) {
                  final isSelected = _selectedChip == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedChip = index;
                        _amountController.text = _chips[index].replaceAll('₹', '').replaceAll(',', '');
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? QuickServeColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? QuickServeColors.primaryBlue : QuickServeColors.borderLight,
                        ),
                      ),
                      child: Text(
                        _chips[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : QuickServeColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 18),

              // Custom amount input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      color: QuickServeColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    labelText: 'Enter Custom Amount',
                    labelStyle: TextStyle(color: QuickServeColors.textSecondary, fontSize: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Withdraw CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppToast.showSuccess(
                      context,
                      'Payout of ₹${_amountController.text} initiated successfully!',
                    );
                    if (widget.onWithdrawSuccess != null) {
                      widget.onWithdrawSuccess!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickServeColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Payouts History
              const Text(
                'Recent Withdrawals',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildTransactionRow(
                      date: 'Today, 11:30 AM',
                      amount: '₹2,000',
                      status: 'Completed',
                    ),
                    const Divider(height: 1, color: QuickServeColors.borderLight),
                    _buildTransactionRow(
                      date: 'Yesterday, 06:15 PM',
                      amount: '₹1,500',
                      status: 'Completed',
                    ),
                    const Divider(height: 1, color: QuickServeColors.borderLight),
                    _buildTransactionRow(
                      date: '10 May, 09:40 PM',
                      amount: '₹3,200',
                      status: 'Completed',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow({
    required String date,
    required String amount,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_upward, color: QuickServeColors.statusGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transferred to HDFC Bank',
                  style: TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: const TextStyle(
                  color: QuickServeColors.statusGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
