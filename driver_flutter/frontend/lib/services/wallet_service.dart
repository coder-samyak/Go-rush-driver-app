import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage_service.dart';

/// Driver wallet data model
class WalletInfo {
  final double balance;
  final double minimumRequiredBalance;
  final String currency;
  final bool isBlocked;
  final bool isSufficient;
  final double totalRecharged;
  final double totalCompanyChargesDeducted;

  const WalletInfo({
    required this.balance,
    required this.minimumRequiredBalance,
    required this.currency,
    required this.isBlocked,
    required this.isSufficient,
    required this.totalRecharged,
    required this.totalCompanyChargesDeducted,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      minimumRequiredBalance:
          (json['minimumRequiredBalance'] as num?)?.toDouble() ?? 100.0,
      currency: json['currency'] as String? ?? 'INR',
      isBlocked: json['isBlocked'] as bool? ?? false,
      isSufficient: json['isSufficient'] as bool? ?? false,
      totalRecharged: (json['totalRecharged'] as num?)?.toDouble() ?? 0.0,
      totalCompanyChargesDeducted:
          (json['totalCompanyChargesDeducted'] as num?)?.toDouble() ?? 0.0,
    );
  }

  WalletInfo copyWith({
    double? balance,
    double? minimumRequiredBalance,
    String? currency,
    bool? isBlocked,
    bool? isSufficient,
    double? totalRecharged,
    double? totalCompanyChargesDeducted,
  }) {
    return WalletInfo(
      balance: balance ?? this.balance,
      minimumRequiredBalance:
          minimumRequiredBalance ?? this.minimumRequiredBalance,
      currency: currency ?? this.currency,
      isBlocked: isBlocked ?? this.isBlocked,
      isSufficient: isSufficient ?? this.isSufficient,
      totalRecharged: totalRecharged ?? this.totalRecharged,
      totalCompanyChargesDeducted:
          totalCompanyChargesDeducted ?? this.totalCompanyChargesDeducted,
    );
  }
}

/// Wallet transaction item
class WalletTxn {
  final String id;
  final String type; // 'CREDIT' | 'DEBIT'
  final String category; // 'COMPANY_CHARGE' | 'RECHARGE' | 'REVERSAL'
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? rideId;
  final String? description;
  final String status;
  final DateTime createdAt;

