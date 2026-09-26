import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'tokens.dart';

class GoRushTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: GoRushColors.background,
      primaryColor: GoRushColors.primary,
      fontFamily: GoRushTypography.fontFamily,
      
      colorScheme: const ColorScheme.light(
        primary: GoRushColors.primary,
        onPrimary: GoRushColors.surface,
        secondary: GoRushColors.accent,
        onSecondary: GoRushColors.surface,
        surface: GoRushColors.surface,
        onSurface: GoRushColors.textPrimary,
        error: GoRushColors.error,
        onError: GoRushColors.surface,
      ),

      textTheme: const TextTheme(
        displayLarge: GoRushTypography.display,
        headlineLarge: GoRushTypography.headline,
        titleLarge: GoRushTypography.title,
        bodyLarge: GoRushTypography.body,
        labelLarge: GoRushTypography.label,
        bodySmall: GoRushTypography.caption,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GoRushColors.primary,
          foregroundColor: GoRushColors.surface,
          elevation: GoRushElevation.none,
          padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.lg, vertical: GoRushSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GoRushRadius.md),
          ),
          textStyle: GoRushTypography.title.copyWith(color: GoRushColors.surface),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GoRushColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md, vertical: GoRushSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoRushRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoRushRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoRushRadius.md),
          borderSide: const BorderSide(color: GoRushColors.primary, width: 2),
        ),
        hintStyle: GoRushTypography.body.copyWith(color: GoRushColors.textMuted),
      ),
    );
  }
}
