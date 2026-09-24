import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';
import '../widgets/app_bottom_nav.dart';

class RidesScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onAcceptRideTap;
  final VoidCallback? onNavigateTripTap;
  final VoidCallback? onViewReceiptTap;
  final Function(int)? onBottomNavTap;

  const RidesScreen({
    super.key,
    this.onBackTap,
    this.onAcceptRideTap,
    this.onNavigateTripTap,
    this.onViewReceiptTap,
    this.onBottomNavTap,
  });

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  int _selectedTab = 0; // 0: Ongoing, 1: History

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
          'My Rides',
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
            // Segment Control: [ Ongoing ] | [ History ]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                              'Ongoing',
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
                              'History',
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

            // Rides Cards List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    // Card 1: Ride Request • ₹120 (Accept / Decline)
                    _buildRideCard(
                      title: 'Ride Request',
                      amount: '₹120',
                      distanceTime: '2.5 km • 8 min',
                      pickup: 'H-Block, Sector 63, Noida',
                      dropoff: 'DLF Mall of India, Sector 18',
                      badgeColor: QuickServeColors.primaryBlue,
                      badgeText: 'New Request',
                      actions: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                AppToast.info(context, 'Ride declined');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: QuickServeColors.statusRed,
                                side: const BorderSide(color: QuickServeColors.statusRed),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.onAcceptRideTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: QuickServeColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 0,
                              ),
                              child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 2: Passenger Picked • ₹180 (View)
                    _buildRideCard(
                      title: 'Passenger Picked',
                      amount: '₹180',
                      distanceTime: '3.2 km • 12 min',
                      pickup: 'Botanical Garden Metro',
                      dropoff: 'Connaught Place, New Delhi',
                      badgeColor: QuickServeColors.statusAmber,
                      badgeText: 'Picked Up',
                      actions: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onNavigateTripTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuickServeColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 3: Trip in Progress • ₹240 (Navigate)
                    _buildRideCard(
                      title: 'Trip in Progress',
                      amount: '₹240',
                      distanceTime: '5.8 km • 15 min',
                      pickup: 'Sector 62 Metro Station',
                      dropoff: 'Cyber City, Gurugram',
                      badgeColor: QuickServeColors.statusGreen,
                      badgeText: 'On Trip',
                      actions: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.navigation_rounded, size: 16),
                          label: const Text('Navigate', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: widget.onNavigateTripTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuickServeColors.statusGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 4: Trip Completed • ₹320 (View Receipt)
                    _buildRideCard(
                      title: 'Trip Completed',
                      amount: '₹320',
                      distanceTime: '8.4 km • 24 min',
                      pickup: 'Indirapuram Habitat Centre',
                      dropoff: 'Terminal 3, IGI Airport',
                      badgeColor: const Color(0xFF64748B),
                      badgeText: 'Completed',
                      actions: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onViewReceiptTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: QuickServeColors.primaryBlue,
                            side: const BorderSide(color: QuickServeColors.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('View Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation (Rides tab active: index 1)
            AppBottomNav(
              currentIndex: 1,
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

  Widget _buildRideCard({
    required String title,
    required String amount,
    required String distanceTime,
    required String pickup,
    required String dropoff,
    required Color badgeColor,
    required String badgeText,
    required Widget actions,
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
                amount,
                style: const TextStyle(
                  color: QuickServeColors.statusGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            distanceTime,
            style: const TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 16, color: QuickServeColors.borderLight),
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
                  dropoff,
                  style: const TextStyle(color: QuickServeColors.textDark, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          actions,
        ],
      ),
    );
  }
}
