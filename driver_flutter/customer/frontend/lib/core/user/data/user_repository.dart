import 'package:dio/dio.dart';
import '../domain/user_models.dart';

abstract class UserRepository {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
  Future<NotificationSettingsModel> getNotifications();
  Future<NotificationSettingsModel> updateNotifications(Map<String, dynamic> settings);
  Future<PrivacySettingsModel> getPrivacy();
  Future<PrivacySettingsModel> updatePrivacy(Map<String, dynamic> settings);
  Future<Map<String, dynamic>> requestAccountDeletion(String reason, {String? details});
  Future<List<FaqCategory>> getSupportFaqs();
}

class HttpUserRepository implements UserRepository {
  static UserProfileModel? _activeUser;

  static void setActiveUser(UserProfileModel user) {
    _activeUser = user;
  }

  static void clearActiveUser() {
    _activeUser = null;
  }

  static UserProfileModel? get activeUser => _activeUser;

  final Dio _dio;
  final MockUserRepository _fallback = MockUserRepository();

  HttpUserRepository({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'http://localhost:3001/v1'));

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final token = _activeUser?.userId ?? 'cust_123';
      final res = await _dio.get(
        '/user/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final profile = UserProfileModel.fromJson(res.data as Map<String, dynamic>);
      _activeUser = profile;
      return profile;
    } catch (_) {
      if (_activeUser != null) {
        return _activeUser!;
      }
      return _fallback.getProfile();
    }
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = _activeUser?.userId ?? 'cust_123';
      final res = await _dio.patch(
        '/user/profile',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final updated = UserProfileModel.fromJson(res.data as Map<String, dynamic>);
      _activeUser = updated;
      return updated;
    } catch (_) {
      final updated = await _fallback.updateProfile(data);
      _activeUser = updated;
      return updated;
    }
  }

  @override
  Future<NotificationSettingsModel> getNotifications() async {
    try {
      final res = await _dio.get(
        '/user/notifications',
        options: Options(headers: {'Authorization': 'Bearer mock_access_token'}),
      );
      return NotificationSettingsModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _fallback.getNotifications();
    }
  }

  @override
  Future<NotificationSettingsModel> updateNotifications(Map<String, dynamic> settings) async {
    try {
      final res = await _dio.patch(
        '/user/notifications',
        data: settings,
        options: Options(headers: {'Authorization': 'Bearer mock_access_token'}),
      );
      return NotificationSettingsModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _fallback.updateNotifications(settings);
    }
  }

  @override
  Future<PrivacySettingsModel> getPrivacy() async {
    try {
      final res = await _dio.get(
        '/user/privacy',
        options: Options(headers: {'Authorization': 'Bearer mock_access_token'}),
      );
      return PrivacySettingsModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _fallback.getPrivacy();
    }
  }

  @override
  Future<PrivacySettingsModel> updatePrivacy(Map<String, dynamic> settings) async {
    try {
      final res = await _dio.patch(
        '/user/privacy',
        data: settings,
        options: Options(headers: {'Authorization': 'Bearer mock_access_token'}),
      );
      return PrivacySettingsModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _fallback.updatePrivacy(settings);
    }
  }

  @override
  Future<Map<String, dynamic>> requestAccountDeletion(String reason, {String? details}) async {
    try {
      final res = await _dio.delete(
        '/user/account',
        data: {'reason': reason, 'details': details},
        options: Options(headers: {'Authorization': 'Bearer mock_access_token'}),
      );
      return res.data as Map<String, dynamic>;
    } catch (_) {
      return _fallback.requestAccountDeletion(reason, details: details);
    }
  }

  @override
  Future<List<FaqCategory>> getSupportFaqs() async {
    try {
      final res = await _dio.get(
        '/user/support/faqs',
        options: Options(headers: {'Authorization': 'Bearer mock_access_token'}),
      );
      final list = res.data as List;
      return list.map((e) => FaqCategory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _fallback.getSupportFaqs();
    }
  }
}

class MockUserRepository implements UserRepository {
  UserProfileModel _profile = UserProfileModel(
    userId: 'cust_123',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+91 98765 43210',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
    gender: 'Male',
    memberTier: 'GOLD',
    memberSince: 'January 2025',
    emergencyContacts: [
      EmergencyContact(name: 'Sarah Doe', phone: '+91 98765 00001', relationship: 'Spouse'),
      EmergencyContact(name: 'David Doe', phone: '+91 98765 00002', relationship: 'Brother'),
    ],
    rating: 4.92,
    totalTrips: 48,
  );

