import 'package:dio/dio.dart';
import '../domain/wallet_models.dart';
import '../../network/api_config.dart';
import '../../security/token_manager.dart';
import '../../security/secure_storage.dart';

abstract class WalletRepository {
  Future<WalletSummary> getSummary();
  Future<Map<String, dynamic>> addMoney(int amountMinor, {String? paymentMethodId});
  Future<List<WalletTransaction>> getTransactions();
  Future<List<RefundStatusModel>> getRefunds();
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> addPaymentMethod({
    required String type,
    required String title,
    required String subtitle,
  });
  Future<List<PaymentMethodModel>> setDefaultPaymentMethod(String id);
  Future<void> deletePaymentMethod(String id);
  Future<List<PromoCredit>> getPromoCredits();
  Future<Map<String, dynamic>> redeemPromo(String code);
}

class HttpWalletRepository implements WalletRepository {
  final Dio _dio;
  final MockWalletRepository _fallback = MockWalletRepository();
  final TokenManager _tokenManager;

  HttpWalletRepository({Dio? dio, TokenManager? tokenManager}) 
      : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
        _tokenManager = tokenManager ?? TokenManager(SecureStorageImpl());

  Future<String> _getToken() async {
    final token = await _tokenManager.getAccessToken();
    return token ?? 'mock_access_token';
  }

