import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';

class ViewEarningStatementScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onDownloadTap;

  const ViewEarningStatementScreen({
    super.key,
    this.onBackTap,
    this.onDownloadTap,
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
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Earning Statement',
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
              // Statement Period Header (Phone 16)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_month, color: QuickServeColors.primaryBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'May 2026',
                          style: TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: QuickServeColors.statusGreenLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Settled',
                        style: TextStyle(
                          color: QuickServeColors.statusGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Total Earnings Card
              Container(
                padding: const EdgeInsets.all(20),
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
                  children: const [
                    Text(
                      'Total Settled Earnings',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '₹23,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '84 rides completed • 100% attendance',
                      style: TextStyle(color: Color(0xFF86EFAC), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Monthly Trend Vertical Bar Chart (Phone 16)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Earnings Trend',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildTrendBar('May', '15%', 60, false),
                        _buildTrendBar('Jun', '18%', 75, false),
                        _buildTrendBar('Jul', '20%', 90, false),
                        _buildTrendBar('Aug', '23%', 110, true), // Active
                        _buildTrendBar('Sep', '28%', 130, false),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Detailed Statement Breakdown Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildBreakdownRow('Trip Fares (84 trips)', '₹19,400'),
                    const Divider(height: 1, color: QuickServeColors.borderLight),
                    _buildBreakdownRow('Quests & Incentives', '+ ₹2,500', isGreen: true),
                    const Divider(height: 1, color: QuickServeColors.borderLight),
                    _buildBreakdownRow('Passenger Tips', '+ ₹1,100', isGreen: true),
                    const Divider(height: 1, color: QuickServeColors.borderLight),
                    _buildBreakdownRow('Platform Commission', '- ₹0', isMuted: true),
                    const Divider(height: 1, color: QuickServeColors.borderLight),
                    _buildBreakdownRow('Total Net Payout', '₹23,000', isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Download Statement Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Download Statement (PDF)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    AppToast.success(context, 'Earning Statement May 2026 downloaded to device!');
                    if (onDownloadTap != null) onDownloadTap!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickServeColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendBar(String month, String percentage, double height, bool isActive) {
    return Column(
      children: [
        Text(
          percentage,
          style: TextStyle(
            color: isActive ? QuickServeColors.primaryBlue : QuickServeColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? QuickServeColors.primaryBlue : const Color(0xFFBFDBFE),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          month,
          style: TextStyle(
            color: isActive ? QuickServeColors.textDark : QuickServeColors.textSecondary,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String title, String amount, {bool isGreen = false, bool isMuted = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isMuted ? QuickServeColors.textMuted : QuickServeColors.textDark,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isGreen
                  ? QuickServeColors.statusGreen
                  : isMuted
                      ? QuickServeColors.textMuted
                      : QuickServeColors.textDark,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