  NotificationSettingsModel _notifications = NotificationSettingsModel(
    pushEnabled: true,
    smsEnabled: true,
    promoOffersEnabled: false,
    tripStatusAlerts: true,
    safetyAlerts: true,
    soundVibrationEnabled: true,
  );

  PrivacySettingsModel _privacy = PrivacySettingsModel(
    locationPermission: 'WHILE_USING',
    shareLiveTripWithEmergency: true,
    personalizedAdsConsent: false,
    analyticsConsent: true,
    dataRetentionYears: 3,
  );

  @override
  Future<UserProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile;
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _profile = UserProfileModel(
      userId: _profile.userId,
      name: data['name'] ?? _profile.name,
      email: data['email'] ?? _profile.email,
      phone: data['phone'] ?? _profile.phone,
      avatarUrl: data['avatarUrl'] ?? _profile.avatarUrl,
      gender: data['gender'] ?? _profile.gender,
      memberTier: _profile.memberTier,
      memberSince: _profile.memberSince,
      emergencyContacts: data['emergencyContacts'] != null
          ? (data['emergencyContacts'] as List).map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>)).toList()
          : _profile.emergencyContacts,
      rating: _profile.rating,
      totalTrips: _profile.totalTrips,
    );
    return _profile;
  }

  @override
  Future<NotificationSettingsModel> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _notifications;
  }

  @override
  Future<NotificationSettingsModel> updateNotifications(Map<String, dynamic> settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications = NotificationSettingsModel(
      pushEnabled: settings['pushEnabled'] ?? _notifications.pushEnabled,
      smsEnabled: settings['smsEnabled'] ?? _notifications.smsEnabled,
      promoOffersEnabled: settings['promoOffersEnabled'] ?? _notifications.promoOffersEnabled,
      tripStatusAlerts: settings['tripStatusAlerts'] ?? _notifications.tripStatusAlerts,
      safetyAlerts: settings['safetyAlerts'] ?? _notifications.safetyAlerts,
      soundVibrationEnabled: settings['soundVibrationEnabled'] ?? _notifications.soundVibrationEnabled,
    );
    return _notifications;
  }

  @override
  Future<PrivacySettingsModel> getPrivacy() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _privacy;
  }

  @override
  Future<PrivacySettingsModel> updatePrivacy(Map<String, dynamic> settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _privacy = PrivacySettingsModel(
      locationPermission: settings['locationPermission'] ?? _privacy.locationPermission,
      shareLiveTripWithEmergency: settings['shareLiveTripWithEmergency'] ?? _privacy.shareLiveTripWithEmergency,
      personalizedAdsConsent: settings['personalizedAdsConsent'] ?? _privacy.personalizedAdsConsent,
      analyticsConsent: settings['analyticsConsent'] ?? _privacy.analyticsConsent,
      dataRetentionYears: settings['dataRetentionYears'] ?? _privacy.dataRetentionYears,
    );
    return _privacy;
  }

  @override
  Future<Map<String, dynamic>> requestAccountDeletion(String reason, {String? details}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'requestId': 'del_req_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'PENDING_GRACE_PERIOD',
      'requestedAt': DateTime.now().toIso8601String(),
      'scheduledPermanentDeletionAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'gracePeriodDaysRemaining': 30,
    };
  }

  @override
  Future<List<FaqCategory>> getSupportFaqs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      FaqCategory(
        category: 'Rides & Booking',
        faqs: [
          FaqItem(question: 'How do I schedule a ride in advance?', answer: 'Tap the Schedule icon on the home screen and select your desired pickup time up to 7 days ahead.'),
          FaqItem(question: 'What is the OTP verification for?', answer: 'The 4-digit OTP code ensures you enter the correct vehicle assigned to your booking.'),
        ],
      ),
      FaqCategory(
        category: 'Payments & Fare',
        faqs: [
          FaqItem(question: 'How are fares calculated?', answer: 'Fares are upfront prices based on base fare, distance, estimated travel time, platform fee, and GST.'),
          FaqItem(question: 'When will I receive my refund?', answer: 'Wallet refunds are instant. Bank refunds take 2-3 business days.'),
        ],
      ),
      FaqCategory(
        category: 'Safety & Emergency',
        faqs: [
          FaqItem(question: 'What is the SOS button for?', answer: 'SOS alerts our 24/7 Safety Command Center, shares live GPS with emergency contacts, and dials 112.'),
          FaqItem(question: 'Is my phone number shared with drivers?', answer: 'No, all communication uses 256-bit masked private relays.'),
        ],
      ),
    ];
  }
}
