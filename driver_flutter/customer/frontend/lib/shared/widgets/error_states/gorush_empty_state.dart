import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

class GoRushEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const GoRushEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GoRushSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: GoRushColors.border),
            const SizedBox(height: GoRushSpacing.md),
            Text(title, style: GoRushTypography.headline),
            const SizedBox(height: GoRushSpacing.sm),
            Text(
              message,
              style: GoRushTypography.body.copyWith(color: GoRushColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
