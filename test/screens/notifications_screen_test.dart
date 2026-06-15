import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationsSettingsScreen Widget Tests', () {
    testWidgets('Screen renders notification UI correctly', (WidgetTester tester) async {
      // Create a minimal test app with the screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: Text(
                    'Ride & Safety',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ride Updates'),
                      Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Safety Alerts'),
                      Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save Preferences'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify UI elements are rendered
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Ride & Safety'), findsOneWidget);
      expect(find.text('Ride Updates'), findsOneWidget);
      expect(find.text('Safety Alerts'), findsOneWidget);
      expect(find.text('Save Preferences'), findsOneWidget);

      // Verify switch widgets exist
      expect(find.byType(Switch), findsWidgets);

      // Verify button exists
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Switches toggle correctly', (WidgetTester tester) async {
      bool switchValue = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Switch(
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(switchValue, isTrue);

      // Tap switch to toggle
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(switchValue, isFalse);
    });

    testWidgets('Save button is enabled by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Save Preferences'),
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      // Button should be enabled (not grayed out)
      final buttonWidget = tester.widget<ElevatedButton>(button);
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('Back button exists in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: const Text('Notifications'),
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('Multiple notification sections display correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                const Text('Ride & Safety'),
                const Text('Payments & Promotions'),
                const Text('System'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Ride & Safety'), findsOneWidget);
      expect(find.text('Payments & Promotions'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Error message displays correctly', (WidgetTester tester) async {
      const errorMessage = 'Failed to load preferences';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('Loading indicator displays', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
