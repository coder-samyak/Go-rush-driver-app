import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/tokens.dart';

class GoRushSearchField extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;

  const GoRushSearchField({
    super.key,
    required this.hintText,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GoRushRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md, vertical: GoRushSpacing.md),
        decoration: BoxDecoration(
          color: GoRushColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GoRushRadius.md),
          border: Border.all(color: GoRushColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: GoRushColors.primary, size: 22),
            const SizedBox(width: GoRushSpacing.sm),
            Expanded(
              child: Text(
                hintText,
                style: GoRushTypography.title.copyWith(color: GoRushColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
