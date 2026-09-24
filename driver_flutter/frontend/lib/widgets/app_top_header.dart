import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'safe_avatar.dart';

class AppTopHeader extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onToggleOnline;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;
  final bool showBack;
  final String title;

  const AppTopHeader({
    super.key,
    this.isOnline = true,
    this.onToggleOnline,
    this.onProfileTap,
    this.onNotificationTap,
    this.onBackTap,
    this.showBack = false,
    this.title = 'PARTNER FLEET\nRadar',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: GoRushColors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBack)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: GoRushColors.textWhite, size: 18),
                onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            // Logo / Title
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: GoRushColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GoRushColors.surfaceBorder),
              ),
              child: const Center(
                child: Icon(Icons.navigation, color: GoRushColors.primaryGreen, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PARTNER FLEET',
                  style: TextStyle(
                    color: GoRushColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  title.contains('\n') ? title.split('\n')[1] : 'Radar',
                  style: const TextStyle(
                    color: GoRushColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Online / Offline Status Badge
            GestureDetector(
              onTap: onToggleOnline,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0x2200E676) : const Color(0x2264748B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOnline ? GoRushColors.primaryGreen : GoRushColors.textMuted,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isOnline ? GoRushColors.primaryGreen : GoRushColors.textMuted,
                        shape: BoxShape.circle,
                        boxShadow: isOnline
                            ? [
                                BoxShadow(
                                  color: GoRushColors.primaryGreen.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        color: isOnline ? GoRushColors.primaryGreen : GoRushColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Notifications Bell Button
            if (onNotificationTap != null) ...[
              GestureDetector(
                onTap: onNotificationTap,
                child: Stack(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: GoRushColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GoRushColors.surfaceBorder),
                      ),
                      child: const Center(
                        child: Icon(Icons.notifications_none, color: GoRushColors.textWhite, size: 18),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: GoRushColors.orangeAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
            // Profile Icon Button
            GestureDetector(
              onTap: onProfileTap,
              child: const SafeAvatar(
                size: 34,
                initials: 'RV',
                imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
