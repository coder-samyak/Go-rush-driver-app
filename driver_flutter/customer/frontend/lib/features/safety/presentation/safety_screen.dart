import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/tokens.dart';
import '../domain/share_session.dart';
import 'share_ride_sheet.dart';
import 'sos_emergency_sheet.dart';

class SafetyScreen extends StatefulWidget {
  final String rideId;

  const SafetyScreen({super.key, required this.rideId});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  List<RideShareSession> activeShares = [];

  void _showShareSheet() async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ShareRideSheet(rideId: widget.rideId),
    );

    if (success == true) {
      setState(() {
        activeShares.add(RideShareSession(
          id: 'share_${DateTime.now().millisecondsSinceEpoch}',
          recipientName: 'Family Member',
          status: RideShareStatus.active,
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        ));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp message sent!')));
      }
    }
  }

  void _revokeShare(String id) {
    setState(() {
      activeShares.removeWhere((s) => s.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live sharing stopped.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoRushColors.background,
      appBar: AppBar(
        title: const Text('Safety & Emergency Toolkit'),
        backgroundColor: GoRushColors.surface,
        foregroundColor: GoRushColors.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GoRushSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BIG SOS EMERGENCY CARD
            GestureDetector(
              onTap: () => SosEmergencySheet.show(context, rideId: widget.rideId),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.redAccent, blurRadius: 12, spreadRadius: 1),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sos_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'TRIGGER EMERGENCY SOS',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Alert Police 112, 24x7 Safety Command Center & Emergency Contacts',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: GoRushSpacing.xl),

            Container(
              padding: const EdgeInsets.all(GoRushSpacing.md),
              decoration: BoxDecoration(
                color: GoRushColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: GoRushColors.primary, size: 32),
                  const SizedBox(width: GoRushSpacing.md),
                  Expanded(
                    child: Text(
                      'Your ride is monitored 24x7. You can share your live location securely with trusted contacts.',
                      style: GoRushTypography.body2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GoRushSpacing.xl),

            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: Text('Share Live Ride Track Link', style: GoRushTypography.button),
              onPressed: _showShareSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: GoRushColors.primary,
                foregroundColor: GoRushColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: GoRushSpacing.md),
              ),
            ),
            const SizedBox(height: GoRushSpacing.xl),

            Text('Active Live Shares', style: GoRushTypography.h3),
            const SizedBox(height: GoRushSpacing.md),
            if (activeShares.isEmpty)
              Text('You are not active sharing this ride right now.', style: GoRushTypography.body2.copyWith(color: Colors.grey)),
            ...activeShares.map((share) => Card(
              margin: const EdgeInsets.only(bottom: GoRushSpacing.sm),
              child: ListTile(
                title: Text(share.recipientName, style: GoRushTypography.body1),
                subtitle: const Text('Live location active'),
                trailing: TextButton(
                  onPressed: () => _revokeShare(share.id),
                  child: const Text('Stop', style: TextStyle(color: GoRushColors.error)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
