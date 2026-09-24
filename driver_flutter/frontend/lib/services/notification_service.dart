import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Lightweight notification service using the Android notification channel
/// via a MethodChannel. No third-party plugin required.
///
/// For a richer experience (heads-up, persistent), this sends a notification
/// through the platform channel. Requires POST_NOTIFICATIONS permission on
/// Android 13+ (already handled in AndroidManifest via the existing setup).
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  static const _channel = MethodChannel('com.gorush.driver/notifications');

  static const int _onlineNotifId = 1001;
  static const int _offlineNotifId = 1002;

  /// Show a heads-up notification for going online / offline.
  Future<void> showOnlineStatusNotification({required bool isOnline}) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'id': isOnline ? _onlineNotifId : _offlineNotifId,
        'title': isOnline ? '🟢 GoRush Driver – You are Online' : '🔴 GoRush Driver – You are Offline',
        'body': isOnline
            ? 'Looking for ride requests. Keep the app open to receive requests.'
            : 'You will not receive new ride requests while offline.',
        'channelId': 'gorush_driver_status',
        'channelName': 'Driver Status Alerts',
        'importance': 4, // HIGH
      });
    } on PlatformException catch (e) {
      debugPrint('[NotificationService] showNotification error: $e');
    } on MissingPluginException {
      // Platform channel not implemented (web/desktop) - silently skip
      debugPrint('[NotificationService] Platform channel not available — notification skipped.');
    }
  }
}
