import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage_service.dart';

class SupportChatService {
  SupportChatService._();
  static final instance = SupportChatService._();
  final _client = http.Client();

  Future<bool> send(String message) async {
    final token = TokenStorageService.instance.accessToken;
    if (token == null || token.isEmpty) return false;
    for (final base in ApiConfig.candidateBaseUrls) {
      try {
        final response = await _client.post(
          Uri.parse('$base/api/support/messages'),
          headers: ApiConfig.getHeaders(token: token),
          body: jsonEncode({'message': message}),
        ).timeout(ApiConfig.requestTimeout);
        if (response.statusCode == 201) return true;
      } catch (_) {}
    }
    return false;
  }
}
