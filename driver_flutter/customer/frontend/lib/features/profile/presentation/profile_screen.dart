import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/user/data/user_repository.dart';
import '../../../core/user/domain/user_models.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'delete_account_sheet.dart';
import 'support_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserRepository? userRepository;

  const ProfileScreen({
    super.key,
    this.userRepository,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserRepository _userRepo;
  UserProfileModel? _profile;
  bool _isLoading = true;
  String _selectedTheme = 'Dark Mode (Default)';

  @override
  void initState() {
    super.initState();
    _userRepo = widget.userRepository ?? HttpUserRepository();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await _userRepo.getProfile();
      if (mounted) {
        setState(() {
          _profile = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReferralModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF161C18),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF00C853), width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF00C853), size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Refer & Earn ₹50 Credits',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Invite friends to GoRush & get free rides',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1410),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('YOUR REFERRAL CODE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      SizedBox(height: 4),
                      Text('GORUSH50', style: TextStyle(color: Color(0xFF00C853), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Referral Code GORUSH50 copied to clipboard!'),
                          backgroundColor: Color(0xFF00C853),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.black),
                    label: const Text('Copy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'How it works:',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildReferralStep('1', 'Share code GORUSH50 with your friends.'),
            _buildReferralStep('2', 'Your friend gets ₹50 off on their first ride.'),
            _buildReferralStep('3', 'You instantly earn ₹50 wallet credits when they finish a trip!'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }

  void _showRewardsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF161C18),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Colors.amber, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'GoRush Rewards & Points',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Earn 1 point for every ₹10 spent on rides',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2310), Color(0xFF161C18)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('AVAILABLE POINTS BALANCE', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text('GOLD TIER', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.stars_rounded, color: Colors.amber, size: 36),
                      SizedBox(width: 10),
                      Text('1,250', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                      Text('pts', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Redeem Options:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRewardTile('₹100 Off Discount Voucher', '500 Points', Icons.confirmation_number_outlined),
            _buildRewardTile('Free Ride Upgrade to Premium', '800 Points', Icons.star_border_rounded),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardTile(String title, String cost, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1410),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title redeemed successfully!'),
                  backgroundColor: const Color(0xFF00C853),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(cost, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showThemeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF161C18),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('App Theme & Appearance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildThemeOption('Dark Mode (Default)', Icons.dark_mode_rounded),
            _buildThemeOption('Light Mode', Icons.light_mode_rounded),
            _buildThemeOption('System Standard Mode', Icons.brightness_auto_rounded),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon) {
    final isSelected = _selectedTheme == title;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00C853).withValues(alpha: 0.15) : const Color(0xFF0E1410),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? const Color(0xFF00C853) : Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF00C853) : Colors.white70),
        title: Text(title, style: TextStyle(color: isSelected ? const Color(0xFF00C853) : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853)) : null,
        onTap: () {
          setState(() => _selectedTheme = title);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme updated to: $title'),
              backgroundColor: const Color(0xFF00C853),
            ),
          );
        },
      ),
    );
  }

  void _showAboutModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF161C18),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
                  child: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('GoRush Customer App', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Version 2.4.0 (Build 2026)', style: TextStyle(color: Color(0xFF00C853), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'GoRush is an ultra-fast, safe, and reliable ride-hailing app built with high-concurrency PostgreSQL/SQLite database persistence, 256-bit masked contact relays, and zero-compromise emerald design.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined, color: Colors.white70),
              title: const Text('Terms of Service & Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code_rounded, color: Colors.white70),
              title: const Text('Open Source Licenses & Credits', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '© 2026 GoRush Inc. All rights reserved.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1410),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
                : RefreshIndicator(
                    color: const Color(0xFF00C853),
                    onRefresh: _loadProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Background Image Hero Header Banner
                          Stack(
                            children: [
                              // Hero Background Image Container with Gradient Overlay
                              Container(
                                height: 210,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/home_map_bg.jpg'),
                                    fit: BoxFit.cover,
                                    onError: null,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF0E1410).withValues(alpha: 0.2),
                                        const Color(0xFF0E1410).withValues(alpha: 0.85),
                                        const Color(0xFF0E1410),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),

                              // Avatar & User Profile Card
                              Padding(
                                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Avatar with Gold Tier Badge
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 36,
                                              backgroundColor: const Color(0xFF00C853).withValues(alpha: 0.2),
                                              child: const Icon(Icons.person, color: Color(0xFF00C853), size: 44),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.amber,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.star_rounded, color: Colors.black, size: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),

                                        // Profile Details Text
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    _profile?.name ?? 'John Doe',
                                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(color: Colors.amber),
                                                    ),
                                                    child: Text(
                                                      '${_profile?.memberTier ?? 'GOLD'} MEMBER',
                                                      style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _profile?.phone ?? '+91 98765 43210',
                                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                              ),
                                              Text(
                                                _profile?.email ?? 'john.doe@example.com',
                                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                                              ),
                                              if (_profile?.userId != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'DB ID: ${_profile!.userId}',
                                                  style: const TextStyle(color: Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Quick Stats Bar (Rating & Trips)
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161C18),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                              const SizedBox(width: 6),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${_profile?.rating ?? 4.92}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                                  const Text('Rating', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(width: 1, height: 24, color: Colors.white12),
                                          Row(
                                            children: [
                                              const Icon(Icons.local_taxi_rounded, color: Color(0xFF00C853), size: 20),
                                              const SizedBox(width: 6),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${_profile?.totalTrips ?? 48}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                                  const Text('Total Rides', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(width: 1, height: 24, color: Colors.white12),
                                          Row(
                                            children: [
                                              const Icon(Icons.shield_rounded, color: Color(0xFF00C853), size: 20),
                                              const SizedBox(width: 6),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Verified', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                                  const Text('Safety Badge', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section 1: Rewards & Special Offers
                          _buildSectionHeader('REWARDS & OFFERS'),
                          _buildMenuTile(
                            icon: Icons.card_giftcard_rounded,
                            title: 'Refer & Earn (Get ₹50)',
                            subtitle: 'Share code GORUSH50 & earn free ride credits',
                            iconColor: const Color(0xFF00C853),
                            onTap: _showReferralModal,
                          ),
                          _buildMenuTile(
                            icon: Icons.stars_rounded,
                            title: 'My Rewards & GoRush Points',
                            subtitle: '1,250 Points - Redeem for ride discounts',
                            iconColor: Colors.amber,
                            onTap: _showRewardsModal,
                          ),

                          const SizedBox(height: 16),

                          // Section 2: My Rides & Payments
                          _buildSectionHeader('MY RIDES & PAYMENTS'),
                          _buildMenuTile(
                            icon: Icons.directions_car_rounded,
                            title: 'My Rides & Trip History',
                            subtitle: 'View completed bookings, receipts & rebook',
                            onTap: () => context.go('/activity'),
                          ),
                          _buildMenuTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Payment Methods & Wallet',
                            subtitle: 'Top-up wallet balance, saved cards & UPI',
                            onTap: () => context.push('/wallet'),
                          ),
                          _buildMenuTile(
                            icon: Icons.place_outlined,
                            title: 'Saved Places',
                            subtitle: 'Home, Work & Favorite Dropoff Locations',
                            onTap: () => context.go('/home'),
                          ),

                          const SizedBox(height: 16),

                          // Section 3: Safety & Support
                          _buildSectionHeader('SUPPORT & SAFETY'),
                          _buildMenuTile(
                            icon: Icons.support_agent_rounded,
                            title: 'Help & Support Center',
                            subtitle: '24/7 Live chat, helpline & FAQ guide',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SupportScreen(userRepository: _userRepo),
                                ),
                              );
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.health_and_safety_outlined,
                            title: 'Safety Toolkit & SOS Relay',
                            subtitle: 'Emergency contacts, PIN safety & 112 helpline',
                            onTap: () => context.go('/safety'),
                          ),

                          const SizedBox(height: 16),

                          // Section 4: Preferences & App Settings
                          _buildSectionHeader('PREFERENCES & APP SETTINGS'),
                          _buildMenuTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile Details',
                            subtitle: 'Name, Email, Phone & Emergency Contacts',
                            onTap: () {
                              if (_profile != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      userRepository: _userRepo,
                                      initialProfile: _profile!,
                                      onProfileUpdated: _loadProfile,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.dark_mode_rounded,
                            title: 'Theme Appearance',
                            subtitle: 'Current: $_selectedTheme',
                            iconColor: Colors.lightBlueAccent,
                            onTap: _showThemeModal,
                          ),
                          _buildMenuTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notification Preferences',
                            subtitle: 'Push, SMS, promo deals & sound alerts',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationSettingsScreen(userRepository: _userRepo),
                                ),
                              );
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.security_rounded,
                            title: 'Privacy & Data Controls',
                            subtitle: 'GPS access, live trip sharing & data export',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PrivacySettingsScreen(userRepository: _userRepo),
                                ),
                              );
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.info_outline_rounded,
                            title: 'About GoRush App',
                            subtitle: 'Version v2.4.0, terms & legal credits',
                            iconColor: Colors.white70,
                            onTap: _showAboutModal,
                          ),

                          const SizedBox(height: 16),

                          // Section 5: Account Actions
                          _buildSectionHeader('ACCOUNT ACTIONS'),
                          _buildMenuTile(
                            icon: Icons.logout_rounded,
                            title: 'Log Out',
                            subtitle: 'Sign out of your GoRush account',
                            iconColor: Colors.amber,
                            titleColor: Colors.amber,
                            onTap: () {
                              HttpUserRepository.clearActiveUser();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logged out successfully'),
                                  backgroundColor: Colors.black87,
                                ),
                              );
                              context.go('/auth/welcome');
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.delete_forever_rounded,
                            title: 'Delete Account Request',
                            subtitle: '30-day grace period account termination',
                            iconColor: Colors.redAccent,
                            titleColor: Colors.redAccent,
                            onTap: () => DeleteAccountSheet.show(context, userRepository: _userRepo),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF00C853),
    Color titleColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161C18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(title, style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
      ),
    );
  }
}
