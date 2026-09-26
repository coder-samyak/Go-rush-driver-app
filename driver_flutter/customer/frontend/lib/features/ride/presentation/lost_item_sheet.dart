import 'package:flutter/material.dart';
import '../../../core/ride/data/ride_repository.dart';

class LostItemSheet extends StatefulWidget {
  final String rideId;
  final RideRepository rideRepository;

  const LostItemSheet({
    super.key,
    required this.rideId,
    required this.rideRepository,
  });

  static Future<void> show(BuildContext context, {required String rideId, required RideRepository rideRepository}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LostItemSheet(rideId: rideId, rideRepository: rideRepository),
    );
  }

  @override
  State<LostItemSheet> createState() => _LostItemSheetState();
}

class _LostItemSheetState extends State<LostItemSheet> {
  final List<Map<String, String>> _categories = const [
    {'id': 'PHONE', 'title': 'Phone / Tablet / Laptop', 'icon': 'phone_iphone'},
    {'id': 'WALLET', 'title': 'Wallet / Cash / Cards', 'icon': 'account_balance_wallet'},
    {'id': 'KEYS', 'title': 'Keys / Access Card', 'icon': 'key'},
    {'id': 'BAG', 'title': 'Luggage / Bag / Jacket', 'icon': 'work'},
    {'id': 'GLASSES', 'title': 'Glasses / Accessories', 'icon': 'visibility'},
    {'id': 'OTHER', 'title': 'Other Personal Item', 'icon': 'inventory_2'},
  ];

  String? _selectedCategory;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '+91 98765 43210');
  bool _isSubmitting = false;

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'phone_iphone':
        return Icons.phone_iphone_rounded;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_rounded;
      case 'key':
        return Icons.key_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'visibility':
        return Icons.visibility_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Future<void> _submitLostItem() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the item left behind')),
      );
      return;
    }

    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a brief item description')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await widget.rideRepository.reportLostItem(
        rideId: widget.rideId,
        itemCategory: _selectedCategory!,
        description: _descController.text.trim(),
        preferredContact: _phoneController.text.trim(),
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
                Icon(Icons.search_rounded, color: Color(0xFF00C853), size: 28),
                SizedBox(width: 10),
                Text('Driver Alert Sent', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Case ID: ${res['caseId'] ?? 'CASE-3091'}\n\nWe have dispatched an immediate notification to Ramesh Kumar. The driver will search the vehicle and contact you at ${_phoneController.text.trim()}',
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
          SnackBar(content: Text('Failed to submit lost item report: $e')),
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
                  'Report Lost Item',
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
              'Did you leave something in the vehicle? Let us alert the driver immediately.',
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
              'Item Description',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Black leather wallet with driving license',
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
            const SizedBox(height: 14),
            const Text(
              'Preferred Contact Phone',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF00C853), size: 20),
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
                onPressed: _isSubmitting ? null : _submitLostItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Alert Driver',
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
