import 'dart:async';
import 'package:dio/dio.dart';
import '../security/token_manager.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenManager tokenManager;
  final VoidCallback onSessionExpired;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  AuthInterceptor({
    required this.dio,
    required this.tokenManager,
    required this.onSessionExpired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final success = await _refreshToken();
      if (success) {
        final token = await tokenManager.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      } else {
        onSessionExpired();
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await tokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        _refreshCompleter!.complete(false);
        return false;
      }

      // Create a temporary Dio instance so we don't trigger the interceptor again
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      final response = await refreshDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        
        await tokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        
        _isRefreshing = false;
        _refreshCompleter!.complete(true);
        return true;
      } else {
        await tokenManager.clearTokens();
        _isRefreshing = false;
        _refreshCompleter!.complete(false);
        return false;
      }
    } catch (e) {
      await tokenManager.clearTokens();
      _isRefreshing = false;
      _refreshCompleter!.complete(false);
      return false;
    }
  }
}

typedef VoidCallback = void Function();
