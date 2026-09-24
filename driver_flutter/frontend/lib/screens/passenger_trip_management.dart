import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_toast.dart';
import '../core/theme.dart';
import '../widgets/safe_avatar.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';

class PassengerTripManagementScreen extends StatefulWidget {
  final VoidCallback? onStartTrip;
  final VoidCallback? onCancelTrip;
  final VoidCallback? onBackTap;
  final VoidCallback? onChatTap;

  const PassengerTripManagementScreen({
    super.key,
    this.onStartTrip,
    this.onCancelTrip,
    this.onBackTap,
    this.onChatTap,
  });

  @override
  State<PassengerTripManagementScreen> createState() =>
      _PassengerTripManagementScreenState();
}

class _PassengerTripManagementScreenState
    extends State<PassengerTripManagementScreen> {
  late final TextEditingController _otpController;

  Future<void> _navigateToPickup(RideModel ride) async {
    final destination = '${ride.pickupLat},${ride.pickupLng}';
    final nativeUri = Uri.parse('google.navigation:q=$destination&mode=d');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving');
    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context,
            'Google Maps could not be opened. Please install or update Maps.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final ride = RideService.instance.activeRide ?? RideModel.defaultSample();
    _otpController = TextEditingController(text: ride.otp);
    final id = ride.rideId.isNotEmpty ? ride.rideId : ride.id;
    if (id.isNotEmpty) {
      RideService.instance.markArrived(id);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride = RideService.instance.activeRide ?? RideModel.defaultSample();

    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap,
        ),
        title: const Text(
          'Trip in Progress',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Passenger Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: QuickServeColors.borderLight, width: 1.5),
                      ),
                      child: SafeAvatar(
                        imageUrl: ride.passengerAvatar,
                        radius: 23,
                        fallbackText: ride.passengerName.isNotEmpty
                            ? ride.passengerName.substring(0, 1)
                            : 'PS',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.passengerName,
                            style: const TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFFFBBF24), size: 14),
                              const SizedBox(width: 3),
                              Text(
                                '${ride.passengerRating.toStringAsFixed(1)} (${ride.passengerTotalRides} rides)',
                                style: const TextStyle(
                                  color: QuickServeColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Call Button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: QuickServeColors.borderLight),
                        ),
                        child: const Icon(Icons.phone,
                            color: QuickServeColors.textDark, size: 18),
                      ),
                      onPressed: () {
                        AppToast.info(
                            context, 'Calling passenger Priya Sharma...');
                      },
                    ),
                    // Chat Button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: QuickServeColors.borderLight),
                        ),
                        child: const Icon(Icons.chat_bubble_outline,
                            color: QuickServeColors.primaryOrange, size: 18),
                      ),
                      onPressed: widget.onChatTap,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Route Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: QuickServeColors.statusGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 38,
                              color: const Color(0xFFCBD5E1),
                            ),
                            Container(
                              width: 10,
                              height: 10,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Pickup Location',
                                    style: TextStyle(
                                      color: QuickServeColors.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F8EE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Arrived',
                                      style: TextStyle(
                                        color: QuickServeColors.statusGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                ride.pickupAddress,
                                style: const TextStyle(
                                  color: QuickServeColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Drop Destination',
                                style: TextStyle(
                                  color: QuickServeColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ride.destinationAddress,
                                style: const TextStyle(
                                  color: QuickServeColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _navigateToPickup(ride),
                                  icon: const Icon(Icons.navigation_rounded),
                                  label: const Text('Navigate to Pickup'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        QuickServeColors.primaryBlue,
                                    side: const BorderSide(
                                        color: QuickServeColors.primaryBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // OTP Verification Card
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
                      'Ask Passenger for Start OTP',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Verify the 4-digit code provided by passenger to begin the trip.',
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _otpController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                              color: QuickServeColors.textDark,
                            ),
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              fillColor: const Color(0xFFF8FAFC),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: QuickServeColors.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: QuickServeColors.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: QuickServeColors.primaryOrange),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8EE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified,
                              color: QuickServeColors.statusGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Large Orange Start Trip CTA
              ElevatedButton(
                onPressed: () async {
                  final enteredOtp = _otpController.text.trim();
                  if (enteredOtp.isEmpty || enteredOtp.length < 4) {
                    AppToast.error(context,
                        'Please enter the 4-digit OTP provided by passenger');
                    return;
                  }
                  final ok = await RideService.instance.startTrip(
                      ride.rideId.isNotEmpty ? ride.rideId : ride.id,
                      enteredOtp);
                  if (context.mounted) {
                    if (ok) {
                      AppToast.success(context, 'OTP Verified! Trip started');
                      widget.onStartTrip?.call();
                    } else {
                      AppToast.error(
                          context, 'Invalid OTP. Please check with passenger.');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Start Trip',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              // Outlined Cancel Trip Button
              OutlinedButton(
                onPressed: () async {
                  AppToast.info(context, 'Cancelling trip...');
                  await RideService.instance.rejectRide(
                      ride.rideId.isNotEmpty ? ride.rideId : ride.id,
                      reason: 'Driver cancelled at pickup');
                  if (context.mounted) {
                    AppToast.info(context, 'Trip cancelled.');
                    widget.onCancelTrip?.call();
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: QuickServeColors.borderLight),
                  foregroundColor: QuickServeColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Cancel Trip',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
