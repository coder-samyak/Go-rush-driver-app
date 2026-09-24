import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/ride_service.dart';

class TripHistoryDetailedReceiptScreen extends StatefulWidget {
  final VoidCallback? onSosTap;
  final VoidCallback? onInsuranceTap;
  final Function(int)? onBottomNavTap;
  final int initialTab;

  const TripHistoryDetailedReceiptScreen({
    super.key,
    this.onSosTap,
    this.onInsuranceTap,
    this.onBottomNavTap,
    this.initialTab = 0,
  });

  @override
  State<TripHistoryDetailedReceiptScreen> createState() =>
      _TripHistoryDetailedReceiptScreenState();
}

class _TripHistoryDetailedReceiptScreenState
    extends State<TripHistoryDetailedReceiptScreen> {
  late int _selectedTab; // 0: Completed, 1: Cancelled

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 1);
    RideService.instance.addListener(_onHistoryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RideService.instance.fetchHistory();
    });
  }

  @override
  void dispose() {
    RideService.instance.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant TripHistoryDetailedReceiptScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _selectedTab = widget.initialTab.clamp(0, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trip History',
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
            // Tabs: Completed / Cancelled
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? QuickServeColors.primaryOrange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Completed (${RideService.instance.completedHistory.isNotEmpty ? RideService.instance.completedHistory.length : 42})',
                              style: TextStyle(
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : QuickServeColors.textSecondary,
                                fontSize: 13,
                                fontWeight: _selectedTab == 0
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? QuickServeColors.primaryOrange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Cancelled (${RideService.instance.cancelledHistory.isNotEmpty ? RideService.instance.cancelledHistory.length : 2})',
                              style: TextStyle(
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : QuickServeColors.textSecondary,
                                fontSize: 13,
                                fontWeight: _selectedTab == 1
                                    ? FontWeight.bold
                                    : FontWeight.w500,
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

            // Trips List: Switches dynamically between Completed and Cancelled
            Expanded(
              child: _selectedTab == 0
                  ? _buildCompletedList()
                  : _buildCancelledList(),
            ),

            // Bottom Navigation Bar (Rides/History tab active: index 1)
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

  Widget _buildCompletedList() {
    final completed = RideService.instance.completedHistory;
    if (completed.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        physics: const BouncingScrollPhysics(),
        itemCount: completed.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) {
          final ride = completed[idx];
          return _buildTripCard(
            date: ride.completedAt != null
                ? 'Today, ${ride.completedAt!.hour.toString().padLeft(2, '0')}:${ride.completedAt!.minute.toString().padLeft(2, '0')}'
                : 'Today, Just now',
            fare: '₹ ${ride.totalFare.toStringAsFixed(0)}',
            pickup: ride.pickupAddress,
            drop: ride.destinationAddress,
            distance: '${ride.distanceKm} km',
            duration: '${ride.durationMin} min',
            passenger: ride.passengerName,
            isCompleted: true,
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildTripCard(
          date: 'Today, 09:30 AM',
          fare: '₹ 362',
          pickup: 'Sector 62, Noida',
          drop: 'Connaught Place, New Delhi',
          distance: '16.4 km',
          duration: '32 min',
          passenger: 'Priya Sharma',
          isCompleted: true,
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          date: 'Today, 07:15 AM',
          fare: '₹ 820',
          pickup: 'Sector 18, Noida',
          drop: 'Cyber City, Gurgaon',
          distance: '38.2 km',
          duration: '55 min',
          passenger: 'Rohan Verma',
          isCompleted: true,
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          date: 'Yesterday, 08:45 PM',
          fare: '₹ 410',
          pickup: 'DLF Phase 2, Gurgaon',
          drop: 'Sector 62, Noida',
          distance: '34.0 km',
          duration: '48 min',
          passenger: 'Ananya Roy',
          isCompleted: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCancelledList() {
    final cancelled = RideService.instance.cancelledHistory;
    if (cancelled.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        physics: const BouncingScrollPhysics(),
        itemCount: cancelled.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) {
          final ride = cancelled[idx];
          return _buildTripCard(
            date: ride.cancelledAt != null
                ? 'Today, ${ride.cancelledAt!.hour.toString().padLeft(2, '0')}:${ride.cancelledAt!.minute.toString().padLeft(2, '0')}'
                : 'Today, Just now',
            fare: '₹ 0',
            pickup: ride.pickupAddress,
            drop: ride.destinationAddress,
            distance: '0.0 km',
            duration: 'Cancelled by driver',
            passenger: ride.passengerName,
            isCompleted: false,
            cancelReason: ride.cancellationReason ?? 'Driver declined request',
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildTripCard(
          date: 'Today, 11:20 AM',
          fare: '₹ 0',
          pickup: 'Noida City Center Metro',
          drop: 'Sector 137, Noida',
          distance: '0.8 km',
          duration: 'Cancelled',
          passenger: 'Vikram Malhotra',
          isCompleted: false,
          cancelReason: 'Rider cancelled after 4 mins (₹50 fee credited)',
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          date: 'Yesterday, 02:15 PM',
          fare: '₹ 0',
          pickup: 'Indirapuram Habitat Center',
          drop: 'Anand Vihar ISBT',
          distance: '0.0 km',
          duration: '1 min before cancel',
          passenger: 'Swati Singh',
          isCompleted: false,
          cancelReason: 'Cancelled by driver: Flat tire / vehicle breakdown',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTripCard({
    required String date,
    required String fare,
    required String pickup,
    required String drop,
    required String distance,
    required String duration,
    required String passenger,
    required bool isCompleted,
    String? cancelReason,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? QuickServeColors.borderLight
              : const Color(0xFFFECACA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Fare Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (!isCompleted && fare != '₹ 0')
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text(
                        '(Fee)',
                        style: TextStyle(
                          color: QuickServeColors.statusGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    fare,
                    style: TextStyle(
                      color: isCompleted
                          ? QuickServeColors.textDark
                          : QuickServeColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pickup & Drop
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: QuickServeColors.statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 26,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: QuickServeColors.statusRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup,
                      style: const TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      drop,
                      style: const TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Optional Cancellation Reason Banner
          if (cancelReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: QuickServeColors.statusRed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cancelReason,
                      style: const TextStyle(
                        color: QuickServeColors.statusRed,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: QuickServeColors.borderLight),
          const SizedBox(height: 10),

          // Passenger & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$passenger • $distance • $duration',
                  style: const TextStyle(
                    color: QuickServeColors.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFE8F8EE)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Cancelled',
                  style: TextStyle(
                    color: isCompleted
                        ? QuickServeColors.statusGreen
                        : QuickServeColors.statusRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCompleted && widget.onInsuranceTap != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: widget.onInsuranceTap,
                  icon: const Icon(Icons.shield_outlined, size: 16),
                  label: const Text('Insurance Available'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF376B3A),
                    side: const BorderSide(color: Color(0xFF9BCB65)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
