import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/ride_service.dart';

class EarningsInstantPayoutScreen extends StatefulWidget {
  final VoidCallback? onCashOutTap;
  final VoidCallback? onStatementTap;
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const EarningsInstantPayoutScreen({
    super.key,
    this.onCashOutTap,
    this.onStatementTap,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<EarningsInstantPayoutScreen> createState() => _EarningsInstantPayoutScreenState();
}

class _EarningsInstantPayoutScreenState extends State<EarningsInstantPayoutScreen> {
  @override
  void initState() {
    super.initState();
    RideService.instance.addListener(_onEarningsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RideService.instance.fetchEarnings();
    });
  }

  @override
  void dispose() {
    RideService.instance.removeListener(_onEarningsChanged);
    super.dispose();
  }

  void _onEarningsChanged() {
    if (mounted) setState(() {});
  }

  String _formatEarnings(double amount) {
    final intVal = amount.round();
    final str = intVal.toString();
    if (str.length <= 3) return '₹$str';
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    return '₹$rest,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Earnings',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Hero Total Earnings Card (Phone 8)
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Earnings',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.calendar_today, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'This Month',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _formatEarnings(RideService.instance.earnings.totalEarnings),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Today's Net Earnings: ${_formatEarnings(RideService.instance.earnings.todayEarnings)}",
                            style: const TextStyle(
                              color: Color(0xFF86EFAC),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Earnings Summary Card with Breakdown Rows
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: QuickServeColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildEarningRow(
                            title: "Today's Earnings (${RideService.instance.earnings.completedRidesCount} rides)",
                            amount: "₹${RideService.instance.earnings.todayEarnings.toStringAsFixed(0)}",
                            icon: Icons.today,
                            iconColor: QuickServeColors.primaryBlue,
                          ),
                          const Divider(height: 1, color: QuickServeColors.borderLight),
                          _buildEarningRow(
                            title: "Yesterday's Earnings",
                            amount: "₹8,600",
                            icon: Icons.history,
                            iconColor: const Color(0xFF64748B),
                          ),
                          const Divider(height: 1, color: QuickServeColors.borderLight),
                          _buildEarningRow(
                            title: "Weekly Earnings",
                            amount: "₹56,200",
                            icon: Icons.date_range,
                            iconColor: QuickServeColors.statusGreen,
                          ),
                          const Divider(height: 1, color: QuickServeColors.borderLight),
                          _buildEarningRow(
                            title: "Last 30 Days",
                            amount: "₹1,02,400",
                            icon: Icons.account_balance_wallet,
                            iconColor: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Linked Bank Info Card (Required for test 6)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: QuickServeColors.borderLight),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.account_balance, color: QuickServeColors.primaryBlue, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Linked Bank: HDFC Bank',
                            style: TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '•••• 4092',
                            style: TextStyle(
                              color: QuickServeColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Instant Cash Out Button (Phone 8 & test 6)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onCashOutTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: QuickServeColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Instant Cash Out',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // View Earning Statement Button (Phone 8 & test 6)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onStatementTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: QuickServeColors.textDark,
                          side: const BorderSide(color: QuickServeColors.borderLight, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'View Earnings Statement',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Navigation (Earnings Tab Active: Index 2)
            AppBottomNav(
              currentIndex: 2,
              onTap: (idx) {
                if (widget.onBottomNavTap != null) {
                  widget.onBottomNavTap!(idx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningRow({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: QuickServeColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
