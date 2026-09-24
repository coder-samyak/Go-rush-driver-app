import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../widgets/live_ride_map.dart';
import '../widgets/safe_avatar.dart';
import '../core/app_toast.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';

class ActiveTripNavigationScreen extends StatefulWidget {
  final VoidCallback? onEndTrip;
  final VoidCallback? onBackTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onSosTap;
  final VoidCallback? onCallTap;

  const ActiveTripNavigationScreen({
    super.key,
    this.onEndTrip,
    this.onBackTap,
    this.onChatTap,
    this.onSosTap,
    this.onCallTap,
  });

  @override
  State<ActiveTripNavigationScreen> createState() =>
      _ActiveTripNavigationScreenState();
}

class _ActiveTripNavigationScreenState
    extends State<ActiveTripNavigationScreen> {
  Future<void> _launchGoogleMapsNavigation(RideModel ride) async {
    final dest = Uri.encodeComponent(ride.destinationAddress.isNotEmpty
        ? ride.destinationAddress
        : '${ride.destinationLat},${ride.destinationLng}');
    final nativeUri = Uri.parse('google.navigation:q=$dest&mode=d');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$dest&travelmode=driving');

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) AppToast.show(context, 'Opening navigation...');
      }
    } catch (_) {
      if (mounted) AppToast.show(context, 'Opening navigation...');
    }
  }

  Future<void> _callPassenger(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) AppToast.show(context, 'Calling $phone...');
      }
    } catch (_) {
      if (mounted) AppToast.show(context, 'Calling $phone...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = RideService.instance.activeRide ?? RideModel.defaultSample();

    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      body: Stack(
        children: [
          // Full Screen Light Navigation Map
          Positioned.fill(
            child: LiveRideMap(ride: ride),
          ),

          // Top Header: < On Trip with Turn banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Back button & Title Bar
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: QuickServeColors.textDark),
                            onPressed: widget.onBackTap ??
                                () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'On Trip',
                            style: TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Navigation instruction banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: QuickServeColors.textDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: QuickServeColors.primaryBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.turn_right,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'In 200m Turn Right',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Sector 62 Main Ring Road • Toward CP',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.navigation_rounded,
                                color: Colors.white, size: 22),
                            tooltip: 'Navigate in Google Maps',
                            onPressed: () => _launchGoogleMapsNavigation(ride),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '45 km/h',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SOS Floating Button — bottom-right corner above passenger card
          Positioned(
            right: 16,
            bottom: 220,
            child: _buildSosButton(),
          ),

          // Bottom Floating Navigation & Passenger Card (Phone 13)
          Positioned(
            left: 14,
            right: 14,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              minimum: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Passenger Row: Riya Sharma (4.9 ★) with Call & Chat Buttons
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: QuickServeColors.borderLight,
                                width: 1.5),
                          ),
                          child: SafeAvatar(
                            imageUrl: ride.passengerAvatar,
                            radius: 22,
                            fallbackText: ride.passengerName.isNotEmpty
                                ? ride.passengerName.substring(0, 1)
                                : 'RS',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ride.passengerName,
                                    style: const TextStyle(
                                      color: QuickServeColors.textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star,
                                      color: Color(0xFFFBBF24), size: 14),
                                  Text(
                                    ' ${ride.passengerRating.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: QuickServeColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ride.vehicleTier} • KA 01 AB 1234',
                                style: const TextStyle(
                                  color: QuickServeColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Call Button
                        IconButton(
                          onPressed: widget.onCallTap ??
                              () => _callPassenger(
                                  ride.passengerPhone.isNotEmpty
                                      ? ride.passengerPhone
                                      : '+919876543210'),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Icon(Icons.phone,
                                color: QuickServeColors.primaryBlue, size: 18),
                          ),
                        ),
                        // Chat Button
                        IconButton(
                          onPressed: widget.onChatTap,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: QuickServeColors.borderLight),
                            ),
                            child: const Icon(Icons.chat_bubble_outline,
                                color: QuickServeColors.primaryBlue, size: 18),
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                        height: 16, color: QuickServeColors.borderLight),

                    // Destination Info
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: QuickServeColors.statusRed, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride.destinationAddress,
                            style: const TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Royal Cobalt Blue End Trip Button (Phone 13)
                    ElevatedButton(
                      onPressed: () async {
                        final ok = await RideService.instance.completeTrip(
                            ride.rideId.isNotEmpty ? ride.rideId : ride.id);
                        if (context.mounted) {
                          if (ok) {
                            AppToast.success(
                                context, 'Trip completed successfully!');
                            widget.onEndTrip?.call();
                          } else {
                            AppToast.error(context,
                                'Failed to complete trip. Please retry.');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuickServeColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'End Trip',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return GestureDetector(
      onTap: () async {
        // Always show the SOS sheet WITHIN the map screen.
        // Do NOT call widget.onSosTap — that navigates away from the trip.
        await _showSosSheet();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sos_rounded, color: Colors.white, size: 26),
                SizedBox(height: 2),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSosSheet() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFFEE2E2),
              child: Icon(Icons.warning_rounded,
                  color: Color(0xFFEF4444), size: 34),
            ),
            const SizedBox(height: 12),
            const Text('Emergency SOS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Your live GPS location will be shared with GoRush Safety Desk.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(sheetCtx, 'sos'),
                icon: const Icon(Icons.sos_rounded),
                label: const Text('Send Live SOS Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(sheetCtx, 'call'),
                icon: const Icon(Icons.phone),
                label: const Text('Call Police 112'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'call') {
      await launchUrl(Uri.parse('tel:112'),
          mode: LaunchMode.externalApplication);
      return;
    }
    final sent = await RideService.instance.triggerSos();
    if (!mounted) return;
    sent
        ? AppToast.error(context, 'SOS sent with your live GPS location!')
        : AppToast.error(context,
            'Enable Location Services and ensure backend is running.');
  }
}
