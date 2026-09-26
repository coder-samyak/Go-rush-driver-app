import 'package:flutter/material.dart';
import '../../../core/pricing/domain/quote_models.dart';
import '../../../core/ride/data/ride_repository.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/tokens.dart';
import '../../ride/presentation/ride_status_screen.dart';
import '../../../core/realtime/application/realtime_service.dart';

class RideBookingConfirmationScreen extends StatefulWidget {
  final Quote quote;
  final RideRepository rideRepository;
  final String pickupAddress;
  final String dropoffAddress;
  final String paymentMethod;

  const RideBookingConfirmationScreen({
    super.key,
    required this.quote,
    required this.rideRepository,
    this.pickupAddress = 'Sector 63, Noida (GPS Fixed)',
    this.dropoffAddress = 'Terminal 3, IGI Airport, New Delhi',
    this.paymentMethod = 'Google Pay',
  });

  @override
  State<RideBookingConfirmationScreen> createState() => _RideBookingConfirmationScreenState();
}

class _RideBookingConfirmationScreenState extends State<RideBookingConfirmationScreen> {
  bool _isBooking = false;
  late String _selectedPayment;
  final TextEditingController _instructionController = TextEditingController();
  final Set<String> _selectedPresets = {};

  final List<Map<String, String>> _instructionPresets = [
    {'icon': '📞', 'label': 'Call upon arrival'},
    {'icon': '🚪', 'label': 'Wait near Gate 2'},
    {'icon': '🧳', 'label': 'Heavy luggage'},
    {'icon': '🤫', 'label': 'Quiet ride'},
    {'icon': '❄️', 'label': 'AC full cooling'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPayment = widget.paymentMethod;
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  void _togglePreset(String label) {
    setState(() {
      if (_selectedPresets.contains(label)) {
        _selectedPresets.remove(label);
      } else {
        _selectedPresets.add(label);
      }
    });
  }

  String _buildFinalInstructions() {
    final text = _instructionController.text.trim();
    final presetsStr = _selectedPresets.join(', ');
    if (presetsStr.isNotEmpty && text.isNotEmpty) {
      return '$presetsStr | $text';
    }
    return presetsStr.isNotEmpty ? presetsStr : text;
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    try {
      final ride = await widget.rideRepository.createRide(
        quoteId: widget.quote.quoteId,
        idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(),
        pickupAddress: widget.pickupAddress,
        dropoffAddress: widget.dropoffAddress,
        paymentMethod: _selectedPayment,
        specialInstructions: _buildFinalInstructions(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RideStatusScreen(
              initialRide: ride,
              repository: widget.rideRepository,
              realtimeService: SocketIoRealtimeService(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.quote.rideCategory;

    return Scaffold(
      backgroundColor: GoRushColors.background,
      appBar: AppBar(
        title: const Text('Confirm Ride Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: GoRushColors.textPrimary,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GoRushSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Pickup & Dropoff Route Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, color: Color(0xFF00C853), size: 14),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Pickup Location', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                Text(widget.pickupAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_location_alt_rounded, size: 18, color: GoRushColors.primary),
                            tooltip: 'Refine Pickup',
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: 18,
                            child: VerticalDivider(color: Colors.grey, thickness: 1.5),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Dropoff Location', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                Text(widget.dropoffAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Selected Vehicle & Guaranteed Fare Card
                Container(
                  decoration: BoxDecoration(
                    color: GoRushColors.primaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GoRushColors.primary.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: GoRushColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat.displayName, style: GoRushTypography.h4.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('${cat.capacity} Passengers • AC • 3m ETA', style: const TextStyle(fontSize: 11, color: GoRushColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.quote.fareBreakdown.total.formatted,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GoRushColors.primary),
                          ),
                          const Text('Guaranteed Fare', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Driver Instructions & Preset Chips Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.speaker_notes_rounded, size: 16, color: GoRushColors.primary),
                          SizedBox(width: 6),
                          Text('Special Instructions for Driver', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Instruction Preset Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _instructionPresets.map((preset) {
                          final isSelected = _selectedPresets.contains(preset['label']);
                          return ChoiceChip(
                            selected: isSelected,
                            label: Text('${preset['icon']} ${preset['label']}', style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            selectedColor: GoRushColors.primaryLight,
                            backgroundColor: Colors.grey[100],
                            labelStyle: TextStyle(color: isSelected ? GoRushColors.primary : GoRushColors.textPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: isSelected ? GoRushColors.primary : Colors.grey[300]!),
                            ),
                            onSelected: (_) => _togglePreset(preset['label']!),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 10),

                      // Freeform Text Input
                      TextField(
                        controller: _instructionController,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. Please ring doorbell or wait at main entrance...',
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GoRushColors.primary)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 4. Payment Method Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00C853)),
                        title: Text(_selectedPayment, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: const Text('Verified & Secured 256-bit', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Confirm & Request Ride CTA Button
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF00A843)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isBooking ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isBooking
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Book ${cat.displayName} • ${widget.quote.fareBreakdown.total.formatted}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
