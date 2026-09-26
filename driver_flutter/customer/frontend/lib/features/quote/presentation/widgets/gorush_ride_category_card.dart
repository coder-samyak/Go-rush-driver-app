import 'package:flutter/material.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/tokens.dart';
import '../../../../shared/theme/typography.dart';

class GoRushRideCategoryCard extends StatelessWidget {
  final String title;
  final String capacity;
  final String eta;
  final String fare;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const GoRushRideCategoryCard({
    super.key,
    required this.title,
    required this.capacity,
    required this.eta,
    required this.fare,
    this.isSelected = false,
    required this.onTap,
    this.icon = Icons.directions_car,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GoRushRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? GoRushColors.primaryContainer.withValues(alpha: 0.5) : GoRushColors.surface,
          border: Border.all(
            color: isSelected ? GoRushColors.primary : GoRushColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(GoRushRadius.md),
        ),
        padding: const EdgeInsets.all(GoRushSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? GoRushColors.primary : GoRushColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : GoRushColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: GoRushSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoRushTypography.title.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: GoRushColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(capacity, style: GoRushTypography.caption),
                      const SizedBox(width: GoRushSpacing.sm),
                      Text('• $eta', style: GoRushTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              fare,
              style: GoRushTypography.title.copyWith(
                color: isSelected ? GoRushColors.primary : GoRushColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
