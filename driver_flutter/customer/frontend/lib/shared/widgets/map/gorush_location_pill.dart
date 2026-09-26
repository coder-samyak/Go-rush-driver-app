import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

class GoRushLocationPill extends StatelessWidget {
  final VoidCallback onTap;

  const GoRushLocationPill({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GoRushRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md, vertical: GoRushSpacing.sm),
        decoration: BoxDecoration(
          color: GoRushColors.surface,
          borderRadius: BorderRadius.circular(GoRushRadius.pill),
          boxShadow: const [
            BoxShadow(
              color: GoRushColors.border,
              offset: Offset(0, 2),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.my_location, color: GoRushColors.primary, size: 18),
            const SizedBox(width: GoRushSpacing.sm),
            Text('Current Location', style: GoRushTypography.label.copyWith(color: GoRushColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
