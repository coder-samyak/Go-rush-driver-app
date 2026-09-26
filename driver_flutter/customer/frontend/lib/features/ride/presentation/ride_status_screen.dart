import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/ride/domain/ride_models.dart';
import '../../../core/ride/data/ride_repository.dart';
import '../../../core/realtime/application/realtime_service.dart';
import '../../../core/realtime/domain/driver_location.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/tokens.dart';
import '../../safety/presentation/sos_emergency_sheet.dart';
import 'in_app_chat_sheet.dart';
import 'post_ride_screen.dart';
import '../../../core/security/token_manager.dart';
import '../../../core/security/secure_storage.dart';
import '../../../shared/map/maps_provider.dart';
import '../../../core/location/domain/location_models.dart';

class RideStatusScreen extends StatefulWidget {
  final Ride initialRide;
  final RideRepository repository;
  final RealtimeService realtimeService;

  const RideStatusScreen({
    super.key,
    required this.initialRide,
    required this.repository,
    required this.realtimeService,
  });

  @override
  State<RideStatusScreen> createState() => _RideStatusScreenState();
}

class _RideStatusScreenState extends State<RideStatusScreen> {
  late Ride _ride;
  bool _isCancelling = false;
  Timer? _mockDispatchTimer;
  StreamSubscription<DriverLocation>? _locationSub;
  DriverLocation? _latestLocation;
  int _etaMinutes = 4;

  StreamSubscription<Map<String, dynamic>>? _statusSub;
  final OpenStreetMapProviderImpl _mapsProvider = OpenStreetMapProviderImpl();

  @override
  void initState() {
    super.initState();
    _ride = widget.initialRide;
    _startLiveTracking();
  }

