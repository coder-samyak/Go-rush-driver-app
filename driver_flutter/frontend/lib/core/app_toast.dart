import 'package:flutter/material.dart';
import 'theme.dart';

/// Centralized Toast and SnackBar Helper for GoRush Driver App
/// Enforces brief 1.8-second duration, immediate clearing of prior popups,
/// and non-blocking floating presentation that never overlaps bottom navigation.
class AppToast {
  static const Duration defaultDuration = Duration(milliseconds: 1800);

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    // Immediately dismiss any existing popups to prevent stacking
    ScaffoldMessenger.of(context).clearSnackBars();

    final Color bgColor = isError
        ? QuickServeColors.statusRed
        : isSuccess
            ? QuickServeColors.statusGreen
            : QuickServeColors.darkNavy;

    final IconData icon = isError
        ? Icons.error_outline_rounded
        : isSuccess
            ? Icons.check_circle_outline_rounded
            : Icons.info_outline_rounded;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: action,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void info(BuildContext context, String message) {
    show(context, message);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }

  static void showError(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message);
  }
}
