import 'package:flutter_test/flutter_test.dart';
import 'package:gorush_driver/main.dart';
import 'package:gorush_driver/widgets/floating_sos_button.dart';

void main() {
  group('Retired auto-demo specifications', () {
    testWidgets('1. Directly launches into Driver Home Dashboard with HUD (No Login, OTP, Onboarding)', (WidgetTester tester) async {
      await tester.pumpWidget(const GoRushDriverApp());
      await tester.pump();

      // Verify Driver Home Dashboard is shown directly
      expect(find.text('STEP 1/13'), findsOneWidget);
      expect(find.text('Driver Home Dashboard'), findsOneWidget);
      expect(find.text('Rajesh Verma'), findsOneWidget);
      expect(find.text('AAJ KI KAMAI'), findsOneWidget);
      expect(find.text('ONLINE LIVE'), findsOneWidget);

      // Verify that Login, OTP, and Onboarding are absent
      expect(find.text('Enter Mobile Number'), findsNothing);
      expect(find.text('Verify OTP'), findsNothing);
      expect(find.text('Driver Registration'), findsNothing);
    });

    testWidgets('2. Automatic 5-second timer transitions smoothly to next screen', (WidgetTester tester) async {
      await tester.pumpWidget(const GoRushDriverApp());
      await tester.pump();

      expect(find.text('STEP 1/13'), findsOneWidget);
      expect(find.text('Driver Home Dashboard'), findsOneWidget);

      // Advance by 5.2 seconds
      await tester.pump(const Duration(seconds: 5, milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      // Should automatically be at Screen 02: Incoming Ride Request
      expect(find.text('STEP 2/13'), findsOneWidget);
      expect(find.text('Incoming Ride Request'), findsOneWidget);
      expect(find.text('₹485'), findsOneWidget);
      expect(find.text('Net Kamai'), findsOneWidget);

      // Advance another 5.2 seconds -> Screen 03: Passenger Chat
      await tester.pump(const Duration(seconds: 5, milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('STEP 3/13'), findsOneWidget);
      expect(find.text('Passenger Chat & Pickup'), findsOneWidget);
      expect(find.text('Aman Verma'), findsOneWidget);
    });

    testWidgets('3. Manual screen touch automatically pauses the 5s auto-flow and displays Paused state', (WidgetTester tester) async {
      await tester.pumpWidget(const GoRushDriverApp());
      await tester.pump();

      expect(find.byTooltip('Pause Auto 5s Flow'), findsOneWidget);

      // User taps or touches anywhere on the dashboard
      final earningsCard = find.text('AAJ KI KAMAI');
      expect(earningsCard, findsOneWidget);
      await tester.tap(earningsCard);
      await tester.pump(const Duration(milliseconds: 500));

      // After tap, controller pauses automatic progression
      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.textContaining('Auto flow paused'), findsOneWidget);
      expect(find.byTooltip('Resume Auto 5s Flow'), findsOneWidget);

      // Pump 10 seconds while paused -> Should stay on the same screen (Screen 6 Earnings)
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('STEP 6/13'), findsOneWidget);
      expect(find.text('Earnings & Instant Payout'), findsOneWidget);

      // Resume by tapping the HUD play button
      final resumeBtn = find.byTooltip('Resume Auto 5s Flow');
      expect(resumeBtn, findsOneWidget);
      await tester.tap(resumeBtn);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byTooltip('Pause Auto 5s Flow'), findsOneWidget);

      // Pump 5.2 seconds after resumption -> Advances to Screen 7 (Incentives)
      await tester.pump(const Duration(seconds: 5, milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('STEP 7/13'), findsOneWidget);
      expect(find.text('Incentives & Weekly Quests'), findsOneWidget);
    });

    testWidgets('4. Dashboard shortcuts navigate directly to target demo screens and return via Bottom Nav', (WidgetTester tester) async {
      await tester.pumpWidget(const GoRushDriverApp());
      await tester.pump();

      // Tap SOS button in floating bar -> Screen 12
      final sosButton = find.byType(FloatingSosButton);
      expect(sosButton, findsOneWidget);
      await tester.tap(sosButton);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('STEP 12/13'), findsOneWidget);
      expect(find.text('Safety Hub & SOS Center'), findsOneWidget);

      // Tap HUD Next button -> Screen 13
      final nextBtn = find.byTooltip('Next Screen');
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('STEP 13/13'), findsOneWidget);
      expect(find.text('Help Center & Support'), findsOneWidget);

      // Next wraps to Screen 1 Driver Home Dashboard
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('STEP 1/13'), findsOneWidget);
      expect(find.text('Driver Home Dashboard'), findsOneWidget);

      // Tap Bottom Nav Trips -> Screen 5
      final tripsTab = find.text('Trips').last;
      await tester.tap(tripsTab);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('STEP 5/13'), findsOneWidget);
      expect(find.text('Trip History & Receipt'), findsOneWidget);

      // Tap Bottom Nav Radar (Home) -> Screen 1
      final radarTab = find.text('Radar').last;
      await tester.tap(radarTab);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('STEP 1/13'), findsOneWidget);
      expect(find.text('Driver Home Dashboard'), findsOneWidget);
    });

    testWidgets('5. Full 13-screen loop seamlessly wraps from Help Center back to Driver Home', (WidgetTester tester) async {
      await tester.pumpWidget(const GoRushDriverApp());
      await tester.pump();

      // Jump to Screen 13 (Help & Support) via HUD next buttons
      final nextBtn = find.byTooltip('Next Screen');
      for (int i = 0; i < 12; i++) {
        await tester.tap(nextBtn);
        await tester.pump(const Duration(milliseconds: 450));
      }

      expect(find.text('STEP 13/13'), findsOneWidget);
      expect(find.text('Help Center & Support'), findsOneWidget);

      // Next screen wraps back to Screen 01 (Driver Home Dashboard)
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 450));

      expect(find.text('STEP 1/13'), findsOneWidget);
      expect(find.text('Driver Home Dashboard'), findsOneWidget);
    });
  }, skip: 'The retired auto-demo is not part of the approved production driver UI.');
}
