import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/safety_repository.dart';
import '../domain/emergency_contact.dart';

class SosEmergencySheet extends StatefulWidget {
  final String rideId;
  final SafetyRepository? repository;

  const SosEmergencySheet({
    super.key,
    required this.rideId,
    this.repository,
  });

  static Future<void> show(BuildContext context, {String rideId = 'ride_active', SafetyRepository? repository}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SosEmergencySheet(rideId: rideId, repository: repository),
    );
  }

  @override
  State<SosEmergencySheet> createState() => _SosEmergencySheetState();
}

class _SosEmergencySheetState extends State<SosEmergencySheet> with SingleTickerProviderStateMixin {
  late final SafetyRepository _repository;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isTriggering = false;
  bool _sosAlertActive = false;
  Map<String, dynamic>? _sosAlertResult;
  List<EmergencyContact> _contacts = [];
  bool _isLoadingContacts = true;
  bool _isAudioRecording = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HttpSafetyRepository();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadContacts();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final contacts = await _repository.getEmergencyContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
        _isLoadingContacts = false;
      });
    }
  }

  Future<void> _triggerSos() async {
    HapticFeedback.vibrate();
    setState(() {
      _isTriggering = true;
    });

    final result = await _repository.triggerSosAlert(rideId: widget.rideId);

    if (mounted) {
      setState(() {
        _isTriggering = false;
        _sosAlertActive = true;
        _sosAlertResult = result;
      });
    }
  }

  Future<void> _addNewContact() async {
    _nameController.clear();
    _phoneController.clear();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.person_add_rounded, color: Color(0xFF00C853)),
            SizedBox(width: 8),
            Text('Add Emergency Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'e.g. Mom, Brother, Spouse',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g. +91 98765 43210',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
            onPressed: () async {
              final name = _nameController.text.trim();
              final phone = _phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                Navigator.pop(ctx);
                final newContact = await _repository.addEmergencyContact(name: name, phone: phone);
                setState(() {
                  _contacts.add(newContact);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added $name to Emergency Contacts!')),
                  );
                }
              }
            },
            child: const Text('Save Contact', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareTrip() async {
    final trackingUrl = await _repository.shareLiveRide(rideId: widget.rideId);
    if (mounted) {
      Clipboard.setData(ClipboardData(text: trackingUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Live Ride Link copied to Clipboard!\n$trackingUrl'),
          backgroundColor: const Color(0xFF00C853),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _makeCall(String label, String number) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text('Call $label?'),
          ],
        ),
        content: Text('Calling $number directly from your phone...'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dialing $label ($number)...')),
              );
            },
            child: const Text('Call Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDC2626).withValues(alpha: 0.25),
                  const Color(0xFF111827),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFFEF4444), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'EMERGENCY & SAFETY TOOLKIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '24x7 Live Shield & Instant Escalation',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ACTIVE SOS ALERT BANNER IF TRIGGERED
                  if (_sosAlertActive) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF991B1B).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.redAccent, blurRadius: 12),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                              SizedBox(width: 10),
                              Text(
                                '🚨 SOS ALERT ACTIVE!',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _sosAlertResult?['message'] ?? '24x7 Safety Command Center notified. Police helpline 112 standby.',
                            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Alert ID: ${_sosAlertResult?['alertId'] ?? 'sos_active'}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'GPS Broadcasting Live',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ] else ...[
                    // MAIN BIG RED SOS TRIGGER BUTTON
                    Center(
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: GestureDetector(
                          onTap: _isTriggering ? null : _triggerSos,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFFEF4444),
                                  Color(0xFFDC2626),
                                  Color(0xFF991B1B),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isTriggering)
                                  const CircularProgressIndicator(color: Colors.white)
                                else ...[
                                  const Icon(Icons.sos_rounded, color: Colors.white, size: 54),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'TAP FOR SOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Press to instantly alert 24x7 Safety Command Center, Police 112 & Emergency Contacts',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 11.5),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // QUICK EMERGENCY DIAL HOTLINES
                  const Text(
                    'INSTANT EMERGENCY HOTLINES',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEmergencyCallCard(
                          icon: Icons.local_police_rounded,
                          color: const Color(0xFFEF4444),
                          title: 'Police 112',
                          subtitle: 'National Emergency',
                          onTap: () => _makeCall('Police 112', '112'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEmergencyCallCard(
                          icon: Icons.support_agent_rounded,
                          color: const Color(0xFF00C853),
                          title: 'Safety Command',
                          subtitle: 'GoRush 24x7',
                          onTap: () => _makeCall('GoRush Safety Desk', '+91 1800-467874'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEmergencyCallCard(
                          icon: Icons.medical_services_rounded,
                          color: Colors.blueAccent,
                          title: 'Ambulance 108',
                          subtitle: 'Medical Helpline',
                          onTap: () => _makeCall('Ambulance 108', '108'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // LIVE RIDE LOCATION SHARING & AUDIO RECORDING TOOLKIT
                  const Text(
                    'SAFETY TOOLKIT',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.share_location_rounded, color: Color(0xFF00C853)),
                          ),
                          title: const Text('Share Live Ride Track Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text('Send live GPS tracking link via WhatsApp/SMS', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          trailing: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
                            onPressed: _shareTrip,
                            icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                            label: const Text('Copy Link', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                        Divider(color: Colors.grey[800], height: 1),
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.mic_rounded, color: _isAudioRecording ? Colors.redAccent : Colors.amber),
                          ),
                          title: const Text('Audio Safety Shield', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                            _isAudioRecording ? 'Audio recording ACTIVE for ride safety' : 'Record audio locally for trip safety evidence',
                            style: TextStyle(color: _isAudioRecording ? Colors.redAccent : Colors.grey, fontSize: 12),
                          ),
                          value: _isAudioRecording,
                          onChanged: (val) {
                            setState(() {
                              _isAudioRecording = val;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val ? '🎙️ Audio Safety Shield Started!' : 'Audio Safety Shield Paused.'),
                                backgroundColor: val ? Colors.redAccent : Colors.grey[800],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // EMERGENCY CONTACTS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EMERGENCY CONTACTS',
                        style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                      TextButton.icon(
                        onPressed: _addNewContact,
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00C853), size: 18),
                        label: const Text('Add Contact', style: TextStyle(color: Color(0xFF00C853), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_isLoadingContacts)
                    const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Color(0xFF00C853))))
                  else if (_contacts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('No emergency contacts added yet. Tap "Add Contact" to list family or friends.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    )
                  else
                    ..._contacts.map((contact) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00C853).withValues(alpha: 0.2),
                          child: Text(
                            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'E',
                            style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(contact.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${contact.phone} • ${contact.relationship}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.call_rounded, color: Color(0xFF00C853)),
                              onPressed: () => _makeCall(contact.name, contact.phone),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                              onPressed: () async {
                                await _repository.deleteEmergencyContact(contact.id);
                                setState(() {
                                  _contacts.removeWhere((c) => c.id == contact.id);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCallCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
