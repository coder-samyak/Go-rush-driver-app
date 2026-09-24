import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/insurance_models.dart';
import 'api_config.dart';
import 'token_storage_service.dart';

class InsuranceService {
  static final InsuranceService instance = InsuranceService._internal();
  InsuranceService._internal();
  factory InsuranceService() => instance;

  final _storage = TokenStorageService.instance;

  Map<String, String> get _headers => ApiConfig.getHeaders(
        token: _storage.accessToken,
      );

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response =
        await _send(method, path, body: body).timeout(ApiConfig.requestTimeout);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid insurance API response');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          decoded['message']?.toString() ?? 'Insurance request failed');
    }
    return decoded;
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final encoded = body == null ? null : jsonEncode(body);
    switch (method) {
      case 'POST':
        return http.post(uri, headers: _headers, body: encoded);
      case 'PUT':
        return http.put(uri, headers: _headers, body: encoded);
      default:
        return http.get(uri, headers: _headers);
    }
  }

  Future<InsurancePolicy?> getPolicy() async {
    final response = await _request('GET', '/api/insurance/my-policy');
    final data = response['data'];
    if (data is Map<String, dynamic>) return InsurancePolicy.fromJson(data);
    return null;
  }

  Future<Map<String, dynamic>> getRideInsurance(String rideId) =>
      _request('GET', '/api/insurance/ride/${Uri.encodeComponent(rideId)}');

  Future<List<InsuranceClaim>> getClaims() async {
    final response = await _request('GET', '/api/insurance/claims');
    final data = response['data'];
    final list = data is List ? data : response['claims'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((item) => InsuranceClaim.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<InsuranceClaim> submitClaim(Map<String, dynamic> claim) async {
    final response =
        await _request('POST', '/api/insurance/claim', body: claim);
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Claim response did not contain a claim');
    }
    return InsuranceClaim.fromJson(data);
  }

  Future<Map<String, dynamic>> getClaim(String claimId) =>
      _request('GET', '/api/insurance/claim/${Uri.encodeComponent(claimId)}');

  Future<List<Map<String, dynamic>>> getFaqs() async {
    final response = await _request('GET', '/api/insurance/faqs');
    final data = response['data'];
    return data is List
        ? data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : const [];
  }
}
