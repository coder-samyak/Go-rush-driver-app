import 'package:flutter/material.dart';
import '../core/app_toast.dart';
import '../core/theme.dart';

class ScheduledRidesAdvanceBookingsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const ScheduledRidesAdvanceBookingsScreen({
    super.key,
    this.onBackTap,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<ScheduledRidesAdvanceBookingsScreen> createState() => _ScheduledRidesAdvanceBookingsScreenState();
}

class _ScheduledRidesAdvanceBookingsScreenState extends State<ScheduledRidesAdvanceBookingsScreen> {
  int _selectedTab = 0; // 0: Upcoming, 1: Past

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
          'Scheduled Rides',
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
            // Filter Segment Tabs: [ Upcoming ] | [ Past ] (Phone 11)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? QuickServeColors.statusGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Upcoming',
                              style: TextStyle(
                                color: _selectedTab == 0 ? Colors.white : QuickServeColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? QuickServeColors.statusGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Past',
                              style: TextStyle(
                                color: _selectedTab == 1 ? Colors.white : QuickServeColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Rides List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildScheduledCard(
                    title: 'Airport Ride',
                    dateTime: '12 May, 06:30 AM',
                    fare: '₹450',
                    pickup: 'Sector 62, Noida',
                    drop: 'Terminal 3, IGI Airport, New Delhi',
                    passenger: 'Aarav Mehta',
                    badgeText: 'Confirmed',
                    badgeColor: QuickServeColors.primaryBlue,
                  ),
                  const SizedBox(height: 12),
                  _buildScheduledCard(
                    title: 'Office Ride',
                    dateTime: '12 May, 09:15 AM',
                    fare: '₹220',
                    pickup: 'Shipra Mall, Indirapuram',
                    drop: 'Cyber City, Gurugram',
                    passenger: 'Meera Deshmukh',
                    badgeText: 'Confirmed',
                    badgeColor: QuickServeColors.statusGreen,
                  ),
                  const SizedBox(height: 12),
                  _buildScheduledCard(
                    title: 'Hotel Ride',
                    dateTime: '12 May, 02:00 PM',
                    fare: '₹380',
                    pickup: 'Connaught Place, Central Delhi',
                    drop: 'Taj Palace, Chanakyapuri, New Delhi',
                    passenger: 'Vikram Sethi',
                    badgeText: 'Advance Booking',
                    badgeColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom CTA: Browse Open Advance Bids
            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppToast.show(context, 'Scanning available advance ride bookings...');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickServeColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Browse Scheduled Bids',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledCard({
    required String title,
    required String dateTime,
    required String fare,
    required String pickup,
    required String drop,
    required String passenger,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: QuickServeColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                fare,
                style: const TextStyle(
                  color: QuickServeColors.statusGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule, color: QuickServeColors.textSecondary, size: 14),
              const SizedBox(width: 6),
              Text(
                dateTime,
                style: const TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.person, color: QuickServeColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(
                passenger,
                style: const TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: QuickServeColors.borderLight),
          Row(
            children: [
              const Icon(Icons.circle, color: QuickServeColors.statusGreen, size: 10),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pickup,
                  style: const TextStyle(color: QuickServeColors.textDark, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: QuickServeColors.statusRed, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  drop,
                  style: const TextStyle(color: QuickServeColors.textDark, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
