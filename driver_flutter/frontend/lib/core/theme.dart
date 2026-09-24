import 'package:flutter/material.dart';

class QuickServeColors {
  // Brand Identity Palette — Royal Cobalt Blue & Vibrant Green (Exact Theme From Reference Image)
  // Kept primaryOrange alias for 100% backward compatibility across all existing files
  static const Color primaryOrange = Color(0xFF2563EB); // Royal Cobalt Blue — #2563EB (Primary CTAs & Brand)
  static const Color primaryOrangeDark = Color(0xFF1D4ED8); // Deep Cobalt Blue — #1D4ED8
  static const Color primaryOrangeLight = Color(0xFFEFF6FF); // Soft Blue Tint — #EFF6FF
  static const Color primaryOrangeBorder = Color(0xFFBFDBFE); // Soft Blue Border — #BFDBFE

  // Semantic Brand Color Names
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Cobalt Blue — #2563EB
  static const Color primaryCobalt = Color(0xFF1E40AF); // Deep Cobalt — #1E40AF
  static const Color accentGreen = Color(0xFF22C55E); // Vibrant Green — #22C55E (Online & Checkmarks)
  static const Color darkNavy = Color(0xFF0D1B3E); // Deep Midnight Navy — #0D1B3E (Splash & Dark BG)

  // Dark Foundations (for Splash, Map Accents & Admin Web Sidebar)
  static const Color darkBg = Color(0xFF0D1B3E); // Deep Midnight Navy — #0D1B3E
  static const Color darkCard = Color(0xFF162A56); // Deep Navy Card
  static const Color adminSidebar = Color(0xFF0D1B3E); // Deep Midnight Navy — #0D1B3E
  static const Color adminSidebarActive = Color(0xFF162A56);

  // White Mobile Surfaces & Light Background
  static const Color white = Color(0xFFFFFFFF); // Card Background: #FFFFFF
  static const Color surfaceLight = Color(0xFFF4F7FC); // Light Background: #F4F7FC
  static const Color surfaceSecondary = Color(0xFFEDF2F7);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF0F4F8);
  static const Color inputBg = Color(0xFFF8FAFC); // Clean Input Background

  // Status & Actions
  static const Color statusGreen = Color(0xFF22C55E); // Vibrant Green from reference image
  static const Color statusGreenLight = Color(0xFFE8F8EE); // Soft Green Tint
  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusRedLight = Color(0xFFFFEBEE);
  static const Color statusAmber = Color(0xFFF59E0B);
  static const Color statusAmberLight = Color(0xFFFFFBEB);
  static const Color routeBlue = Color(0xFF2563EB); // Royal Blue Navigation Route

  // Typography
  static const Color textDark = Color(0xFF0D1B3E); // Primary Text: Deep Midnight Navy — #0D1B3E
  static const Color textSecondary = Color(0xFF64748B); // Secondary Text: Slate Grey — #64748B
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);
}

typedef QuickServiceColors = QuickServeColors;

// Backward-compatibility alias so existing screens work seamlessly while adopting QuickServe's palette
class GoRushColors {
  static const Color background = QuickServeColors.surfaceLight;
  static const Color surface = QuickServeColors.white;
  static const Color surfaceCard = QuickServeColors.white;
  static const Color surfaceElevated = QuickServeColors.surfaceLight;
  static const Color surfaceBorder = QuickServeColors.borderLight;
  static const Color surfaceInput = QuickServeColors.inputBg;

  static const Color primaryGreen = QuickServeColors.primaryOrange;
  static const Color accentGreen = QuickServeColors.statusGreen;
  static const Color darkGreen = QuickServeColors.primaryOrangeDark;
  static const Color greenTint = QuickServeColors.statusGreenLight;
  static const Color greenBorder = QuickServeColors.primaryOrangeBorder;

  static const Color gold = QuickServeColors.statusAmber;
  static const Color goldDark = Color(0xFFD97706);
  static const Color goldTint = QuickServeColors.statusAmberLight;

  static const Color sosRed = QuickServeColors.statusRed;
  static const Color sosRedDark = Color(0xFFDC2626);
  static const Color sosRedTint = QuickServeColors.statusRedLight;

  static const Color blueAccent = QuickServeColors.primaryOrange;
  static const Color blueDark = QuickServeColors.primaryOrangeDark;
  static const Color blueTint = QuickServeColors.primaryOrangeLight;

  static const Color orangeAccent = QuickServeColors.primaryOrange;
  static const Color orangeTint = QuickServeColors.primaryOrangeLight;

  static const Color textWhite = QuickServeColors.textDark;
  static const Color textPrimary = QuickServeColors.textDark;
  static const Color textSecondary = QuickServeColors.textSecondary;
  static const Color textMuted = QuickServeColors.textMuted;
  static const Color textOnPrimary = QuickServeColors.textWhite;
}

class QuickServeTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: QuickServeColors.surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: QuickServeColors.primaryOrange,
        secondary: QuickServeColors.statusGreen,
        surface: QuickServeColors.white,
        error: QuickServeColors.statusRed,
        onPrimary: QuickServeColors.textWhite,
        onSurface: QuickServeColors.textDark,
      ),
      cardTheme: CardThemeData(
        color: QuickServeColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: QuickServeColors.borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QuickServeColors.primaryOrange,
          foregroundColor: QuickServeColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QuickServeColors.textDark,
          side: const BorderSide(color: QuickServeColors.borderLight, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QuickServeColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: QuickServeColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: QuickServeColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: QuickServeColors.primaryOrange, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: QuickServeColors.darkNavy,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class GoRushTheme {
  static ThemeData get darkTheme => QuickServeTheme.lightTheme;
}
