import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_toast.dart';
import '../core/theme.dart';
import '../services/ride_service.dart';
import '../services/location_service.dart';
import '../services/support_ticket_service.dart';

class SafetyHubSosCenterScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const SafetyHubSosCenterScreen({
    super.key,
    this.onBackTap,
  });

  @override
  State<SafetyHubSosCenterScreen> createState() =>
      _SafetyHubSosCenterScreenState();
}

class _SafetyHubSosCenterScreenState extends State<SafetyHubSosCenterScreen> {
  bool _isSosActive = false;

  Future<void> _callEmergency(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        AppToast.error(
            context, 'Could not open dialer. Please dial $number manually.');
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(
            context, 'Could not open dialer. Please dial $number manually.');
      }
    }
  }

  Future<void> _shareTrip() async {
    final location = await LocationService.instance.currentPosition();
    if (!mounted) return;
    if (location == null) {
      AppToast.error(
          context, 'Allow location permission to share your live location.');
      return;
    }
    await Share.share(
        'GoRush Safety: I am on an active trip. My current location: https://maps.google.com/?q=${location.latitude},${location.longitude}');
  }

  void _showSafetyInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ]),
    );
  }

  Future<void> _emergencyContact() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final call = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Contact name')),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Call contact')),
        ],
      ),
    );
    if (call == true && phone.text.trim().isNotEmpty) await _callEmergency(phone.text.trim());
  }

  Future<void> _reportIncident() async {
    final details = TextEditingController();
    final submit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Safety Incident'),
        content: TextField(controller: details, maxLines: 5, decoration: const InputDecoration(hintText: 'Describe what happened and your current safety needs.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Submit report')),
        ],
      ),
    );
    if (submit != true || details.text.trim().isEmpty) return;
    final ticket = await SupportTicketService.instance.create(
      title: 'Safety incident report', category: 'Safety Incident', description: details.text.trim());
    if (!mounted) return;
    ticket == null
        ? AppToast.error(context, 'Report could not be sent. Try Safety Desk or call 112.')
        : AppToast.success(context, 'Incident ${ticket.number} sent to Safety Desk.');
  }

  @override
  Widget build(BuildContext context) {
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
          'Safety & SOS Center',
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
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Broadcast Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Emergency SOS',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Press and hold to instantly broadcast your live GPS to GoRush Emergency Dispatch and Police.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Large Red Circular SOS Button
                    GestureDetector(
                      onTap: () async {
                        if (_isSosActive) {
                          setState(() => _isSosActive = false);
                          AppToast.show(
                              context, 'Emergency beacon display deactivated.');
                          return;
                        }
                        final sent = await RideService.instance.triggerSos();
                        if (!context.mounted) return;
                        if (sent) {
                          setState(() => _isSosActive = true);
                          AppToast.error(context,
                              'EMERGENCY BEACON TRIGGERED: GoRush Safety Desk notified.');
                        } else {
                          AppToast.error(context,
                              'SOS needs location permission and a network connection.');
                        }
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: QuickServeColors.statusRed,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  QuickServeColors.statusRed.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              _isSosActive ? 'ACTIVE' : 'EMERGENCY',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      '24x7 GoRush Emergency Response Protocol Active',
                      style: TextStyle(
                        color: QuickServeColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4 Safety Action Cards Grid (2x2)
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.contact_phone_outlined,
                      title: 'Emergency Contacts',
                      subtitle: 'Family & Guardians',
                      color: QuickServeColors.primaryOrange,
                      onTap: _emergencyContact,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.share_location_outlined,
                      title: 'Share Trip',
                      subtitle: 'Live GPS link',
                      color: const Color(0xFF3B82F6),
                      onTap: _shareTrip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.security,
                      title: 'Safety Center',
                      subtitle: 'Guidelines & FAQs',
                      color: QuickServeColors.statusGreen,
                      onTap: () => _showSafetyInfo('Safety Center',
                          'Move to a safe public place, keep your doors locked, share your trip location with a trusted contact, and call 112 immediately if you are in danger.'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.report_problem_outlined,
                      title: 'Report Incident',
                      subtitle: 'Disputes & Accidents',
                      color: const Color(0xFFF59E0B),
                      onTap: _reportIncident,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Direct Helpline Calls
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.local_police,
                          color: QuickServeColors.statusRed),
                      label: const Text('Call Police (112)'),
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: QuickServeColors.statusRed),
                        foregroundColor: QuickServeColors.statusRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _callEmergency('112'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon:
                          const Icon(Icons.support_agent, color: Colors.white),
                      label: const Text('Safety Desk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuickServeColors.textDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final sent = await RideService.instance.triggerSos();
                        if (!context.mounted) return;
                        sent
                            ? AppToast.success(
                                context, 'Live SOS sent to GoRush Safety Desk.')
                            : AppToast.error(context,
                                'Enable location and check the backend connection.');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: QuickServeColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
