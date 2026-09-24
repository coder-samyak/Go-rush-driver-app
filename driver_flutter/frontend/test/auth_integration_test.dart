import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gorush_driver/services/api_config.dart';
import 'package:gorush_driver/services/token_storage_service.dart';
import 'package:gorush_driver/services/auth_api_service.dart';
import 'package:gorush_driver/services/driver_backend_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3: Flutter & Backend Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await TokenStorageService.instance.clearSession();
    });

    test('1. ApiConfig correctly resolves base URL and endpoints on port 5000', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.candidateBaseUrls.any((url) => url.contains(':5000')), isTrue);
      expect(ApiConfig.registerEndpoint, equals('/api/auth/register'));
      expect(ApiConfig.loginEndpoint, equals('/api/auth/login'));
      expect(ApiConfig.meEndpoint, equals('/api/auth/me'));
      expect(ApiConfig.healthEndpoint, equals('/api/health'));

      final defaultHeaders = ApiConfig.getHeaders();
      expect(defaultHeaders['Content-Type'], equals('application/json'));
      expect(defaultHeaders.containsKey('Authorization'), isFalse);

      final authHeaders = ApiConfig.getHeaders(token: 'mock_bearer_jwt_token');
      expect(authHeaders['Authorization'], equals('Bearer mock_bearer_jwt_token'));
    });

    test('2. TokenStorageService correctly saves, reads, and clears JWT session', () async {
      final storage = TokenStorageService.instance;
      await storage.init();

      expect(storage.isAuthenticated, isFalse);
      expect(storage.accessToken, isNull);

      // Save session
      await storage.saveSession(
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test',
        refreshToken: 'refresh_token_test_123',
        driverProfile: {
          '_id': 'drv_60d0fe4f5311236168a109ca',
          'name': 'Ramesh Kumar',
          'email': 'ramesh@gorush.com',
          'status': 'offline',
        },
      );

      expect(storage.isAuthenticated, isTrue);
      expect(storage.accessToken, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test'));
      expect(storage.refreshToken, equals('refresh_token_test_123'));
      expect(storage.driverProfile?['name'], equals('Ramesh Kumar'));
      expect(storage.hasToken(), isTrue);

      // Clear session (Logout)
      await storage.clearSession();
      expect(storage.isAuthenticated, isFalse);
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.driverProfile, isNull);
      expect(storage.hasToken(), isFalse);
    });

    test('3. DriverBackendService integrates with TokenStorage and handles auth state', () async {
      final backend = DriverBackendService.instance;
      await backend.logout();
      expect(backend.isAuthenticated, isFalse);
      expect(backend.accessToken, isNull);

      await backend.saveSession(
        accessToken: 'backend_service_token_xyz',
        driverProfile: {
          'name': 'Aman Sharma',
          'phone': '+91 98765 43210',
          'status': 'offline',
        },
      );

      expect(backend.isAuthenticated, isTrue);
      expect(backend.accessToken, equals('backend_service_token_xyz'));
      expect(backend.driverProfile?['name'], equals('Aman Sharma'));

      await backend.logout();
      expect(backend.isAuthenticated, isFalse);
      expect(backend.accessToken, isNull);
    });

    test('4. AuthResult handles success and failure states cleanly', () {
      final successResult = AuthResult.success(
        message: 'Login successful',
        token: 'valid_jwt_token',
        driver: {'name': 'Ramesh', 'email': 'ramesh@gorush.com'},
        statusCode: 200,
      );

      expect(successResult.success, isTrue);
      expect(successResult.message, equals('Login successful'));
      expect(successResult.token, equals('valid_jwt_token'));
      expect(successResult.driver?['name'], equals('Ramesh'));
      expect(successResult.statusCode, equals(200));

      final failureResult = AuthResult.failure(
        message: 'Invalid email or password',
        statusCode: 401,
      );

      expect(failureResult.success, isFalse);
      expect(failureResult.message, equals('Invalid email or password'));
      expect(failureResult.token, isNull);
      expect(failureResult.statusCode, equals(401));
    });
  });
}
