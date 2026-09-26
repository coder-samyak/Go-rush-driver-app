import 'package:flutter/foundation.dart';

class DeviceSessionManager {
  Future<String> getDeviceId() async {
    // Abstraction for unique device identifier
    return 'mock-device-id-1234';
  }

  Future<Map<String, dynamic>> getSessionMetadata() async {
    return {
      'os': defaultTargetPlatform.name,
      'app_version': '1.0.0',
    };
  }
}
