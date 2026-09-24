import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gorush_driver/screens/onboarding/driver_login_registration.dart';

void main() {
  testWidgets('Create Account Screen matches Image 2 specs precisely', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: DriverLoginRegistrationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand Logo & Titles
    expect(find.text('GoRush'), findsOneWidget);
    expect(find.text('Driver App'), findsOneWidget);

    // Verify Headline & Subtitle
    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Join GoRush and start earning today!'), findsOneWidget);

    // Verify all 6 placeholder hints
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Vehicle Number'), findsOneWidget);
    expect(find.text('License Number'), findsOneWidget);

    // Verify Register CTA button
    expect(find.text('Register'), findsOneWidget);

    // Verify Login link
    expect(find.text('Already have an account? '), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify Footer illustration
    expect(find.byType(Image), findsOneWidget);
  });
}