  @override
  Future<WalletSummary> getSummary() async {
    try {
      final token = await _getToken();
      final res = await _dio.get(
        '/wallet',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return WalletSummary.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _fallback.getSummary();
    }
  }

  @override
  Future<Map<String, dynamic>> addMoney(int amountMinor, {String? paymentMethodId}) async {
    try {
      final token = await _getToken();
      final res = await _dio.post(
        '/wallet/add-money',
        data: {'amountMinor': amountMinor, 'paymentMethodId': paymentMethodId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data as Map<String, dynamic>;
    } catch (_) {
      return _fallback.addMoney(amountMinor, paymentMethodId: paymentMethodId);
    }
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    try {
      final token = await _getToken();
      final res = await _dio.get(
        '/wallet/transactions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final list = res.data as List;
      return list.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _fallback.getTransactions();
    }
  }

  @override
  Future<List<RefundStatusModel>> getRefunds() async {
    try {
      final token = await _getToken();
      final res = await _dio.get(
        '/wallet/refunds',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final list = res.data as List;
      return list.map((e) => RefundStatusModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _fallback.getRefunds();
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final token = await _getToken();
      final res = await _dio.get(
        '/wallet/payment-methods',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final list = res.data as List;
      return list.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _fallback.getPaymentMethods();
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod({
    required String type,
    required String title,
    required String subtitle,
  }) async {
    try {
      final token = await _getToken();
      final res = await _dio.post(
        '/wallet/payment-methods',
        data: {'type': type, 'title': title, 'subtitle': subtitle},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return PaymentMethodModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _fallback.addPaymentMethod(type: type, title: title, subtitle: subtitle);
    }
  }

  @override
  Future<List<PaymentMethodModel>> setDefaultPaymentMethod(String id) async {
    try {
      final token = await _getToken();
      final res = await _dio.post(
        '/wallet/payment-methods/$id/set-default',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final list = res.data as List;
      return list.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _fallback.setDefaultPaymentMethod(id);
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '/wallet/payment-methods/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {
      await _fallback.deletePaymentMethod(id);
    }
  }

  @override
  Future<List<PromoCredit>> getPromoCredits() async {
    try {
      final token = await _getToken();
      final res = await _dio.get(
        '/wallet/promo-credits',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final list = res.data as List;
      return list.map((e) => PromoCredit.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _fallback.getPromoCredits();
    }
  }

  @override
  Future<Map<String, dynamic>> redeemPromo(String code) async {
    try {
      final token = await _getToken();
      final res = await _dio.post(
        '/wallet/redeem-promo',
        data: {'code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data as Map<String, dynamic>;
    } catch (_) {
      return _fallback.redeemPromo(code);
    }
  }
}

class MockWalletRepository implements WalletRepository {
  int _walletBalance = 45000;
  int _promoBalance = 15000;

  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'tx_9801',
      title: 'Added to GoRush Wallet',
      subtitle: 'Via Google Pay (UPI)',
      type: 'TOPUP',
      amountMinor: 50000,
      isDebit: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      referenceId: 'UPI-9812401924',
      status: 'COMPLETED',
    ),
    WalletTransaction(
      id: 'tx_9802',
      title: 'Ride #ride_abc123',
      subtitle: 'Dropoff at IGI Terminal 3',
      type: 'RIDE_PAYMENT',
      amountMinor: 18900,
      isDebit: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      referenceId: 'ride_abc123',
      status: 'COMPLETED',
    ),
    WalletTransaction(
      id: 'tx_9803',
      title: 'Refund for Cancellation',
      subtitle: 'Ride #ride_prev99',
      type: 'REFUND',
      amountMinor: 13900,
      isDebit: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 36)),
      referenceId: 'ref_30192',
      status: 'COMPLETED',
    ),
  ];

  final List<RefundStatusModel> _refunds = [
    RefundStatusModel(
      refundId: 'ref_30192',
      rideId: 'ride_prev99',
      amountMinor: 13900,
      reason: 'Driver unfulfilled trip / Cancellation',
      status: 'PROCESSED',
      initiatedAt: DateTime.now().subtract(const Duration(hours: 38)),
      estimatedCompletionAt: DateTime.now().subtract(const Duration(hours: 36)),
      bankReferenceNumber: 'HDFC-REF-8891029',
    ),
    RefundStatusModel(
      refundId: 'ref_40821',
      rideId: 'ride_delay12',
      amountMinor: 5000,
      reason: 'Route delay compensation',
      status: 'IN_BANK',
      initiatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      estimatedCompletionAt: DateTime.now().add(const Duration(hours: 18)),
      bankReferenceNumber: 'ICICI-REF-1928374',
    ),
  ];

  final List<PaymentMethodModel> _paymentMethods = [
    PaymentMethodModel(
      id: 'pm_gpay',
      type: 'UPI',
      title: 'Google Pay',
      subtitle: 'user@okicici',
      icon: 'gpay',
      isDefault: true,
    ),
    PaymentMethodModel(
      id: 'pm_phonepe',
      type: 'UPI',
      title: 'PhonePe UPI',
      subtitle: '9876543210@ybl',
      icon: 'phonepe',
      isDefault: false,
    ),
    PaymentMethodModel(
      id: 'pm_card_hdfc',
      type: 'CARD',
      title: 'HDFC Bank Credit Card',
      subtitle: '•••• •••• •••• 4829 (Expires 08/28)',
      icon: 'credit_card',
      isDefault: false,
    ),
  ];

  final List<PromoCredit> _promos = [
    PromoCredit(
      code: 'GORUSH50',
      title: '50% OFF Next 3 Rides',
      description: 'Maximum discount ₹75 per ride',
      discountPercentage: 50,
      expiresAt: DateTime.now().add(const Duration(days: 15)),
      isRedeemed: false,
    ),
    PromoCredit(
      code: 'AIRPORT100',
      title: '₹100 Flat Cashback on Airport Trips',
      description: 'Applicable on GoSedan category',
      flatAmountMinor: 10000,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      isRedeemed: false,
    ),
  ];

  @override
  Future<WalletSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final defaultPm = _paymentMethods.firstWhere((p) => p.isDefault, orElse: () => _paymentMethods.first);
    return WalletSummary(
      walletBalanceMinor: _walletBalance,
      promoBalanceMinor: _promoBalance,
      totalAvailableMinor: _walletBalance + _promoBalance,
      formattedWalletBalance: '₹${(_walletBalance / 100).toStringAsFixed(2)}',
      formattedPromoBalance: '₹${(_promoBalance / 100).toStringAsFixed(2)}',
      formattedTotalAvailable: '₹${((_walletBalance + _promoBalance) / 100).toStringAsFixed(2)}',
      defaultPaymentMethod: defaultPm,
    );
  }

  @override
  Future<Map<String, dynamic>> addMoney(int amountMinor, {String? paymentMethodId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _walletBalance += amountMinor;

    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Added to GoRush Wallet',
      subtitle: 'Via Online Payment',
      type: 'TOPUP',
      amountMinor: amountMinor,
      isDebit: false,
      timestamp: DateTime.now(),
      referenceId: 'REF-${DateTime.now().millisecondsSinceEpoch}',
      status: 'COMPLETED',
    );
    _transactions.insert(0, tx);

    return {
      'status': 'TOPUP_SUCCESSFUL',
      'transaction': tx,
    };
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions;
  }

  @override
  Future<List<RefundStatusModel>> getRefunds() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _refunds;
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _paymentMethods;
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod({
    required String type,
    required String title,
    required String subtitle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newPm = PaymentMethodModel(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      subtitle: subtitle,
      icon: type == 'CARD' ? 'credit_card' : 'qr_code_2',
      isDefault: _paymentMethods.isEmpty,
    );
    _paymentMethods.add(newPm);
    return newPm;
  }

  @override
  Future<List<PaymentMethodModel>> setDefaultPaymentMethod(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _paymentMethods.length; i++) {
      final p = _paymentMethods[i];
      _paymentMethods[i] = PaymentMethodModel(
        id: p.id,
        type: p.type,
        title: p.title,
        subtitle: p.subtitle,
        icon: p.icon,
        isDefault: p.id == id,
      );
    }
    return _paymentMethods;
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _paymentMethods.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<PromoCredit>> getPromoCredits() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _promos;
  }

  @override
  Future<Map<String, dynamic>> redeemPromo(String code) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'WELCOME100' || cleanCode == 'GORUSH50' || cleanCode == 'FREERIDE') {
      final added = cleanCode == 'WELCOME100' ? 10000 : 5000;
      _promoBalance += added;
      _transactions.insert(
        0,
        WalletTransaction(
          id: 'tx_promo_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Redeemed Code: $cleanCode',
          subtitle: 'Added to Promo Credits',
          type: 'PROMO_CREDIT',
          amountMinor: added,
          isDebit: false,
          timestamp: DateTime.now(),
          referenceId: 'PROMO-$cleanCode',
          status: 'COMPLETED',
        ),
      );
      return {'status': 'PROMO_REDEEMED', 'addedCreditMinor': added};
    }
    throw Exception('Invalid promo code');
  }
}
