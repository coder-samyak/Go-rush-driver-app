import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage_service.dart';

/// Standard result object for authentication operations
class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? driver;
  final int? statusCode;

  const AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.driver,
    this.statusCode,
  });

  bool get isSuccess => success;

  factory AuthResult.success({
    required String message,
    String? token,
    Map<String, dynamic>? driver,
    int? statusCode,
  }) {
    return AuthResult(
      success: true,
      message: message,
      token: token,
      driver: driver,
      statusCode: statusCode ?? 200,
    );
  }

  factory AuthResult.failure({
    required String message,
    int? statusCode,
  }) {
    return AuthResult(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

/// Authentication API Service
/// Handles registration, login, profile retrieval, and health checks against the Node.js backend.
class AuthApiService {
  static final AuthApiService instance = AuthApiService._internal();
  factory AuthApiService() => instance;
  AuthApiService._internal();

  final http.Client _httpClient = http.Client();
  final TokenStorageService _tokenStorage = TokenStorageService.instance;

  /// Helper to safely parse JSON responses
  Map<String, dynamic>? _tryParseJson(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  Duration _timeoutForCandidate(String base) {
    // Cloudflare tunnel / HTTPS remote API — generous cold-start timeout
    if (base.startsWith('https://')) return const Duration(seconds: 30);
    // LAN / emulator — backend uses MongoDB Atlas so needs 15–20 s on slow Wi-Fi
    if (base.contains('localhost') ||
        base.contains('127.0.0.1') ||
        base.contains('10.0.2.2')) {
      return const Duration(seconds: 20);
    }
    // Physical device over local Wi-Fi (LAN IP)
    return const Duration(seconds: 20);
  }

  /// Send POST request with automatic retry across candidates.
  /// Retries up to [maxAttempts] times to handle Cloudflare tunnel cold-starts
  /// and intermittent connectivity hiccups — eliminating the "Connection Timeout"
  /// registration failure the driver sees when the tunnel is slow to respond.
  Future<http.Response> _postWithFallback(
    String endpoint,
    Map<String, dynamic> payload, {
    String? token,
    int maxAttempts = 3,
  }) async {
    final candidateUrls = ApiConfig.candidateBaseUrls;
    Object? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        debugPrint('[AuthApi] 🔄 Retry attempt $attempt/$maxAttempts...');
        await Future.delayed(const Duration(seconds: 2));
      }
      for (final base in candidateUrls) {
        final url = Uri.parse('$base$endpoint');
        try {
          debugPrint('[AuthApi] 🚀 Attempting POST to: $url (attempt $attempt)');
          final response = await _httpClient
              .post(
                url,
                headers: ApiConfig.getHeaders(token: token),
                body: jsonEncode(payload),
              )
              .timeout(_timeoutForCandidate(base));

          final parsed = _tryParseJson(response.body);
          if (parsed != null) {
            debugPrint(
                '[AuthApi] ✅ Response from $url (Status: ${response.statusCode})');
            ApiConfig.customBaseUrl = base;
            return response;
          } else {
            debugPrint(
                '[AuthApi] ⚠️ Non-JSON response from $url (Status: ${response.statusCode})');
            lastError = Exception('Non-JSON response from server ($url)');
          }
        } catch (err) {
          debugPrint('[AuthApi] ⚠️ Failed for $url: $err');
          lastError = err;
        }
      }
    }

    if (lastError is SocketException) {
      throw lastError;
    }
    if (lastError is TimeoutException) {
      throw lastError;
    }
    throw const SocketException(
      'Unable to reach backend server. Please verify backend is running on port 5000 and internet connection is active.',
    );
  }

  /// Send GET request sequentially across candidates
  Future<http.Response> _getWithFallback(
    String endpoint, {
    String? token,
  }) async {
    final candidateUrls = ApiConfig.candidateBaseUrls;
    Object? lastError;

    for (final base in candidateUrls) {
      final url = Uri.parse('$base$endpoint');
      try {
        final response = await _httpClient
            .get(
              url,
              headers: ApiConfig.getHeaders(token: token),
            )
            .timeout(_timeoutForCandidate(base));

        final parsed = _tryParseJson(response.body);
        if (parsed != null) {
          ApiConfig.customBaseUrl = base;
          return response;
        }
      } catch (err) {
        lastError = err;
      }
    }

    if (lastError is SocketException) {
      throw lastError;
    }
    if (lastError is TimeoutException) {
      throw lastError;
    }
    throw const SocketException('Unable to reach backend on any candidate URL');
  }

  /// Send PUT request sequentially across candidates
  Future<http.Response> _putWithFallback(
    String endpoint,
    Map<String, dynamic> payload, {
    String? token,
  }) async {
    final candidateUrls = ApiConfig.candidateBaseUrls;
    Object? lastError;

    for (final base in candidateUrls) {
      final url = Uri.parse('$base$endpoint');
      try {
        final response = await _httpClient
            .put(
              url,
              headers: ApiConfig.getHeaders(token: token),
              body: jsonEncode(payload),
            )
            .timeout(_timeoutForCandidate(base));

        final parsed = _tryParseJson(response.body);
        if (parsed != null) {
          ApiConfig.customBaseUrl = base;
          return response;
        } else {
          lastError = Exception('Non-JSON response from server ($url)');
        }
      } catch (err) {
        lastError = err;
      }
    }

    if (lastError is SocketException) throw lastError;
    if (lastError is TimeoutException) throw lastError;
    throw const SocketException('Unable to reach backend on any candidate URL');
  }

  /// 1. Driver Registration API: POST /api/auth/register
  Future<AuthResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? licenseNumber,
    String? profileImage,
    String? vehicleId,
    String? dateOfBirth,
  }) async {
    final payload = {
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      if (licenseNumber != null && licenseNumber.isNotEmpty)
        'licenseNumber': licenseNumber.trim(),
      if (profileImage != null && profileImage.isNotEmpty)
        'profileImage': profileImage.trim(),
      if (vehicleId != null && vehicleId.isNotEmpty)
        'vehicleId': vehicleId.trim(),
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        'dateOfBirth': dateOfBirth,
    };

    try {
      final response =
          await _postWithFallback(ApiConfig.registerEndpoint, payload);

      final data = _tryParseJson(response.body);
      final message =
          data?['message'] as String? ?? 'Registration request completed';

      if (response.statusCode == 201 && data?['success'] == true) {
        final token = data?['data']?['token'] as String?;
        final driverData = data?['data']?['driver'] as Map<String, dynamic>?;

        if (token != null) {
          await _tokenStorage.saveSession(
            accessToken: token,
            driverProfile: driverData,
          );
        }

        return AuthResult.success(
          message: message,
          token: token,
          driver: driverData,
          statusCode: response.statusCode,
        );
      }

      // Handle validation (400), conflict (409), or server errors (500/503)
      return AuthResult.failure(
        message: message,
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return AuthResult.failure(
        message:
            'Server is taking too long to respond. Please tap Register again — it will retry automatically.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return AuthResult.failure(
        message:
            'Cannot reach server. Check your internet connection and tap Register again. (${e.message})',
        statusCode: 503,
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Registration error. Please try again. (${e.toString()})',
      );
    }
  }

  /// 2. Driver Login API: POST /api/auth/login
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    try {
      final response =
          await _postWithFallback(ApiConfig.loginEndpoint, payload);

      final data = _tryParseJson(response.body);
      final message = data?['message'] as String? ?? 'Login request completed';

      if (response.statusCode == 200 && data?['success'] == true) {
        final token = data?['data']?['token'] as String?;
        final driverData = data?['data']?['driver'] as Map<String, dynamic>?;

        // Persist session locally
        if (token != null) {
          await _tokenStorage.saveSession(
            accessToken: token,
            driverProfile: driverData,
          );
        }

        return AuthResult.success(
          message: message,
          token: token,
          driver: driverData,
          statusCode: response.statusCode,
        );
      }

      // Handle 401 invalid credentials, 400 validation, 403 inactive, or 500/503
      return AuthResult.failure(
        message: message,
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return AuthResult.failure(
        message: 'Connection timed out. Please check your backend connection.',
        statusCode: 408,
      );
    } on SocketException {
      return AuthResult.failure(
        message:
            'Cannot reach backend server. Please verify backend is running on port 5000.',
        statusCode: 503,
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// 3. Authenticated Driver Profile: GET /api/auth/me (Protected with Bearer Token)
  Future<AuthResult> getAuthenticatedProfile() async {
    final token = _tokenStorage.accessToken;

    if (token == null || token.isEmpty) {
      return AuthResult.failure(
        message: 'No active authentication session found.',
        statusCode: 401,
      );
    }

    try {
      final response =
          await _getWithFallback(ApiConfig.meEndpoint, token: token);

      final data = _tryParseJson(response.body);
      final message = data?['message'] as String? ?? 'Profile fetch completed';

      if (response.statusCode == 200 && data?['success'] == true) {
        final driverData = data?['data']?['driver'] as Map<String, dynamic>?;
        if (driverData != null) {
          await _tokenStorage.saveSession(
            accessToken: token,
            driverProfile: driverData,
          );
        }
        return AuthResult.success(
          message: message,
          token: token,
          driver: driverData,
          statusCode: response.statusCode,
        );
      }

      // Note: Do NOT clear local session on transient 401/network issues
      // to preserve the registered driver's name, phone, and credentials.
      if (response.statusCode == 401) {
        debugPrint(
            '[AuthApi] Profile request received 401 from server: $message');
      }

      return AuthResult.failure(
        message: message,
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return AuthResult.failure(
        message: 'Connection timed out while fetching profile.',
        statusCode: 408,
      );
    } on SocketException {
      return AuthResult.failure(
        message: 'Cannot connect to backend server.',
        statusCode: 503,
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Failed to retrieve profile: ${e.toString()}',
      );
    }
  }

  /// 4. Backend & MongoDB Connectivity Health Check: GET /api/health
  Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final response = await _getWithFallback(ApiConfig.healthEndpoint);

      if (response.statusCode == 200) {
        return _tryParseJson(response.body);
      }
    } catch (_) {}
    return null;
  }

  /// 5. Change Password: POST /api/auth/change-password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    String? confirmPassword,
  }) async {
    final driver = _tokenStorage.driverProfile;
    final email = driver?['email'] as String?;
    final phone = driver?['phone'] as String?;
    final driverId = driver?['_id'] as String?;

    try {
      final payload = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        if (confirmPassword != null && confirmPassword.isNotEmpty)
          'confirmPassword': confirmPassword,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (driverId != null && driverId.isNotEmpty) 'driverId': driverId,
      };

      final response = await _postWithFallback(
        ApiConfig.changePasswordEndpoint,
        payload,
        token: _tokenStorage.accessToken,
      );

      final data = _tryParseJson(response.body);
      final message =
          data?['message'] as String? ?? 'Password update completed';

      if (response.statusCode == 200 && data?['success'] == true) {
        return AuthResult.success(
          message: message,
          statusCode: 200,
        );
      }

      return AuthResult.failure(
        message: message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthResult.failure(
        message:
            'Unable to change password. Please check your connection and try again.',
        statusCode: 503,
      );
    }
  }

  /// 6. Update Driver Profile: PUT /api/auth/profile
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? city,
    String? address,
    String? profileImage,
    String? licenseNumber,
    String? vehicleNumber,
    Map<String, bool>? privacySettings,
    Map<String, String?>? documents,
    Map<String, dynamic>? vehicleInsuranceDetails,
    Map<String, dynamic>? driverInsuranceDetails,
  }) async {
    final driver = _tokenStorage.driverProfile;
    final driverEmail = email ?? driver?['email'] as String?;
    final driverPhone = phone ?? driver?['phone'] as String?;
    final driverId = driver?['_id'] as String?;

    try {
      final payload = {
        if (name != null && name.isNotEmpty) 'name': name,
        if (driverPhone != null && driverPhone.isNotEmpty) 'phone': driverPhone,
        if (driverEmail != null && driverEmail.isNotEmpty) 'email': driverEmail,
        if (city != null) 'city': city,
        if (address != null) 'address': address,
        if (profileImage != null && profileImage.isNotEmpty)
          'profileImage': profileImage,
        if (licenseNumber != null && licenseNumber.isNotEmpty)
          'licenseNumber': licenseNumber,
        if (vehicleNumber != null && vehicleNumber.isNotEmpty)
          'vehicleId': vehicleNumber,
        if (privacySettings != null) 'privacySettings': privacySettings,
        if (documents != null) 'documents': documents,
        if (vehicleInsuranceDetails != null)
          'vehicleInsuranceDetails': vehicleInsuranceDetails,
        if (driverInsuranceDetails != null)
          'driverInsuranceDetails': driverInsuranceDetails,
        if (driverId != null && driverId.isNotEmpty) 'driverId': driverId,
      };

      final response = await _putWithFallback(
        ApiConfig.updateProfileEndpoint,
        payload,
        token: _tokenStorage.accessToken,
      );

      final data = _tryParseJson(response.body);
      final message =
          data?['message'] as String? ?? 'Profile updated successfully';

      if (response.statusCode == 200 && data?['success'] == true) {
        final updatedDriver = data?['data']?['driver'] as Map<String, dynamic>?;
        if (updatedDriver != null) {
          await _tokenStorage.saveSession(
            accessToken: _tokenStorage.accessToken ?? '',
            refreshToken: _tokenStorage.refreshToken,
            driverProfile: updatedDriver,
          );
        }
        return AuthResult.success(
          message: message,
          driver: updatedDriver,
          statusCode: 200,
        );
      }

      return AuthResult.failure(
          message: message, statusCode: response.statusCode);
    } catch (e) {
      return AuthResult.failure(
        message:
            'Unable to update profile. Please check your connection and try again.',
        statusCode: 503,
      );
    }
  }

  /// 7. Add Secondary Vehicle: POST /api/auth/vehicles
  Future<AuthResult> addVehicle({
    required String model,
    required String regNumber,
    required String type,
  }) async {
    final driver = _tokenStorage.driverProfile;
    final email = driver?['email'] as String?;
    final token = _tokenStorage.accessToken;

    final payload = {
      'model': model.trim(),
      'regNumber': regNumber.trim().toUpperCase(),
      'type': type.trim(),
      if (email != null) 'email': email,
    };

    try {
      final response = await _postWithFallback(
        ApiConfig.vehiclesEndpoint,
        payload,
        token: token,
      );

      final data = _tryParseJson(response.body);
      final message =
          data?['message'] as String? ?? 'Vehicle operation completed';

      if (response.statusCode == 201 && data?['success'] == true) {
        final vehicleData = data?['data']?['vehicle'] as Map<String, dynamic>?;
        final allVehicles = data?['data']?['vehicles'] as List<dynamic>?;
        if (allVehicles != null) {
          final mapped = allVehicles
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          await _tokenStorage.saveVehicles(mapped);
        }
        return AuthResult.success(
          message: message,
          driver: vehicleData,
          statusCode: 201,
        );
      }

      return AuthResult.failure(
        message: message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Failed to add vehicle: ${e.toString()}',
      );
    }
  }

  /// 8. Get Registered Vehicles: GET /api/auth/vehicles
  Future<List<Map<String, dynamic>>> getVehicles() async {
    final token = _tokenStorage.accessToken;
    final driver = _tokenStorage.driverProfile;
    final email = driver?['email'] as String?;

    try {
      final endpoint = email != null
          ? '${ApiConfig.vehiclesEndpoint}?email=${Uri.encodeComponent(email)}'
          : ApiConfig.vehiclesEndpoint;
      final response = await _getWithFallback(endpoint, token: token);
      final data = _tryParseJson(response.body);
      if (response.statusCode == 200 && data?['success'] == true) {
        final list = data?['data']?['vehicles'] as List<dynamic>?;
        if (list != null) {
          final mapped =
              list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          await _tokenStorage.saveVehicles(mapped);
          return mapped;
        }
      }
    } catch (_) {}

    final local = await _tokenStorage.getVehicles();
    return local ?? [];
  }
}
