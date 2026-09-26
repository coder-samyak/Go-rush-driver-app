enum RideCategoryType {
  bike,
  bikeLite,
  auto,
  autoLite,
  cab,
  cabLite,
  primeSedan,
  sevenSeater,
}

class RideCategory {
  final String id;
  final RideCategoryType code;
  final String displayName;
  final String description;
  final int capacity;
  final int etaMinutes;

  const RideCategory({
    required this.id,
    required this.code,
    required this.displayName,
    required this.description,
    required this.capacity,
    this.etaMinutes = 3,
  });

  factory RideCategory.fromJson(Map<String, dynamic> json) {
    final codeStr = (json['code'] as String? ?? '').toUpperCase();
    RideCategoryType code = RideCategoryType.cab;

    if (codeStr == 'BIKE') {
      code = RideCategoryType.bike;
    } else if (codeStr == 'BIKE_LITE') {
      code = RideCategoryType.bikeLite;
    } else if (codeStr == 'AUTO') {
      code = RideCategoryType.auto;
    } else if (codeStr == 'AUTO_LITE') {
      code = RideCategoryType.autoLite;
    } else if (codeStr == 'CAB' || codeStr == 'MINI') {
      code = RideCategoryType.cab;
    } else if (codeStr == 'CAB_LITE') {
      code = RideCategoryType.cabLite;
    } else if (codeStr == 'PRIME_SEDAN' || codeStr == 'SEDAN') {
      code = RideCategoryType.primeSedan;
    } else if (codeStr == 'SEVEN_SEATER' || codeStr == 'PREMIUM_XL') {
      code = RideCategoryType.sevenSeater;
    }

    return RideCategory(
      id: json['id'] as String? ?? 'cat_1',
      code: code,
      displayName: json['displayName'] as String? ?? 'Cab',
      description: json['description'] as String? ?? 'Comfortable AC Ride',
      capacity: (json['capacity'] as num?)?.toInt() ?? 4,
      etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 3,
    );
  }
}
