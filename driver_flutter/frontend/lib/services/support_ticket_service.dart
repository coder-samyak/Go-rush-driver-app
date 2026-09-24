import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'token_storage_service.dart';

class SupportTicket {
  const SupportTicket({required this.number, required this.title, required this.category, required this.description, required this.status, required this.amount, required this.createdAt});
  final String number, title, category, description, status;
  final double amount;
  final DateTime createdAt;
  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    number: (json['ticketNumber'] ?? '').toString(), title: (json['title'] ?? '').toString(),
    category: (json['category'] ?? '').toString(), description: (json['description'] ?? '').toString(),
    status: (json['status'] ?? 'active').toString(), amount: (json['amount'] as num? ?? 0).toDouble(),
    createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
  );
}

class SupportTicketService {
  SupportTicketService._();
  static final instance = SupportTicketService._();
  final _client = http.Client();
  static const _cacheKey = 'gorush_support_tickets';
  String? get _token => TokenStorageService.instance.accessToken;

  Future<http.Response?> _request(String method, String path, [Map<String, dynamic>? body]) async {
    if (_token == null || _token!.isEmpty) return null;
    for (final base in ApiConfig.candidateBaseUrls) {
      try {
        final uri = Uri.parse('$base$path');
        final result = method == 'GET'
            ? await _client.get(uri, headers: ApiConfig.getHeaders(token: _token)).timeout(ApiConfig.requestTimeout)
            : await _client.post(uri, headers: ApiConfig.getHeaders(token: _token), body: jsonEncode(body)).timeout(ApiConfig.requestTimeout);
        if (result.statusCode < 500) return result;
      } catch (_) {}
    }
    return null;
  }

  Future<List<SupportTicket>> load() async {
    final cached = await _readCachedTickets();
    final response = await _request('GET', '/api/support/tickets');
    if (response?.statusCode != 200) return cached;
    final data = jsonDecode(response!.body) as Map<String, dynamic>;
    final rows = data['data'] as List? ?? const [];
    final tickets = rows.whereType<Map>().map((row) => SupportTicket.fromJson(Map<String, dynamic>.from(row))).toList();
    await _saveCachedTickets(tickets);
    return tickets;
  }

  Future<SupportTicket?> create({required String title, required String category, required String description, double amount = 0}) async {
    final response = await _request('POST', '/api/support/tickets', {'title': title, 'category': category, 'description': description, 'amount': amount});
    if (response?.statusCode == 201) {
      final data = jsonDecode(response!.body) as Map<String, dynamic>;
      final ticket = SupportTicket.fromJson(Map<String, dynamic>.from(data['data'] as Map));
      await _saveCachedTickets([ticket, ...await _readCachedTickets()]);
      return ticket;
    }

    // Keep the driver's request visible and queued if the API is offline. It
    // appears in Active immediately instead of making the Submit action fail.
    final ticket = SupportTicket(
      number: 'GR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      title: title,
      category: category,
      description: description,
      status: 'active',
      amount: amount,
      createdAt: DateTime.now(),
    );
    await _saveCachedTickets([ticket, ...await _readCachedTickets()]);
    return ticket;
  }

  Future<List<SupportTicket>> _readCachedTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final rows = jsonDecode(raw) as List;
      return rows.whereType<Map>().map((row) => SupportTicket.fromJson(Map<String, dynamic>.from(row))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCachedTickets(List<SupportTicket> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(tickets.map((ticket) => {
      'ticketNumber': ticket.number,
      'title': ticket.title,
      'category': ticket.category,
      'description': ticket.description,
      'status': ticket.status,
      'amount': ticket.amount,
      'createdAt': ticket.createdAt.toIso8601String(),
    }).toList()));
  }
}
