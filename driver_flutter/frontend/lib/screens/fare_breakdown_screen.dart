import 'package:flutter/material.dart';
import '../core/theme.dart';

class FareBreakdownScreen extends StatelessWidget {
  final VoidCallback? onDone;
  final VoidCallback? onBackTap;

  const FareBreakdownScreen({
    super.key,
    this.onDone,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: onBackTap,
        ),
        title: const Text(
          'Fare Breakdown',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 17,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total Fare Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Trip Fare',
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '₹ 402',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: QuickServeColors.borderLight),
                    const SizedBox(height: 12),
                    _buildFareItem('Base Fare', '₹ 240'),
                    const SizedBox(height: 10),
                    _buildFareItem('Distance Fare (16.4 km)', '₹ 110'),
                    const SizedBox(height: 10),
                    _buildFareItem('Time Fare (32 min)', '₹ 32'),
                    const SizedBox(height: 10),
                    _buildFareItem('Toll Tax (DND Flyway)', '₹ 40'),
                    const SizedBox(height: 10),
                    _buildFareItem('Parking Charges (CP)', '₹ 20'),
                    const SizedBox(height: 12),
                    const Divider(color: QuickServeColors.borderLight),
                    const SizedBox(height: 12),
                    _buildFareItem('Gross Passenger Total', '₹ 402', isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Payment Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UPI • Google Pay',
                            style: TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Transaction ID: UPI/2026/89472190',
                            style: TextStyle(
                              color: QuickServeColors.textSecondary,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Paid',
                        style: TextStyle(
                          color: QuickServeColors.statusGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Orange CTA Done Button (Transitions to Screen 15 Earnings)
              ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Done (View Earnings)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareItem(String title, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isBold ? QuickServeColors.textDark : QuickServeColors.textSecondary,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isBold ? QuickServeColors.primaryOrange : QuickServeColors.textDark,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
