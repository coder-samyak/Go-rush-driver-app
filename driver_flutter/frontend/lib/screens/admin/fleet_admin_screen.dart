import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/safe_avatar.dart';
import '../../widgets/app_bottom_nav.dart';

class FleetAdminOperationsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(int)? onBottomNavTap;

  const FleetAdminOperationsScreen({super.key, this.onBack, this.onBottomNavTap});

  @override
  State<FleetAdminOperationsScreen> createState() => _FleetAdminOperationsScreenState();
}

class _FleetAdminOperationsScreenState extends State<FleetAdminOperationsScreen> {
  int _selectedFleetTab = 0;

  final List<Map<String, dynamic>> _drivers = [
    {
      'name': 'Rohit Sharma',
      'phone': '+91 81224 367641',
      'vehicle': 'Toyota Etios (DL 01 AB 1234)',
      'status': 'Active',
      'rating': '4.8 ★',
      'avatar': 'assets/captain_aman.jpg',
    },
    {
      'name': 'Amit Singh',
      'phone': '+91 98111 22334',
      'vehicle': 'Maruti Dzire (DL 04 CD 5678)',
      'status': 'Active',
      'rating': '4.9 ★',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
    {
      'name': 'Vikram Rao',
      'phone': '+91 98222 33445',
      'vehicle': 'Hyundai Aura (UP 16 XY 9012)',
      'status': 'Pending',
      'rating': '--',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
    {
      'name': 'Sandeep Yadav',
      'phone': '+91 98333 44556',
      'vehicle': 'Toyota Innova (HR 26 AB 3456)',
      'status': 'Active',
      'rating': '4.7 ★',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile phone layout matching Phone 24
        return Scaffold(
          backgroundColor: QuickServeColors.surfaceLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
              onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Fleet Management',
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
                        // 4 Metrics Grid (Phone 24: Total Drivers 124, Active 98, Pending 12, Vehicles 110)
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Drivers',
                                value: '124',
                                icon: Icons.people_alt_outlined,
                                color: QuickServeColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Active Drivers',
                                value: '98',
                                icon: Icons.check_circle_outline,
                                color: QuickServeColors.statusGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Pending Approval',
                                value: '12',
                                icon: Icons.hourglass_top_rounded,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Vehicles',
                                value: '110',
                                icon: Icons.directions_car_outlined,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section Title: Fleet Actions
                        const Text(
                          'Fleet Operations',
                          style: TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildActionTile(
                          icon: Icons.map_outlined,
                          title: 'Driver Roster & Live Tracking',
                          subtitle: 'View live GPS locations of all 98 active drivers',
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _buildActionTile(
                          icon: Icons.verified_user_outlined,
                          title: 'Driver Onboarding Approvals',
                          subtitle: '12 new partner applications awaiting document review',
                          badge: '12 New',
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _buildActionTile(
                          icon: Icons.car_repair_outlined,
                          title: 'Vehicle Maintenance & Compliance',
                          subtitle: 'Insurance, fitness certificates and PUC tracking',
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _buildActionTile(
                          icon: Icons.bar_chart_outlined,
                          title: 'Revenue & Commission Analytics',
                          subtitle: 'Fleet weekly revenue: ₹4,82,400 (Settled)',
                          onTap: () {},
                        ),

                        const SizedBox(height: 20),

                        // Drivers Roster Preview
                        const Text(
                          'Top Performing Drivers',
                          style: TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: QuickServeColors.borderLight),
                          ),
                          child: Column(
                            children: _drivers.map((driver) {
                              return Column(
                                children: [
                                  ListTile(
                                    leading: SafeAvatar(
                                      imageUrl: driver['avatar'] as String,
                                      radius: 20,
                                      fallbackText: (driver['name'] as String).substring(0, 1),
                                    ),
                                    title: Text(
                                      driver['name'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      driver['vehicle'] as String,
                                      style: const TextStyle(fontSize: 12, color: QuickServeColors.textSecondary),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: driver['status'] == 'Active'
                                            ? QuickServeColors.statusGreenLight
                                            : QuickServeColors.statusAmberLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        driver['status'] as String,
                                        style: TextStyle(
                                          color: driver['status'] == 'Active'
                                              ? QuickServeColors.statusGreen
                                              : QuickServeColors.statusAmber,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (driver != _drivers.last)
                                    const Divider(height: 1, color: QuickServeColors.borderLight),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 5-Tab Fleet Bottom Navigation (Phone 24)
                AppBottomNav(
                  isFleetMode: true,
                  currentIndex: _selectedFleetTab,
                  onTap: (idx) {
                    setState(() => _selectedFleetTab = idx);
                    if (widget.onBottomNavTap != null) {
                      widget.onBottomNavTap!(idx);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: QuickServeColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: QuickServeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: QuickServeColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: QuickServeColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: QuickServeColors.statusAmberLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: QuickServeColors.statusAmber, width: 0.8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: QuickServeColors.statusAmber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: QuickServeColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
