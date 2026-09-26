class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };
}

class UserProfileModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String gender;
  final String memberTier;
  final String memberSince;
  final List<EmergencyContact> emergencyContacts;
  final double rating;
  final int totalTrips;

  UserProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.gender,
    required this.memberTier,
    required this.memberSince,
    required this.emergencyContacts,
    required this.rating,
    required this.totalTrips,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final list = json['emergencyContacts'] as List? ?? [];
    return UserProfileModel(
      userId: json['userId'] ?? 'cust_123',
      name: json['name'] ?? 'John Doe',
      email: json['email'] ?? 'john.doe@example.com',
      phone: json['phone'] ?? '+91 98765 43210',
      avatarUrl: json['avatarUrl'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      gender: json['gender'] ?? 'Male',
      memberTier: json['memberTier'] ?? 'GOLD',
      memberSince: json['memberSince'] ?? 'January 2025',
      emergencyContacts: list.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>)).toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.92,
      totalTrips: json['totalTrips'] ?? 48,
    );
  }
}

class NotificationSettingsModel {
  final bool pushEnabled;
  final bool smsEnabled;
  final bool promoOffersEnabled;
  final bool tripStatusAlerts;
  final bool safetyAlerts;
  final bool soundVibrationEnabled;

  NotificationSettingsModel({
    required this.pushEnabled,
    required this.smsEnabled,
    required this.promoOffersEnabled,
    required this.tripStatusAlerts,
    required this.safetyAlerts,
    required this.soundVibrationEnabled,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      pushEnabled: json['pushEnabled'] ?? true,
      smsEnabled: json['smsEnabled'] ?? true,
      promoOffersEnabled: json['promoOffersEnabled'] ?? false,
      tripStatusAlerts: json['tripStatusAlerts'] ?? true,
      safetyAlerts: json['safetyAlerts'] ?? true,
      soundVibrationEnabled: json['soundVibrationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'pushEnabled': pushEnabled,
        'smsEnabled': smsEnabled,
        'promoOffersEnabled': promoOffersEnabled,
        'tripStatusAlerts': tripStatusAlerts,
        'safetyAlerts': safetyAlerts,
        'soundVibrationEnabled': soundVibrationEnabled,
      };
}

class PrivacySettingsModel {
  final String locationPermission;
  final bool shareLiveTripWithEmergency;
  final bool personalizedAdsConsent;
  final bool analyticsConsent;
  final int dataRetentionYears;

  PrivacySettingsModel({
    required this.locationPermission,
    required this.shareLiveTripWithEmergency,
    required this.personalizedAdsConsent,
    required this.analyticsConsent,
    required this.dataRetentionYears,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      locationPermission: json['locationPermission'] ?? 'WHILE_USING',
      shareLiveTripWithEmergency: json['shareLiveTripWithEmergency'] ?? true,
      personalizedAdsConsent: json['personalizedAdsConsent'] ?? false,
      analyticsConsent: json['analyticsConsent'] ?? true,
      dataRetentionYears: json['dataRetentionYears'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
        'locationPermission': locationPermission,
        'shareLiveTripWithEmergency': shareLiveTripWithEmergency,
        'personalizedAdsConsent': personalizedAdsConsent,
        'analyticsConsent': analyticsConsent,
        'dataRetentionYears': dataRetentionYears,
      };
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      question: json['q'] ?? '',
      answer: json['a'] ?? '',
    );
  }
}

class FaqCategory {
  final String category;
  final List<FaqItem> faqs;

  FaqCategory({required this.category, required this.faqs});

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    final list = json['faqs'] as List? ?? [];
    return FaqCategory(
      category: json['category'] ?? '',
      faqs: list.map((e) => FaqItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
