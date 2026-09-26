import 'package:flutter/material.dart';
import 'gorush_colors.dart';
import 'gorush_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: GoRushColors.brand,
      scaffoldBackgroundColor: GoRushColors.background,
      colorScheme: const ColorScheme.light(
        primary: GoRushColors.brand,
        secondary: GoRushColors.charcoal,
        surface: GoRushColors.surface,
        error: GoRushColors.error,
      ),
      textTheme: const TextTheme(
        displayLarge: GoRushTypography.display,
        headlineMedium: GoRushTypography.heading,
        titleLarge: GoRushTypography.title,
        bodyLarge: GoRushTypography.body,
        bodyMedium: GoRushTypography.bodyMedium,
        labelLarge: GoRushTypography.label,
        bodySmall: GoRushTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GoRushColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: GoRushColors.charcoal),
        titleTextStyle: GoRushTypography.title,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GoRushColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GoRushColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GoRushColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GoRushColors.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GoRushColors.error),
        ),
        labelStyle: GoRushTypography.body.copyWith(color: GoRushColors.textSecondary),
        hintStyle: GoRushTypography.body.copyWith(color: GoRushColors.textMuted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GoRushColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
