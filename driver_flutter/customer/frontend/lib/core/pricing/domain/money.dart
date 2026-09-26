class Money {
  final int amountMinor; // e.g., 10050 paise for ₹100.50
  final String currency; // e.g., 'INR'

  const Money({
    required this.amountMinor,
    this.currency = 'INR',
  });

  Money operator +(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot add money of different currencies');
    }
    return Money(amountMinor: amountMinor + other.amountMinor, currency: currency);
  }

  Money operator -(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot subtract money of different currencies');
    }
    return Money(amountMinor: amountMinor - other.amountMinor, currency: currency);
  }

  String get formatted {
    final double value = amountMinor / 100.0;
    return '₹${value.toStringAsFixed(2)}';
  }

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amountMinor: json['amountMinor'] as int,
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amountMinor': amountMinor,
      'currency': currency,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && runtimeType == other.runtimeType && amountMinor == other.amountMinor && currency == other.currency;

  @override
  int get hashCode => amountMinor.hashCode ^ currency.hashCode;
}
