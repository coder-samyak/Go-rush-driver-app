import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/tokens.dart';

class GoRushButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const GoRushButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSecondary ? GoRushColors.surfaceElevated : GoRushColors.primary;
    final fgColor = isSecondary ? GoRushColors.textPrimary : GoRushColors.surface;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: GoRushElevation.none,
          padding: const EdgeInsets.symmetric(vertical: GoRushSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GoRushRadius.md),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Text(
                label,
                style: GoRushTypography.title.copyWith(color: fgColor),
              ),
      ),
    );
  }
}
