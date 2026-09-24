import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/safe_avatar.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onEditProfileTap;
  final VoidCallback? onVehicleTap;
  final VoidCallback? onDocumentsTap;
  final VoidCallback? onBankTap;
  final VoidCallback? onPushNotificationTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onLogoutTap;
  final Function(int)? onBottomNavTap;

  const SettingsScreen({
    super.key,
    this.onBackTap,
    this.onEditProfileTap,
    this.onVehicleTap,
    this.onDocumentsTap,
    this.onBankTap,
    this.onPushNotificationTap,
    this.onLanguageTap,
    this.onPrivacyTap,
    this.onLogoutTap,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Settings',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top User Card (Phone 18: User Pane Driver)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: QuickServeColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: QuickServeColors.primaryBlue, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/captain_aman.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SafeAvatar(
                                  imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                                  radius: 25,
                                  fallbackText: 'RS',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'User Pane Driver',
                                  style: TextStyle(
                                    color: QuickServeColors.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '+91 81224 367641 • Active',
                                  style: TextStyle(
                                    color: QuickServeColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: QuickServeColors.statusGreenLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                color: QuickServeColors.statusGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Group 1: Profile & Account
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal details',
                        onTap: onEditProfileTap,
                      ),
                      const Divider(height: 1, color: QuickServeColors.borderLight),
                      _buildSettingsTile(
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicle Details',
                        subtitle: 'Toyota Etios • DL 01 AB 1234',
                        onTap: onVehicleTap,
                      ),
                      const Divider(height: 1, color: QuickServeColors.borderLight),
                      _buildSettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Documents & Verification',
                        subtitle: 'DL, RC, Insurance verified',
                        onTap: onDocumentsTap,
                      ),
                      const Divider(height: 1, color: QuickServeColors.borderLight),
                      _buildSettingsTile(
                        icon: Icons.account_balance_outlined,
                        title: 'Bank Details & UPI',
                        subtitle: 'HDFC Bank • Instant Payouts',
                        onTap: onBankTap,
                      ),
                    ]),

                    const SizedBox(height: 14),

                    // Group 2: App Preferences
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.notifications_none,
                        title: 'Push Notifications',
                        subtitle: 'Ride alerts & payment sounds',
                        onTap: onPushNotificationTap,
                      ),
                      const Divider(height: 1, color: QuickServeColors.borderLight),
                      _buildSettingsTile(
                        icon: Icons.language,
                        title: 'App Language',
                        subtitle: 'English (India)',
                        onTap: onLanguageTap,
                      ),
                      const Divider(height: 1, color: QuickServeColors.borderLight),
                      _buildSettingsTile(
                        icon: Icons.security,
                        title: 'Privacy & Security',
                        subtitle: 'App lock & location controls',
                        onTap: onPrivacyTap,
                      ),
                    ]),

                    const SizedBox(height: 14),

                    // Logout Tile
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: QuickServeColors.borderLight),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout, color: QuickServeColors.statusRed, size: 20),
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: QuickServeColors.statusRed,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: QuickServeColors.statusRed, size: 20),
                        onTap: onLogoutTap,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation (Profile / Settings Active: Index 4)
            AppBottomNav(
              currentIndex: 4,
              onTap: (idx) {
                if (onBottomNavTap != null) {
                  onBottomNavTap!(idx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: QuickServeColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: QuickServeColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: QuickServeColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: QuickServeColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