  void _startLiveTracking() {
    TokenManager(SecureStorageImpl()).getAccessToken().then((token) {
      widget.realtimeService.connect(token ?? 'mock_token');
      widget.realtimeService.subscribeToRide(_ride.rideId);
    });

    _locationSub = widget.realtimeService.driverLocationStream.listen((location) {
      if (mounted) {
        setState(() {
          _latestLocation = location;
          if (_etaMinutes > 1 && location.sequenceNumber % 3 == 0) {
            _etaMinutes--;
          }
          final coord = GeoCoordinate(latitude: location.latitude, longitude: location.longitude);
          _mapsProvider.setMarkers([coord]);
          _mapsProvider.animateCamera(coord, zoom: 16);
        });
      }
    });

    _statusSub = widget.realtimeService.rideStatusStream.listen((data) {
      if (mounted) {
        setState(() {
          // Update ride from backend event data.
          // Note: The payload contains the full ride object, or at least the status.
          // We assume the payload maps exactly to the Ride.fromJson structure
          try {
            _ride = Ride.fromJson(data);
          } catch (e) {
            if (kDebugMode) {
              print('Failed to parse ride update: $e');
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _locationSub?.cancel();
    widget.realtimeService.unsubscribeFromRide(_ride.rideId);
    widget.realtimeService.disconnect();
    _mapsProvider.dispose();
    super.dispose();
  }

  Future<void> _cancelRide() async {
    setState(() => _isCancelling = true);
    try {
      final updatedRide = await widget.repository.cancelRide(
        rideId: _ride.rideId,
        reason: 'CUSTOMER_CHANGED_MIND',
      );
      setState(() {
        _ride = updatedRide;
      });
      _locationSub?.cancel();
      widget.realtimeService.unsubscribeFromRide(_ride.rideId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.requested:
        return 'Booking your ride...';
      case RideStatus.searching:
        return 'Finding best driver near you...';
      case RideStatus.driverAssigned:
        return 'Driver assigned & on the way';
      case RideStatus.driverEnRoute:
        return 'Driver is arriving soon';
      case RideStatus.driverArrived:
        return 'Driver has arrived at pickup!';
      case RideStatus.rideStarted:
      case RideStatus.rideInProgress:
        return 'On trip to destination';
      case RideStatus.rideCompleted:
        return 'Ride completed!';
      case RideStatus.cancelled:
        return 'Ride cancelled';
      case RideStatus.noDriver:
        return 'No driver available';
      default:
        return 'Updating ride status...';
    }
  }

  int _getStepIndex(RideStatus status) {
    switch (status) {
      case RideStatus.requested:
        return 1;
      case RideStatus.searching:
        return 2;
      case RideStatus.driverAssigned:
      case RideStatus.driverEnRoute:
        return 3;
      case RideStatus.driverArrived:
      case RideStatus.rideStarted:
      case RideStatus.rideInProgress:
        return 4;
      case RideStatus.rideCompleted:
        return 5;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _getStepIndex(_ride.status);

    return Scaffold(
      backgroundColor: GoRushColors.background,
      appBar: AppBar(
        title: Text('Ride #${_ride.rideId.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: GoRushColors.textPrimary,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => SosEmergencySheet.show(context, rideId: _ride.rideId),
            icon: const Icon(Icons.shield_rounded, color: GoRushColors.primary),
            tooltip: 'Safety Toolkit',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GestureDetector(
                onTap: () => SosEmergencySheet.show(context, rideId: _ride.rideId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.redAccent, blurRadius: 6),
                    ],
                  ),
                  child: const Text(
                    'SOS',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              // State Machine Step Progress Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepIndicator(1, 'Booked', currentStep),
                        _buildStepDivider(1, currentStep),
                        _buildStepIndicator(2, 'Searching', currentStep),
                        _buildStepDivider(2, currentStep),
                        _buildStepIndicator(3, 'Assigned', currentStep),
                        _buildStepDivider(3, currentStep),
                        _buildStepIndicator(4, 'In Trip', currentStep),
                        _buildStepDivider(4, currentStep),
                        _buildStepIndicator(5, 'Completed', currentStep),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(GoRushSpacing.md),
                  child: Column(
                    children: [
                      // Ride Status Headline Banner
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            if (_ride.status == RideStatus.searching || _ride.status == RideStatus.requested) ...[
                              const SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(color: GoRushColors.primary, strokeWidth: 3),
                              ),
                              const SizedBox(height: 14),
                            ] else if (_ride.status == RideStatus.driverAssigned || _ride.status == RideStatus.driverEnRoute) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: GoRushColors.primaryLight, shape: BoxShape.circle),
                                child: const Icon(Icons.check_circle_rounded, color: GoRushColors.primary, size: 36),
                              ),
                              const SizedBox(height: 10),
                            ],

                            // Live Map Display
                            if (_latestLocation != null || _ride.status != RideStatus.searching) ...[
                              Container(
                                height: 200,
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _mapsProvider.buildMap(),
                                ),
                              ),
                            ],

                            Text(
                              _getStatusText(_ride.status),
                              style: GoRushTypography.h3.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),

                            if (_ride.status == RideStatus.driverAssigned || _ride.status == RideStatus.driverEnRoute) ...[
                              const SizedBox(height: 10),
                              // OTP Start Code Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF00C853)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_clock_rounded, size: 16, color: Color(0xFF00C853)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Start OTP: ${_ride.otpCode}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (_latestLocation != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  '📡 GPS: [${_latestLocation!.latitude.toStringAsFixed(4)}, ${_latestLocation!.longitude.toStringAsFixed(4)}] • Live Stream',
                                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: GoRushColors.textSecondary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Driver Details Card (When Driver Assigned)
                      if (_ride.driverName != null && _ride.driverName!.isNotEmpty) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: GoRushColors.primary.withValues(alpha: 0.3)),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: GoRushColors.primary,
                                    child: Text(
                                      _ride.driverName![0],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(_ride.driverName!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(6)),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                                                  const SizedBox(width: 2),
                                                  Text('${_ride.driverRating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text('${_ride.driverVehicle} • ${_ride.driverPlate}', style: const TextStyle(fontSize: 12, color: GoRushColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('$_etaMinutes min', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GoRushColors.primary)),
                                      const Text('ETA', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: Row(
                                              children: const [
                                                Icon(Icons.phone_locked_rounded, color: GoRushColors.primary),
                                                SizedBox(width: 8),
                                                Text('Masked Call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            content: const Text(
                                              'Connecting call via GoRush 256-bit Private Masked Line:\n\n📞 +91 11 4084 1234\n\nYour personal phone number remains 100% private & hidden from driver.',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Dialing +91 11 4084 1234...'), backgroundColor: GoRushColors.primary),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: GoRushColors.primary),
                                                child: const Text('Dial Now', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.phone_rounded, size: 16, color: GoRushColors.primary),
                                      label: const Text('Call Driver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GoRushColors.primary)),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        side: const BorderSide(color: GoRushColors.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => InAppChatSheet(
                                            rideId: _ride.rideId,
                                            driverName: _ride.driverName ?? 'Ramesh Kumar',
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                                      label: const Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: GoRushColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Pickup & Dropoff Address Summary Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_ride.quoteSnapshot.rideCategory.displayName, style: GoRushTypography.h4.copyWith(fontWeight: FontWeight.bold)),
                                Text(_ride.quoteSnapshot.fareBreakdown.total.formatted, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GoRushColors.primary)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.circle, size: 12, color: Color(0xFF00C853)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(_ride.pickupAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: SizedBox(height: 16, child: VerticalDivider(color: Colors.grey, thickness: 1)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 10),
                                Expanded(child: Text(_ride.dropoffAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                              ],
                            ),

                            if (_ride.specialInstructions.isNotEmpty) ...[
                              const Divider(height: 20),
                              Row(
                                children: [
                                  const Icon(Icons.speaker_notes_rounded, size: 14, color: GoRushColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Note: ${_ride.specialInstructions}',
                                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: GoRushColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Complete Ride & Post-Ride Flow Button
                      if (_ride.status == RideStatus.driverAssigned || _ride.status == RideStatus.driverEnRoute || _ride.status == RideStatus.rideStarted || _ride.status == RideStatus.rideInProgress)
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostRideScreen(
                                        rideId: _ride.rideId,
                                        rideRepository: widget.repository,
                                        onComplete: () {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                                label: const Text('Complete Trip & Post-Ride', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),

                      // Cancel Ride Button
                      if (_ride.status == RideStatus.searching || _ride.status == RideStatus.requested || _ride.status == RideStatus.driverAssigned)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isCancelling ? null : _cancelRide,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isCancelling
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                                : const Text('Cancel Ride Request', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),

                      if (_ride.status == RideStatus.cancelled || _ride.status == RideStatus.noDriver)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GoRushColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Return to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String label, int currentStep) {
    final isDone = currentStep > stepNumber;
    final isCurrent = currentStep == stepNumber;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone || isCurrent ? GoRushColors.primary : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : Colors.grey[600],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? GoRushColors.primary : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int stepNumber, int currentStep) {
    final isDone = currentStep > stepNumber;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? GoRushColors.primary : Colors.grey[200],
      ),
    );
  }
}
