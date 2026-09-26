class PaymentMethodModel {
  final String id;
  final String type; // 'UPI', 'CARD', 'NET_BANKING', 'WALLET'
  final String title;
  final String subtitle;
  final String icon;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'UPI',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: json['icon'] ?? 'credit_card',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class WalletSummary {
  final int walletBalanceMinor;
  final int promoBalanceMinor;
  final int totalAvailableMinor;
  final String formattedWalletBalance;
  final String formattedPromoBalance;
  final String formattedTotalAvailable;
  final PaymentMethodModel? defaultPaymentMethod;

  WalletSummary({
    required this.walletBalanceMinor,
    required this.promoBalanceMinor,
    required this.totalAvailableMinor,
    required this.formattedWalletBalance,
    required this.formattedPromoBalance,
    required this.formattedTotalAvailable,
    this.defaultPaymentMethod,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      walletBalanceMinor: json['walletBalanceMinor'] ?? 0,
      promoBalanceMinor: json['promoBalanceMinor'] ?? 0,
      totalAvailableMinor: json['totalAvailableMinor'] ?? 0,
      formattedWalletBalance: json['formattedWalletBalance'] ?? '₹0.00',
      formattedPromoBalance: json['formattedPromoBalance'] ?? '₹0.00',
      formattedTotalAvailable: json['formattedTotalAvailable'] ?? '₹0.00',
      defaultPaymentMethod: json['defaultPaymentMethod'] != null
          ? PaymentMethodModel.fromJson(json['defaultPaymentMethod'])
          : null,
    );
  }
}

class WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final int amountMinor;
  final bool isDebit;
  final DateTime timestamp;
  final String? referenceId;
  final String status;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.amountMinor,
    required this.isDebit,
    required this.timestamp,
    this.referenceId,
    required this.status,
  });

  String get formattedAmount => '₹${(amountMinor / 100.0).toStringAsFixed(2)}';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: json['type'] ?? 'TOPUP',
      amountMinor: json['amountMinor'] ?? 0,
      isDebit: json['isDebit'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      referenceId: json['referenceId'],
      status: json['status'] ?? 'COMPLETED',
    );
  }
}

class RefundStatusModel {
  final String refundId;
  final String rideId;
  final int amountMinor;
  final String reason;
  final String status; // 'PROCESSED', 'IN_BANK', 'PENDING'
  final DateTime initiatedAt;
  final DateTime estimatedCompletionAt;
  final String? bankReferenceNumber;

  RefundStatusModel({
    required this.refundId,
    required this.rideId,
    required this.amountMinor,
    required this.reason,
    required this.status,
    required this.initiatedAt,
    required this.estimatedCompletionAt,
    this.bankReferenceNumber,
  });

  String get formattedAmount => '₹${(amountMinor / 100.0).toStringAsFixed(2)}';

  factory RefundStatusModel.fromJson(Map<String, dynamic> json) {
    return RefundStatusModel(
      refundId: json['refundId'] ?? '',
      rideId: json['rideId'] ?? '',
      amountMinor: json['amountMinor'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      initiatedAt: DateTime.tryParse(json['initiatedAt'] ?? '') ?? DateTime.now(),
      estimatedCompletionAt: DateTime.tryParse(json['estimatedCompletionAt'] ?? '') ?? DateTime.now(),
      bankReferenceNumber: json['bankReferenceNumber'],
    );
  }
}

class PromoCredit {
  final String code;
  final String title;
  final String description;
  final int? discountPercentage;
  final int? flatAmountMinor;
  final DateTime expiresAt;
  final bool isRedeemed;

  PromoCredit({
    required this.code,
    required this.title,
    required this.description,
    this.discountPercentage,
    this.flatAmountMinor,
    required this.expiresAt,
    required this.isRedeemed,
  });

  factory PromoCredit.fromJson(Map<String, dynamic> json) {
    return PromoCredit(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: json['discountPercentage'],
      flatAmountMinor: json['flatAmountMinor'],
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
      isRedeemed: json['isRedeemed'] ?? false,
    );
  }
}
