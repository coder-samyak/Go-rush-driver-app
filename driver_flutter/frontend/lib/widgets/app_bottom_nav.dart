import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/app_language_service.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback? onSosTap;
  final VoidCallback? onMenuTap;
  final bool showSosBadge;
  final bool isFleetNav;

  const AppBottomNav({
    super.key,
    int? selectedIndex,
    int? currentIndex,
    Function(int)? onTabSelected,
    Function(int)? onTap,
    this.onSosTap,
    this.onMenuTap,
    this.showSosBadge = false,
    bool isFleetNav = false,
    bool isFleetMode = false,
  })  : selectedIndex = selectedIndex ?? currentIndex ?? 0,
        onTabSelected = onTabSelected ?? onTap ?? _noop,
        isFleetNav = isFleetNav || isFleetMode;

  static void _noop(int _) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: QuickServeColors.white,
        border: Border(top: BorderSide(color: QuickServeColors.borderLight, width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: isFleetNav ? _buildFleetRow() : _buildDriverRow(),
        ),
      ),
    );
  }

  Widget _buildDriverRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(0, Icons.home_outlined, Icons.home, tr('Home')),
        _buildNavItem(1, Icons.directions_car_outlined, Icons.directions_car, tr('Rides')),
        _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, tr('Earnings')),
        _buildNavItem(3, Icons.card_giftcard_outlined, Icons.card_giftcard, tr('Incentives')),
        _buildNavItem(4, Icons.person_outline, Icons.person, tr('Profile')),
      ],
    );
  }

  Widget _buildFleetRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(0, Icons.home_outlined, Icons.home, tr('Home')),
        _buildNavItem(1, Icons.people_outline, Icons.people, tr('Drivers')),
        _buildNavItem(2, Icons.directions_car_outlined, Icons.directions_car, tr('Vehicles')),
        _buildNavItem(3, Icons.bar_chart_outlined, Icons.bar_chart, tr('Reports')),
        _buildNavItem(4, Icons.person_outline, Icons.person, tr('Profile')),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        onLongPress: onMenuTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              size: 22,
              color: isSelected ? QuickServeColors.statusGreen : QuickServeColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? QuickServeColors.statusGreen : QuickServeColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
