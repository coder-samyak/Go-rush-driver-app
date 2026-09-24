import 'package:flutter/material.dart';
import '../core/maps_provider.dart';
import '../core/theme.dart';

/// Standalone map opened from the dashboard Navigation shortcut.
/// It deliberately contains no ride-request or trip controls.
class NavigationMapScreen extends StatelessWidget {
  final VoidCallback? onBackTap;

  const NavigationMapScreen({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
                      onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Navigation',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: QuickServeColors.borderLight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: const LightNavigationMapView(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
