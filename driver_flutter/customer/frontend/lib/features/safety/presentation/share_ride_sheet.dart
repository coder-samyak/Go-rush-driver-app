import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/tokens.dart';

class ShareRideSheet extends StatefulWidget {
  final String rideId;

  const ShareRideSheet({super.key, required this.rideId});

  @override
  State<ShareRideSheet> createState() => _ShareRideSheetState();
}

class _ShareRideSheetState extends State<ShareRideSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSharing = false;

  Future<void> _shareRide() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) return;

    setState(() => _isSharing = true);
    
    // MOCK API CALL
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context, true); // Returns true if successful
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: GoRushSpacing.xl,
        right: GoRushSpacing.xl,
        top: GoRushSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Share Live Ride', style: GoRushTypography.h2),
          const SizedBox(height: GoRushSpacing.sm),
          Text(
            'We will send a secure WhatsApp message with a temporary tracking link. The link expires when the ride completes.',
            style: GoRushTypography.body2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: GoRushSpacing.xl),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Contact Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: GoRushSpacing.md),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'WhatsApp Number',
              border: OutlineInputBorder(),
              prefixText: '+91 ',
            ),
          ),
          const SizedBox(height: GoRushSpacing.xl),
          ElevatedButton(
            onPressed: _isSharing ? null : _shareRide,
            style: ElevatedButton.styleFrom(
              backgroundColor: GoRushColors.primary,
              foregroundColor: GoRushColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: GoRushSpacing.md),
            ),
            child: _isSharing 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Share via WhatsApp', style: GoRushTypography.button),
          ),
          const SizedBox(height: GoRushSpacing.xl),
        ],
      ),
    );
  }
}
