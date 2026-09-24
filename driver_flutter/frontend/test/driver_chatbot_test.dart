import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gorush_driver/main.dart';
import 'package:gorush_driver/core/demo_controller.dart';
import 'package:gorush_driver/screens/driver_chatbot_screen.dart';

void main() {
  group('GoRush Driver Floating Chatbot & Navigation Tests', () {
    testWidgets('1. Floating Chatbot button at bottom-right opens full screen ChatGPT/Meta AI UI',
        (tester) async {
      await tester.pumpWidget(
        const QuickServeDriverApp(
          initialScreen: DemoScreen.driverHomeDashboard,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Support circle is restored
      expect(find.text('Support'), findsOneWidget);

      // Tap on bottom-right Floating Chatbot button (chat_bubble_rounded)
      final floatingChatbot = find.byIcon(Icons.chat_bubble_rounded);
      expect(floatingChatbot, findsOneWidget);
      await tester.tap(floatingChatbot);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Chatbot Screen is displayed
      expect(find.byType(DriverChatbotScreen), findsOneWidget);
      expect(find.text('GoRush Saathi AI'), findsOneWidget);
      expect(find.textContaining('Online • AI Partner'), findsOneWidget);

      // Verify Initial greeting
      expect(find.textContaining('GoRush Saathi AI assistant'), findsOneWidget);

      // Verify Send input field
      expect(find.byType(TextField), findsOneWidget);

      // Test sending a message
      await tester.enterText(find.byType(TextField), 'How are my earnings calculated?');
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();

      // Verify user message appears in list
      expect(find.text('How are my earnings calculated?'), findsOneWidget);

      // Wait for AI response
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.textContaining('Earnings Summary'), findsOneWidget);

      // Verify Back button returns to Home Dashboard
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(DriverChatbotScreen), findsNothing);
      expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
    });

    testWidgets('2. Header does not have Chatbot icon (only Notification Bell)',
        (tester) async {
      await tester.pumpWidget(
        const QuickServeDriverApp(
          initialScreen: DemoScreen.driverHomeDashboard,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify notification bell is present
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      // Verify no robot icon anywhere
      expect(find.byIcon(Icons.smart_toy_rounded), findsNothing);
    });
  });
}
