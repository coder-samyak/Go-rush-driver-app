import 'package:flutter/material.dart';
import '../../../core/user/data/user_repository.dart';
import '../../../core/user/domain/user_models.dart';

class PrivacySettingsScreen extends StatefulWidget {
  final UserRepository userRepository;

  const PrivacySettingsScreen({
    super.key,
    required this.userRepository,
  });

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  PrivacySettingsModel? _privacy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    try {
      final res = await widget.userRepository.getPrivacy();
      if (mounted) {
        setState(() {
          _privacy = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSetting(String key, dynamic value) async {
    if (_privacy == null) return;

    final updatedMap = _privacy!.toJson();
    updatedMap[key] = value;

    setState(() {
      _privacy = PrivacySettingsModel.fromJson(updatedMap);
    });

    try {
      await widget.userRepository.updatePrivacy(updatedMap);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1410),
      appBar: AppBar(
        title: const Text('Privacy & Data Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    // Location Permissions Tile
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161C18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Location Permissions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Controls how GoRush accesses high-precision GPS', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildLocationOption('WHILE_USING', 'While Using App'),
                              const SizedBox(width: 8),
                              _buildLocationOption('ALWAYS', 'Always Allow'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    _buildSwitchTile(
                      title: 'Share Live Trip with Emergency Contacts',
                      subtitle: 'Automatically send tracking link to saved contacts during active rides',
                      value: _privacy?.shareLiveTripWithEmergency ?? true,
                      onChanged: (val) => _toggleSetting('shareLiveTripWithEmergency', val),
                    ),
                    _buildSwitchTile(
                      title: 'Personalized Offers & Ads',
                      subtitle: 'Allow GoRush to tailor promos based on travel frequency',
                      value: _privacy?.personalizedAdsConsent ?? false,
                      onChanged: (val) => _toggleSetting('personalizedAdsConsent', val),
                    ),
                    _buildSwitchTile(
                      title: 'Usage Analytics & Performance',
                      subtitle: 'Share anonymous crash reports & performance telemetry',
                      value: _privacy?.analyticsConsent ?? true,
                      onChanged: (val) => _toggleSetting('analyticsConsent', val),
                    ),

                    const SizedBox(height: 12),

                    // Data Download / Export Tile
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161C18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.download_for_offline_rounded, color: Color(0xFF00C853), size: 24),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Download Your Data Archive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                SizedBox(height: 2),
                                Text('Export all trip history, receipts, and profile data in JSON format', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Preparing your data archive. We will email you the download link within 24 hours.'),
                                  backgroundColor: Color(0xFF00C853),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00C853)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Export', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLocationOption(String code, String label) {
    final isSelected = _privacy?.locationPermission == code;
    return Expanded(
      child: InkWell(
        onTap: () => _toggleSetting('locationPermission', code),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00C853).withValues(alpha: 0.2) : const Color(0xFF222B24),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF00C853) : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00C853) : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
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
