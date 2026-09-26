import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl.replaceFirst(RegExp(r'/$'), '');
    }
    // The customer app uses the same Node/Mongo API as the driver app.
    if (kIsWeb) return 'http://localhost:5000/api/v1';
    return 'http://192.168.1.15:5000/api/v1';
  }
}
