import 'money.dart';
import 'ride_category.dart';

class FareComponent {
  final String type;
  final String label;
  final Money amount;

  const FareComponent({
    required this.type,
    required this.label,
    required this.amount,
  });

  factory FareComponent.fromJson(Map<String, dynamic> json) {
    return FareComponent(
      type: json['type'] as String,
      label: json['label'] as String,
      amount: Money.fromJson(json['amount'] as Map<String, dynamic>),
    );
  }
}

class FareBreakdown {
  final Money subtotal;
  final List<FareComponent> components;
  final Money discount;
  final Money tax;
  final Money total;

  const FareBreakdown({
    required this.subtotal,
    required this.components,
    required this.discount,
    required this.tax,
    required this.total,
  });

  factory FareBreakdown.fromJson(Map<String, dynamic> json) {
    return FareBreakdown(
      subtotal: json['subtotal'] != null ? Money.fromJson(json['subtotal'] as Map<String, dynamic>) : Money(amountMinor: 0, currency: 'INR'),
      components: json['components'] != null 
          ? (json['components'] as List)
              .map((e) => FareComponent.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      discount: json['discount'] != null ? Money.fromJson(json['discount'] as Map<String, dynamic>) : Money(amountMinor: 0, currency: 'INR'),
      tax: json['tax'] != null ? Money.fromJson(json['tax'] as Map<String, dynamic>) : Money(amountMinor: 0, currency: 'INR'),
      total: json['total'] != null ? Money.fromJson(json['total'] as Map<String, dynamic>) : Money(amountMinor: 0, currency: 'INR'),
    );
  }
}

class Quote {
  final String quoteId;
  final RideCategory rideCategory;
  final int distanceMeters;
  final int durationSeconds;
  final FareBreakdown fareBreakdown;
  final String pricingVersion;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Quote({
    required this.quoteId,
    required this.rideCategory,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.fareBreakdown,
    required this.pricingVersion,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quoteId: json['quoteId'] as String? ?? 'Q-UNKNOWN',
      rideCategory: json['rideCategory'] != null 
          ? RideCategory.fromJson(json['rideCategory'] as Map<String, dynamic>) 
          : const RideCategory(id: 'cat_unknown', code: RideCategoryType.cab, displayName: 'Unknown', description: 'Unknown category', capacity: 4, etaMinutes: 0),
      distanceMeters: json['distanceMeters'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      fareBreakdown: FareBreakdown.fromJson(json['fareBreakdown'] as Map<String, dynamic>),
      pricingVersion: json['pricingVersion'] as String? ?? 'v1',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : DateTime.now().add(const Duration(hours: 1)),
    );
  }
}
