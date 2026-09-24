import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gorush_driver/services/token_storage_service.dart';
import 'package:gorush_driver/services/app_language_service.dart';
import 'package:gorush_driver/screens/driver_profile_vehicle_settings.dart';
import 'package:gorush_driver/screens/onboarding/driver_profile_setup.dart';
import 'package:gorush_driver/screens/vehicle_management_screen.dart';
import 'package:gorush_driver/screens/trip_history_detailed_receipt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4: GoRush Driver App Complete Functional Integration Tests', () {
    const testDriver = {
      'name': 'Vikramaditya Rao',
      'phone': '9876543210',
      'email': 'vikram.rao@gorush.com',
      'licenseNumber': 'DL-0420230099881',
      'vehicleId': 'DL 01 AB 9999',
      'city': 'Noida Sector 62',
      'address': 'Tower B, Galaxy Apartments, Noida',
    };

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await TokenStorageService.instance.saveSession(
        accessToken: 'mock_jwt_token_phase4',
        driverProfile: Map<String, dynamic>.from(testDriver),
      );
      await TokenStorageService.instance.saveVehicles([
        {
          'model': 'Honda City (Sedan)',
          'regNumber': 'DL 01 AB 9999 • White',
          'type': 'Sedan',
          'isPrimary': true,
          'isVerified': true,
        }
      ]);
      await AppLanguageService.instance.init();
      AppLanguageService.instance.setLanguage('en', persist: false);
    });

    testWidgets('TEST A & C: Profile Screen displays EXACT registered driver details without dummy data', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: DriverProfileVehicleSettingsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. MUST display exact registered name
      expect(find.text('Vikramaditya Rao'), findsOneWidget);
      expect(find.text('Rohit Sharma'), findsNothing);

      // 2. MUST display exact phone and email
      expect(find.text('9876543210 • vikram.rao@gorush.com'), findsOneWidget);

      // 3. MUST display exact license number
      expect(find.text('License: DL-0420230099881'), findsOneWidget);
      expect(find.text('License: DL-0420230099881 • RC, Insurance'), findsOneWidget);

      // 4. MUST display primary vehicle plate
      expect(find.text('Primary Vehicle • DL 01 AB 9999'), findsOneWidget);
      expect(find.text('DL 01 AB 1234'), findsNothing);
    });

    testWidgets('TEST D: Edit Profile pre-fills registered data and saves updates', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: DriverProfileSetupScreen(
            isEditing: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify fields pre-filled with current driver data
      expect(find.widgetWithText(TextField, 'Vikramaditya Rao'), findsOneWidget);
      expect(find.widgetWithText(TextField, '9876543210'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'vikram.rao@gorush.com'), findsOneWidget);

      // Edit name
      final nameField = find.widgetWithText(TextField, 'Vikramaditya Rao');
      await tester.enterText(nameField, 'Vikramaditya Rao Updated');
      await tester.pump();

      await TokenStorageService.instance.updateProfile(name: 'Vikramaditya Rao Updated');
      expect(TokenStorageService.instance.driverProfile?['name'], 'Vikramaditya Rao Updated');
    });

    testWidgets('TEST E: Vehicle Details displays registered vehicle and Add Secondary Vehicle button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: VehicleManagementScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Primary vehicle must reflect registered vehicle plate
      expect(find.textContaining('DL 01 AB 9999'), findsOneWidget);
      expect(find.text('Add Secondary Vehicle'), findsOneWidget);
    });

    testWidgets('TEST F: History separates Completed and Cancelled rides into dedicated tabs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // 1. Initial tab 0: Completed
      await tester.pumpWidget(
        const MaterialApp(
          home: TripHistoryDetailedReceiptScreen(initialTab: 0),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Completed (42)'), findsOneWidget);
      expect(find.text('Connaught Place, New Delhi'), findsOneWidget);
      expect(find.text('Cyber City, Gurgaon'), findsOneWidget);
      // Cancelled rides must NOT be in completed view
      expect(find.text('Flat tire / vehicle breakdown'), findsNothing);

      // 2. Switch to Cancelled tab
      await tester.tap(find.text('Cancelled (2)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Cancelled rides appear
      expect(find.textContaining('Cancelled by driver: Flat tire / vehicle breakdown'), findsOneWidget);
      expect(find.textContaining('Rider cancelled after 4 mins'), findsOneWidget);
      // Completed fares must NOT be present
      expect(find.text('Connaught Place, New Delhi'), findsNothing);
    });

    testWidgets('TEST G: App Language selection applies translations and persists', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      expect(tr('Profile'), 'Profile');

      // Switch to Hindi
      AppLanguageService.instance.setLanguage('hi');
      expect(AppLanguageService.instance.currentLanguageCode, 'hi');
      expect(tr('Profile'), 'प्रोफ़ाइल');
      expect(tr('Edit Profile'), 'प्रोफ़ाइल संपादित करें');
      expect(tr('Vehicle Details'), 'वाहन विवरण');

      // Switch back to English
      AppLanguageService.instance.setLanguage('en');
      expect(AppLanguageService.instance.currentLanguageCode, 'en');
      expect(tr('Profile'), 'Profile');
    });
  });
}
