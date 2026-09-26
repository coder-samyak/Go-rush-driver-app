import 'package:dio/dio.dart';
import '../../../core/network/api_config.dart';
import '../../../core/security/secure_storage.dart';
import '../../../core/security/token_manager.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phoneNumber);
  Future<void> verifyOtp(String phoneNumber, String otp);
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<Map<String, dynamic>> loginWithPassword({
    required String identifier,
    required String password,
  });
  Future<void> logout();
  Future<bool> checkSession();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final TokenManager _tokenManager;

  AuthRepositoryImpl({Dio? dio, TokenManager? tokenManager})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
                headers: {'Content-Type': 'application/json'},
              ),
            ),
        _tokenManager = tokenManager ?? TokenManager(SecureStorageImpl());

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _dio.post('/customer/auth/send-otp', data: {'phoneNumber': phoneNumber});
    } on DioException catch (error) {
      throw Exception(_messageFrom(error));
    }
  }

  @override
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post('/customer/auth/verify-otp', data: {'phoneNumber': phoneNumber, 'otp': otp});
      await _saveSession(response.data);
    } on DioException catch (error) {
      throw Exception(_messageFrom(error));
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/customer/auth/register',
        data: {
          'name': name,
          'email': email,
          'phoneNumber': phone,
          'password': password,
        },
      );
      await _saveSession(response.data);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          throw Exception(data['message']);
        }
      }
      throw Exception(_messageFrom(e));
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/customer/auth/login-password',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );
      await _saveSession(response.data);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          throw Exception(data['message']);
        }
      }

      throw Exception(_messageFrom(e));
    }
  }

  @override
  Future<void> logout() async {
    await _tokenManager.clearTokens();
  }

  @override
  Future<bool> checkSession() async {
    try {
      final token = await _tokenManager.getAccessToken();
      if (token == null || token.isEmpty) return false;
      final res = await _dio.get('/customer/auth/me', options: Options(headers: {'Authorization': 'B' 'earer $token'}));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveSession(dynamic raw) async {
    final data = Map<String, dynamic>.from(raw as Map);
    final session = Map<String, dynamic>.from(data['session'] as Map);
    final accessToken = session['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) throw Exception('Authentication token was not returned by the server.');
    await _tokenManager.saveTokens(accessToken: accessToken, refreshToken: session['refreshToken'] as String? ?? '');
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return 'Unable to reach GoRush server. Please check your connection and try again.';
  }
}
