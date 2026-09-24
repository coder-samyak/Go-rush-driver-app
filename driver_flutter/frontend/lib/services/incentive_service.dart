import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage_service.dart';

class IncentiveQuest {
  final int completed;
  final int target;
  final double progress;
  final bool eligible;
  final String status;

  const IncentiveQuest({
    required this.completed,
    required this.target,
    required this.progress,
    required this.eligible,
    required this.status,
  });

  factory IncentiveQuest.fromJson(Map<String, dynamic> json) => IncentiveQuest(
        completed: (json['completed'] as num?)?.toInt() ?? 0,
        target: (json['target'] as num?)?.toInt() ?? 0,
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        eligible: json['eligible'] == true,
        status: (json['status'] ?? 'In progress').toString(),
      );
}

class IncentiveSummary {
  final IncentiveQuest weekly;
  final IncentiveQuest weekend;
  final double rating;
  final double ratingTarget;
  final double ratingProgress;
  final bool topDriverEligible;
  final String topDriverStatus;

  const IncentiveSummary({
    required this.weekly,
    required this.weekend,
    required this.rating,
    required this.ratingTarget,
    required this.ratingProgress,
    required this.topDriverEligible,
    required this.topDriverStatus,
  });

  factory IncentiveSummary.fromJson(Map<String, dynamic> json) {
    final topDriver = json['topDriver'] as Map<String, dynamic>? ?? const {};
    return IncentiveSummary(
      weekly: IncentiveQuest.fromJson(
          json['weekly'] as Map<String, dynamic>? ?? const {}),
      weekend: IncentiveQuest.fromJson(
          json['weekend'] as Map<String, dynamic>? ?? const {}),
      rating: (topDriver['rating'] as num?)?.toDouble() ?? 0,
      ratingTarget: (topDriver['target'] as num?)?.toDouble() ?? 4.5,
      ratingProgress: (topDriver['progress'] as num?)?.toDouble() ?? 0,
      topDriverEligible: topDriver['eligible'] == true,
      topDriverStatus: (topDriver['status'] ?? 'Not qualified').toString(),
    );
  }
}

class IncentiveService {
  static final IncentiveService instance = IncentiveService._();
  IncentiveService._();

  final _storage = TokenStorageService.instance;

  Future<IncentiveSummary?> fetch() async {
    final token = _storage.accessToken;
    if (token == null || token.isEmpty) return null;
    for (final baseUrl in ApiConfig.candidateBaseUrls) {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl${ApiConfig.driverIncentivesEndpoint}'),
              headers: ApiConfig.getHeaders(token: token),
            )
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          if (decoded['success'] == true &&
              decoded['data'] is Map<String, dynamic>) {
            ApiConfig.customBaseUrl = baseUrl;
            return IncentiveSummary.fromJson(
                decoded['data'] as Map<String, dynamic>);
          }
        }
      } on TimeoutException catch (_) {
        // Try the next valid local/device endpoint.
      } catch (_) {
        // Try the next valid local/device endpoint.
      }
    }
    return null;
  }
}
