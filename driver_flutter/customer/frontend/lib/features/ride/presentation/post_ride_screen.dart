import 'package:flutter/material.dart';
import '../../../core/ride/data/ride_repository.dart';
import 'report_issue_sheet.dart';
import 'lost_item_sheet.dart';

class PostRideScreen extends StatefulWidget {
  final String rideId;
  final RideRepository rideRepository;
  final VoidCallback onComplete;

  const PostRideScreen({
    super.key,
    required this.rideId,
    required this.rideRepository,
    required this.onComplete,
  });

  @override
  State<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends State<PostRideScreen> {
  int _selectedRating = 5;
  final Set<String> _selectedFeedbackTags = {'Clean Car', 'Punctual', 'Polite'};
  final TextEditingController _commentController = TextEditingController();

  final List<double> _tipOptions = [0, 30, 50, 100];
  double _selectedTip = 30;
  final TextEditingController _customTipController = TextEditingController();
  bool _isCustomTip = false;

  bool _isSubmitting = false;
  Map<String, dynamic>? _receiptData;

  final List<String> _availableTags = [
    'Clean Car',
    'Smooth Driver',
    'Punctual',
    'Polite',
    'Great Music',
    'Safe Driving',
    'Great Navigation',
  ];

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    try {
      final res = await widget.rideRepository.getReceipt(rideId: widget.rideId);
      if (mounted) {
        setState(() {
          _receiptData = res;
        });
      }
    } catch (_) {}
  }

  Future<void> _submitFeedbackAndFinish() async {
    setState(() => _isSubmitting = true);

    try {
      final finalTip = _isCustomTip
          ? (double.tryParse(_customTipController.text) ?? 0)
          : _selectedTip;

      await widget.rideRepository.submitRating(
        rideId: widget.rideId,
        rating: _selectedRating,
        feedbackTags: _selectedFeedbackTags.toList(),
        comment: _commentController.text.trim(),
        tipAmount: finalTip,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for rating your ride!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFareMinor = _receiptData?['breakdown']?['total']?['amountMinor'] ?? 18900;
    final totalFareDisplay = (totalFareMinor / 100.0).toStringAsFixed(2);
    final driverName = _receiptData?['driverName'] ?? 'Ramesh Kumar';
    final vehicle = _receiptData?['vehicle'] ?? 'Maruti Suzuki Dzire';
    final invoiceId = _receiptData?['invoiceId'] ?? 'INV-2026-RD9821';

    return Scaffold(
      backgroundColor: const Color(0xFF0E1410),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // Top AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trip Summary',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: widget.onComplete,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // Success Animated Badge
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00C853).withValues(alpha: 0.15),
                            border: Border.all(color: const Color(0xFF00C853), width: 2),
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 44),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          'You Have Arrived!',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hope you enjoyed your ride with $driverName',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

                        // Driver Rating Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161C18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFF00C853).withValues(alpha: 0.2),
                                    child: const Icon(Icons.person, color: Color(0xFF00C853), size: 30),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          driverName,
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          vehicle,
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          '4.9',
                                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Rate Your Experience',
                                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),

                              // Interactive Star Rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  final starIndex = index + 1;
                                  return IconButton(
                                    iconSize: 36,
                                    onPressed: () => setState(() => _selectedRating = starIndex),
                                    icon: Icon(
                                      starIndex <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: starIndex <= _selectedRating ? Colors.amber : Colors.white24,
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),

                              // Feedback Tags
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'What went well?',
                                  style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableTags.map((tag) {
                                  final isSelected = _selectedFeedbackTags.contains(tag);
                                  return FilterChip(
                                    label: Text(tag),
                                    selected: isSelected,
                                    onSelected: (val) {
                                      setState(() {
                                        if (val) {
                                          _selectedFeedbackTags.add(tag);
                                        } else {
                                          _selectedFeedbackTags.remove(tag);
                                        }
                                      });
                                    },
                                    selectedColor: const Color(0xFF00C853).withValues(alpha: 0.25),
                                    backgroundColor: const Color(0xFF222B24),
                                    checkmarkColor: const Color(0xFF00C853),
                                    labelStyle: TextStyle(
                                      color: isSelected ? const Color(0xFF00C853) : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    side: BorderSide(
                                      color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // Driver note
                              TextField(
                                controller: _commentController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Add a compliment or driver note (optional)...',
                                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF222B24),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tip Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161C18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add a Tip for Driver',
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '100% of the tip goes directly to $driverName',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  ..._tipOptions.map((tip) {
                                    final isSelected = !_isCustomTip && _selectedTip == tip;
                                    final label = tip == 0 ? 'No Tip' : '₹${tip.toInt()}';
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isCustomTip = false;
                                              _selectedTip = tip;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF00C853).withValues(alpha: 0.2)
                                                  : const Color(0xFF222B24),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                label,
                                                style: TextStyle(
                                                  color: isSelected ? const Color(0xFF00C853) : Colors.white70,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() => _isCustomTip = true);
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _isCustomTip
                                                ? const Color(0xFF00C853).withValues(alpha: 0.2)
                                                : const Color(0xFF222B24),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _isCustomTip ? const Color(0xFF00C853) : Colors.transparent,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Custom',
                                              style: TextStyle(
                                                color: _isCustomTip ? const Color(0xFF00C853) : Colors.white70,
                                                fontWeight: _isCustomTip ? FontWeight.bold : FontWeight.normal,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isCustomTip) ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _customTipController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    prefixText: '₹ ',
                                    prefixStyle: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold),
                                    hintText: 'Enter custom tip amount',
                                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFF222B24),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Final Fare & Receipt Breakdown Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161C18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Final Fare & Tax Receipt',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C853).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'PAID',
                                      style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Invoice #: $invoiceId',
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                              const SizedBox(height: 16),
                              const Divider(color: Colors.white12, height: 1),
                              const SizedBox(height: 14),

                              _buildReceiptRow('Base Fare', '₹80.00'),
                              const SizedBox(height: 8),
                              _buildReceiptRow('Distance Fare (5.5 km)', '₹85.00'),
                              const SizedBox(height: 8),
                              _buildReceiptRow('Platform Fee', '₹15.00'),
                              const SizedBox(height: 8),
                              _buildReceiptRow('GST (5%)', '₹9.00'),
                              const SizedBox(height: 14),
                              const Divider(color: Colors.white12, height: 1),
                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Charged',
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Paid via Google Pay',
                                        style: TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹$totalFareDisplay',
                                    style: const TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons: Issue & Lost Item
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ReportIssueSheet.show(
                                    context,
                                    rideId: widget.rideId,
                                    rideRepository: widget.rideRepository,
                                  );
                                },
                                icon: const Icon(Icons.support_agent_rounded, color: Colors.white70, size: 18),
                                label: const Text('Report Issue', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  LostItemSheet.show(
                                    context,
                                    rideId: widget.rideId,
                                    rideRepository: widget.rideRepository,
                                  );
                                },
                                icon: const Icon(Icons.find_in_page_rounded, color: Colors.white70, size: 18),
                                label: const Text('Lost Item?', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Bottom Submit & Done Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161C18),
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedbackAndFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Done & Submit Rating',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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

  Widget _buildReceiptRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(amount, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
