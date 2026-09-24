import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';

class TripCompletionScreen extends StatefulWidget {
  final VoidCallback? onViewDetails;
  final VoidCallback? onDoneTap;
  final VoidCallback? onBackTap;

  const TripCompletionScreen({
    super.key,
    this.onViewDetails,
    this.onDoneTap,
    this.onBackTap,
  });

  @override
  State<TripCompletionScreen> createState() => _TripCompletionScreenState();
}

class _TripCompletionScreenState extends State<TripCompletionScreen> {
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    final ride = RideService.instance.lastCompletedRide ?? RideModel.defaultSample();

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
          'Trip Completed',
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
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Green circular checkmark badge (Phone 14)
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: QuickServeColors.statusGreen,
                  size: 52,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Ride Completed',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Trip Completed Successfully! Trip fare details',
                style: TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 22),

              // Fare Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Fare',
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${ride.totalFare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: QuickServeColors.statusGreenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${ride.paymentMethod} Received',
                        style: const TextStyle(
                          color: QuickServeColors.statusGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: QuickServeColors.borderLight),
                    const SizedBox(height: 10),
                    _buildFareRow('Base Fare', '₹${ride.baseFare.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _buildFareRow('Distance Fare (${ride.distanceKm} km)', '₹${ride.distanceFare.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _buildFareRow('Taxes & Fees', '₹${ride.taxes.toStringAsFixed(0)}'),
                    const SizedBox(height: 12),
                    // Net earnings badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Driver Earning',
                            style: TextStyle(
                              color: QuickServeColors.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${ride.driverEarnings.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: QuickServeColors.primaryBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Rate passenger
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Column(
                  children: [
                    Text(
                      'Rate Passenger: ${ride.passengerName}',
                      style: const TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= _selectedRating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFBBF24),
                            size: 32,
                          ),
                          onPressed: () => setState(() => _selectedRating = star),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // View Receipt / View Fare Breakdown (Outlined Button)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onViewDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: QuickServeColors.primaryBlue,
                    side: const BorderSide(color: QuickServeColors.primaryBlue, width: 1.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'View Receipt',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Done CTA Button (Royal Cobalt Blue)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onDoneTap ?? widget.onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickServeColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildFareRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: QuickServeColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
