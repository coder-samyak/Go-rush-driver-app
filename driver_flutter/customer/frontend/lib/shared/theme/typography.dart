import 'package:flutter/material.dart';
import 'colors.dart';

class GoRushTypography {
  static const String fontFamily = 'Inter'; // Standard clean mobility font placeholder

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: GoRushColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: GoRushColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: GoRushColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: GoRushColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: GoRushColors.textSecondary,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: GoRushColors.textMuted,
    height: 1.4,
  );

  // Aliases for compatibility
  static const TextStyle h2 = display;
  static const TextStyle h3 = headline;
  static const TextStyle h4 = title;
  static const TextStyle body1 = body;
  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: GoRushColors.textSecondary,
    height: 1.5,
  );
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: GoRushColors.surface,
    height: 1.4,
  );
}
