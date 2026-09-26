import 'package:flutter/material.dart';
import '../../../core/user/data/user_repository.dart';
import '../../../core/user/domain/user_models.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final UserRepository userRepository;

  const NotificationSettingsScreen({
    super.key,
    required this.userRepository,
  });

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  NotificationSettingsModel? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final res = await widget.userRepository.getNotifications();
      if (mounted) {
        setState(() {
          _settings = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSetting(String key, bool value) async {
    if (_settings == null) return;

    final updatedMap = _settings!.toJson();
    updatedMap[key] = value;

    setState(() {
      _settings = NotificationSettingsModel.fromJson(updatedMap);
    });

    try {
      await widget.userRepository.updateNotifications(updatedMap);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1410),
      appBar: AppBar(
        title: const Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF161C18),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSwitchTile(
                      title: 'Push Notifications',
                      subtitle: 'Receive real-time trip status and driver arrival alerts',
                      value: _settings?.pushEnabled ?? true,
                      onChanged: (val) => _toggleSetting('pushEnabled', val),
                    ),
                    _buildSwitchTile(
                      title: 'SMS Notifications',
                      subtitle: 'Receive trip Receipts and OTP codes via SMS',
                      value: _settings?.smsEnabled ?? true,
                      onChanged: (val) => _toggleSetting('smsEnabled', val),
                    ),
                    _buildSwitchTile(
                      title: 'Promotional Offers & Discounts',
                      subtitle: 'Receive exclusive deals, coupon codes, and weekend discount alerts',
                      value: _settings?.promoOffersEnabled ?? false,
                      onChanged: (val) => _toggleSetting('promoOffersEnabled', val),
                    ),
                    _buildSwitchTile(
                      title: 'Trip Status Updates',
                      subtitle: 'Driver assignment, arrival, and destination dropoff notifications',
                      value: _settings?.tripStatusAlerts ?? true,
                      onChanged: (val) => _toggleSetting('tripStatusAlerts', val),
                    ),
                    _buildSwitchTile(
                      title: 'Safety & SOS Alerts',
                      subtitle: 'Critical safety updates and emergency contact broadcast notifications',
                      value: _settings?.safetyAlerts ?? true,
                      onChanged: (val) => _toggleSetting('safetyAlerts', val),
                    ),
                    _buildSwitchTile(
                      title: 'Sound & Vibration',
                      subtitle: 'Play alert sounds and vibrate for ride updates',
                      value: _settings?.soundVibrationEnabled ?? true,
                      onChanged: (val) => _toggleSetting('soundVibrationEnabled', val),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161C18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: const Color(0xFF00C853),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
