import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gorush_driver/services/token_storage_service.dart';
import 'package:gorush_driver/services/app_language_service.dart';
import 'package:gorush_driver/screens/driver_profile_vehicle_settings.dart';
import 'package:gorush_driver/screens/onboarding/driver_profile_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TokenStorageService.instance.init();
    await AppLanguageService.instance.init();
  });

  tearDown(() async {
    await TokenStorageService.instance.clearSession();
  });

  group('Registered Driver Details Must Appear in Profile - Complete Verification', () {
    const testRegistration = {
      'name': 'Aditya Birla',
      'phone': '9876543210',
      'email': 'aditya.birla@gmail.com',
      'licenseNumber': 'MH-02-2026-009988',
      'vehicleId': 'MH 02 AB 1234',
      'status': 'offline',
    };

    testWidgets('1. Profile screen displays the EXACT registered driver information', (WidgetTester tester) async {
      // Simulate successful registration & login session saving
      await TokenStorageService.instance.saveSession(
        accessToken: 'mock_jwt_token_for_aditya',
        driverProfile: Map<String, dynamic>.from(testRegistration),
      );

      // Verify token storage
      expect(TokenStorageService.instance.isAuthenticated, isTrue);
      expect(TokenStorageService.instance.driverProfile?['name'], 'Aditya Birla');
      expect(TokenStorageService.instance.driverProfile?['phone'], '9876543210');
      expect(TokenStorageService.instance.driverProfile?['email'], 'aditya.birla@gmail.com');
      expect(TokenStorageService.instance.driverProfile?['licenseNumber'], 'MH-02-2026-009988');

      // Pump Profile Screen
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverProfileVehicleSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert that actual registered details appear on screen
      expect(find.text('Aditya Birla'), findsOneWidget);
      expect(find.textContaining('9876543210'), findsWidgets);
      expect(find.textContaining('aditya.birla@gmail.com'), findsWidgets);
      expect(find.textContaining('MH-02-2026-009988'), findsWidgets);

      // Confirm no dummy/demo fallback data appears
      expect(find.text('Rohit Sharma'), findsNothing);
      expect(find.textContaining('rohit.sharma@gorush.com'), findsNothing);
      expect(find.text('Partner Driver'), findsNothing);
    });

    testWidgets('2. Edit Profile pre-fills registered data and dynamically refreshes Profile screen', (WidgetTester tester) async {
      await TokenStorageService.instance.saveSession(
        accessToken: 'mock_jwt_token_for_aditya',
        driverProfile: Map<String, dynamic>.from(testRegistration),
      );

      // Pump Edit Profile Screen
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverProfileSetupScreen(isEditing: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify registered data is pre-filled in editable fields
      expect(find.widgetWithText(TextField, 'Aditya Birla'), findsOneWidget);
      expect(find.widgetWithText(TextField, '9876543210'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'aditya.birla@gmail.com'), findsOneWidget);

      // Perform simulated update in TokenStorageService (as done by DriverBackendService.instance.updateProfile)
      await TokenStorageService.instance.updateProfile(
        name: 'Aditya V. Birla',
        city: 'Mumbai Nariman Point',
        address: 'Birla Tower, Nariman Point, Mumbai - 400021',
      );

      // Re-pump Profile screen
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverProfileVehicleSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify updated name appears immediately on Profile screen
      expect(find.text('Aditya V. Birla'), findsOneWidget);
      expect(find.text('Aditya Birla'), findsNothing);
      expect(find.textContaining('9876543210'), findsWidgets);
      expect(find.textContaining('MH-02-2026-009988'), findsWidgets);
    });
  });
}
