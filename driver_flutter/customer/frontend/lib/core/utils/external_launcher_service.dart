import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLauncherService {
  /// Launches an external HTTPS URL.
  /// Handles platform-specific behavior for Web, Android, and iOS.
  static Future<bool> launchExternalUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    try {
      if (kIsWeb) {
        // On web, launchUrl handles opening in a new tab/window
        return await launchUrl(url);
      } else {
        // On mobile, externalApplication ensures we leave the app
        // and try to open the native app or fallback to browser.
        // We skip canLaunchUrl check because it can return false for http(s)
        // on Android 11+ unless <queries> are configured in AndroidManifest.xml.
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        return launched;
      }
    } catch (e) {
      debugPrint('Error launching $url: $e');
      return false;
    }
  }
}
