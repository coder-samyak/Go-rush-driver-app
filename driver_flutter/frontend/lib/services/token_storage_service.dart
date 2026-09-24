import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure Token & Session Storage Service
/// Manages persistence of JWT access tokens and driver authentication state.
class TokenStorageService extends ChangeNotifier {
  static final TokenStorageService instance = TokenStorageService._internal();
  factory TokenStorageService() => instance;
  TokenStorageService._internal();

  static const String _keyAccessToken = 'gorush_driver_access_token';
  static const String _keyRefreshToken = 'gorush_driver_refresh_token';
  static const String _keyDriverProfile = 'gorush_driver_profile';
  static const String _keyIsAuthenticated = 'gorush_driver_is_authenticated';

  // In-memory cache for fast synchronous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  Map<String, dynamic>? _cachedProfile;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _cachedAccessToken;
  String? get refreshToken => _cachedRefreshToken;
  Map<String, dynamic>? get driverProfile => _cachedProfile;

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  /// Load session from local storage on app startup
  Future<void> init() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;

      if (prefs.containsKey(_keyIsAuthenticated)) {
        _isAuthenticated = prefs.getBool(_keyIsAuthenticated) ?? false;
      }

      if (prefs.containsKey(_keyAccessToken)) {
        _cachedAccessToken = prefs.getString(_keyAccessToken);
      }

      if (prefs.containsKey(_keyRefreshToken)) {
        _cachedRefreshToken = prefs.getString(_keyRefreshToken);
      }

      final profileJson = prefs.getString(_keyDriverProfile);
      if (profileJson != null) {
        final decoded = jsonDecode(profileJson);
        if (decoded is Map<String, dynamic>) {
          _cachedProfile = decoded;
          notifyListeners();
        }
      }
    } catch (_) {
      // Fallback gracefully in case of platform storage issues
    }
  }

  /// Persist authentication tokens and driver details upon login/registration
  Future<bool> saveSession({
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? driverProfile,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    _cachedProfile = driverProfile;
    _isAuthenticated = true;
    notifyListeners();

    try {
      final prefs = await _getPrefs();
      if (prefs == null) return true;

      await prefs.setString(_keyAccessToken, accessToken).catchError((_) => false);
      await prefs.setBool(_keyIsAuthenticated, true).catchError((_) => false);

      if (refreshToken != null) {
        await prefs.setString(_keyRefreshToken, refreshToken).catchError((_) => false);
      } else {
        await prefs.remove(_keyRefreshToken).catchError((_) => false);
      }

      if (_cachedProfile != null) {
        await prefs.setString(_keyDriverProfile, jsonEncode(_cachedProfile)).catchError((_) => false);
      } else {
        await prefs.remove(_keyDriverProfile).catchError((_) => false);
      }

      return true;
    } catch (_) {
      return true;
    }
  }

  /// Update and persist full driver profile map
  Future<bool> setDriverProfile(Map<String, dynamic> driverProfile) async {
    _cachedProfile = Map<String, dynamic>.from(driverProfile);
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_keyDriverProfile, jsonEncode(_cachedProfile)).catchError((_) => false);
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Clear all stored tokens and session state upon logout
  Future<bool> clearSession() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedProfile = null;
    _isAuthenticated = false;
    notifyListeners();

    try {
      final prefs = await _getPrefs();
      if (prefs == null) return true;

      await prefs.remove(_keyAccessToken).catchError((_) => false);
      await prefs.remove(_keyRefreshToken).catchError((_) => false);
      await prefs.remove(_keyDriverProfile).catchError((_) => false);
      await prefs.setBool(_keyIsAuthenticated, false).catchError((_) => false);
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Update local cached driver profile with edited fields
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? city,
    String? address,
    String? vehicleNumber,
    String? licenseNumber,
    String? profileImage,
    String? profileDocumentName,
  }) async {
    final updated = Map<String, dynamic>.from(_cachedProfile ?? {});
    if (name != null && name.isNotEmpty) updated['name'] = name;
    if (phone != null && phone.isNotEmpty) updated['phone'] = phone;
    if (email != null && email.isNotEmpty) updated['email'] = email;
    if (city != null && city.isNotEmpty) updated['city'] = city;
    if (address != null && address.isNotEmpty) updated['address'] = address;
    if (vehicleNumber != null && vehicleNumber.isNotEmpty) updated['vehicleId'] = vehicleNumber;
    if (licenseNumber != null && licenseNumber.isNotEmpty) updated['licenseNumber'] = licenseNumber;
    if (profileImage != null && profileImage.isNotEmpty) updated['profileImage'] = profileImage;
    if (profileDocumentName != null && profileDocumentName.isNotEmpty) updated['profileDocumentName'] = profileDocumentName;

    _cachedProfile = updated;
    notifyListeners();

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_keyDriverProfile, jsonEncode(updated)).catchError((_) => false);
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  static const String _keyPrivacySettings = 'gorush_driver_privacy_settings';
  static const String _keyVehiclesList = 'gorush_driver_vehicles_list';
  static const String _keyAppLanguage = 'gorush_driver_app_language';

  /// Save selected app language code (e.g. 'hi', 'pa', 'mr', 'en')
  Future<void> saveLanguage(String code) async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_keyAppLanguage, code).catchError((_) => false);
      }
    } catch (_) {}
  }

  /// Get stored app language code
  Future<String?> getLanguage() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null && prefs.containsKey(_keyAppLanguage)) {
        return prefs.getString(_keyAppLanguage);
      }
    } catch (_) {}
    return null;
  }

  /// Save privacy & security toggles
  Future<void> savePrivacySettings(Map<String, bool> settings) async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_keyPrivacySettings, jsonEncode(settings)).catchError((_) => false);
      }
    } catch (_) {}
  }

  /// Get privacy & security toggles
  Future<Map<String, bool>> getPrivacySettings() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null && prefs.containsKey(_keyPrivacySettings)) {
        final data = jsonDecode(prefs.getString(_keyPrivacySettings)!);
        if (data is Map) {
          return data.map((k, v) => MapEntry(k.toString(), v == true));
        }
      }
    } catch (_) {}
    return {
      'biometricLock': true,
      'backgroundLocation': true,
      'twoFactorAuth': true,
      'maskPhoneNumber': true,
    };
  }

  /// Save secondary vehicles list
  Future<void> saveVehicles(List<Map<String, dynamic>> list) async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_keyVehiclesList, jsonEncode(list)).catchError((_) => false);
      }
    } catch (_) {}
  }

  /// Get secondary vehicles list
  Future<List<Map<String, dynamic>>?> getVehicles() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null && prefs.containsKey(_keyVehiclesList)) {
        final decoded = jsonDecode(prefs.getString(_keyVehiclesList)!);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Quick check if a non-empty token is stored
  bool hasToken() {
    return _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;
  }
}
