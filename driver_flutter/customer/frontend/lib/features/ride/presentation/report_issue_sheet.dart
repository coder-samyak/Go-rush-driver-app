import 'package:flutter/material.dart';
import '../../../core/ride/data/ride_repository.dart';

class ReportIssueSheet extends StatefulWidget {
  final String rideId;
  final RideRepository rideRepository;

  const ReportIssueSheet({
    super.key,
    required this.rideId,
    required this.rideRepository,
  });

  static Future<void> show(BuildContext context, {required String rideId, required RideRepository rideRepository}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportIssueSheet(rideId: rideId, rideRepository: rideRepository),
    );
  }

  @override
  State<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<ReportIssueSheet> {
  final List<Map<String, String>> _categories = const [
    {'id': 'OVERCHARGED', 'title': 'Overcharged / Incorrect Fare', 'icon': 'receipt_long'},
    {'id': 'ROUTE_DEVIATION', 'title': 'Driver Took Longer Route', 'icon': 'alt_route'},
    {'id': 'HYGIENE', 'title': 'Vehicle Hygiene / AC Issue', 'icon': 'cleaning_services'},
    {'id': 'UNSAFE_DRIVING', 'title': 'Unsafe Driving / Rash Driving', 'icon': 'warning_amber'},
    {'id': 'BEHAVIOR', 'title': 'Rude / Unprofessional Behavior', 'icon': 'person_off'},
    {'id': 'OTHER', 'title': 'Other Issue', 'icon': 'help_outline'},
  ];

  String? _selectedCategory;
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'alt_route':
        return Icons.alt_route_rounded;
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'warning_amber':
        return Icons.warning_amber_rounded;
      case 'person_off':
        return Icons.person_off_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> _submitIssue() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await widget.rideRepository.reportIssue(
        rideId: widget.rideId,
        issueCategory: _selectedCategory!,
        description: _descController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E2620),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 28),
                SizedBox(width: 10),
                Text('Support Ticket Created', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Your ticket ID is ${res['ticketId'] ?? 'TK-8912'}.\nOur support team will review this and respond within ${res['expectedResponseHours'] ?? 2} hours.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report issue: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF161C18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Report an Issue',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select the category that best describes your trip issue.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['id'];
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat['id']),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00C853).withValues(alpha: 0.15) : const Color(0xFF222B24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00C853) : Colors.white10,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_getIconData(cat['icon']!), color: isSelected ? const Color(0xFF00C853) : Colors.white60, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat['title']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Additional Details (Optional)',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe what happened in detail...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF222B24),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00C853)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Ticket',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
