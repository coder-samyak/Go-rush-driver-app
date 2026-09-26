import 'package:dio/dio.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import '../security/token_manager.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({required TokenManager tokenManager}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenManager: tokenManager,
      onSessionExpired: () {
        // Trigger session expiration handling
      },
    ));
  }
}