  const WalletTxn({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.rideId,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory WalletTxn.fromJson(Map<String, dynamic> json) {
    return WalletTxn(
      id: json['_id']?.toString() ?? '',
      type: json['type'] as String? ?? 'DEBIT',
      category: json['category'] as String? ?? 'COMPANY_CHARGE',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      rideId: json['rideId'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'SUCCESS',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// GoRush Wallet Service
/// Provides wallet balance, transaction history, and recharge functionality.
/// All monetary calculations happen on the backend — never on the client.
class WalletService extends ChangeNotifier {
  static final WalletService instance = WalletService._internal();
  factory WalletService() => instance;
  WalletService._internal();

  final http.Client _httpClient = http.Client();
  final TokenStorageService _tokenStorage = TokenStorageService.instance;

  WalletInfo? _wallet;
  WalletInfo? get wallet => _wallet;

  List<WalletTxn> _transactions = [];
  List<WalletTxn> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Platform config (from backend — never hardcoded)
  double _companyChargeValue = 20.0;
  double get companyChargeValue => _companyChargeValue;
  String _companyChargeType = 'PERCENTAGE';
  String get companyChargeType => _companyChargeType;
  double _minimumWalletBalance = 100.0;
  double get minimumWalletBalance => _minimumWalletBalance;

  bool get hasLowBalance =>
      _wallet != null && _wallet!.balance < _minimumWalletBalance;

  String? get _token => _tokenStorage.accessToken;

  Map<String, String> get _headers => ApiConfig.getHeaders(token: _token);

  Duration _timeoutForCandidate(String base) {
    if (base.startsWith('https://')) return const Duration(seconds: 20);
    return const Duration(seconds: 15);
  }

  Future<http.Response?> _getWithFallback(String path) async {
    for (final base in ApiConfig.candidateBaseUrls) {
      final url = Uri.parse('$base$path');
      try {
        final response = await _httpClient
            .get(url, headers: _headers)
            .timeout(_timeoutForCandidate(base));
        if (response.statusCode < 500) return response;
      } catch (_) {}
    }
    return null;
  }

  Future<http.Response?> _postWithFallback(
      String path, Map<String, dynamic> body) async {
    for (final base in ApiConfig.candidateBaseUrls) {
      final url = Uri.parse('$base$path');
      try {
        final response = await _httpClient
            .post(url, headers: _headers, body: jsonEncode(body))
            .timeout(_timeoutForCandidate(base));
        if (response.statusCode < 500) return response;
      } catch (_) {}
    }
    return null;
  }

  /// Fetch current wallet balance and platform config
  Future<WalletInfo?> fetchWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _getWithFallback('/api/driver/wallet');
      if (response == null) {
        _error = 'Unable to reach server';
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data?['success'] == true && data?['wallet'] != null) {
        _wallet =
            WalletInfo.fromJson(data!['wallet'] as Map<String, dynamic>);
        // Also update platform config if available
        final config = data['config'] as Map<String, dynamic>?;
        if (config != null) {
          _companyChargeValue =
              (config['companyChargeValue'] as num?)?.toDouble() ?? 20.0;
          _companyChargeType =
              config['companyChargeType'] as String? ?? 'PERCENTAGE';
          _minimumWalletBalance =
              (config['minimumWalletBalance'] as num?)?.toDouble() ?? 100.0;
        }
        return _wallet;
      }
      _error = data?['message'] as String? ?? 'Failed to fetch wallet';
      return null;
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      debugPrint('[WalletService] fetchWallet error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch transaction history (most recent first)
  Future<List<WalletTxn>> fetchTransactions({int limit = 50}) async {
    try {
      final response = await _getWithFallback(
          '/api/driver/wallet/transactions?limit=$limit');
      if (response == null) return _transactions;

      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data?['success'] == true) {
        final list = data?['data']?['transactions'] as List<dynamic>?;
        if (list != null) {
          _transactions = list
              .map((e) => WalletTxn.fromJson(e as Map<String, dynamic>))
              .toList();
          notifyListeners();
        }
      }
      return _transactions;
    } catch (e) {
      debugPrint('[WalletService] fetchTransactions error: $e');
      return _transactions;
    }
  }

  /// Check if wallet has sufficient balance for ride acceptance
  Future<Map<String, dynamic>> checkWalletStatus() async {
    try {
      final response = await _getWithFallback('/api/driver/wallet/status');
      if (response == null) {
        return {'isSufficient': true, 'balance': _wallet?.balance ?? 0};
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data?['success'] == true) {
        final d = data?['data'] as Map<String, dynamic>?;
        return {
          'isSufficient': d?['isSufficient'] ?? true,
          'balance': (d?['balance'] as num?)?.toDouble() ?? 0.0,
          'minimumRequiredBalance':
              (d?['minimumRequiredBalance'] as num?)?.toDouble() ?? 100.0,
          'isBlocked': d?['isBlocked'] ?? false,
        };
      }
      return {'isSufficient': true};
    } catch (e) {
      return {'isSufficient': true};
    }
  }

  /// Recharge wallet by the given amount (in INR)
  Future<({bool success, String message, WalletInfo? wallet})> recharge(
      double amount) async {
    if (amount <= 0) {
      return (
        success: false,
        message: 'Please enter a valid recharge amount',
        wallet: null
      );
    }

    try {
      final response = await _postWithFallback(
        '/api/driver/wallet/recharge',
        {'amount': amount, 'paymentMethod': 'UPI'},
      );

      if (response == null) {
        return (
          success: false,
          message: 'Unable to reach server. Please try again.',
          wallet: null
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data?['success'] == true && data?['wallet'] != null) {
        _wallet =
            WalletInfo.fromJson(data!['wallet'] as Map<String, dynamic>);
        notifyListeners();
        return (
          success: true,
          message:
              data['message'] as String? ?? 'Wallet recharged successfully',
          wallet: _wallet
        );
      }

      return (
        success: false,
        message: data?['message'] as String? ?? 'Recharge failed',
        wallet: null
      );
    } catch (e) {
      return (
        success: false,
        message: 'Network error. Please try again.',
        wallet: null
      );
    }
  }

  /// Format amount as Indian Rupee string
  static String formatAmount(double amount) {
    final intVal = amount.round();
    final str = intVal.abs().toString();
    if (str.length <= 3) return '₹${intVal < 0 ? '-' : ''}$str';
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    return '₹${intVal < 0 ? '-' : ''}$rest,$lastThree';
  }

  void clearSession() {
    _wallet = null;
    _transactions = [];
    _error = null;
    notifyListeners();
  }
}
