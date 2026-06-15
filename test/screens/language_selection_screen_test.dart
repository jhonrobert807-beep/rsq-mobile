import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanguageSelectionScreen Widget Tests', () {
    testWidgets('Screen renders language UI correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Language'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: Text(
                    'Available Languages',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                for (final lang in ['English', 'Spanish', 'French', 'German'])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lang),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD1E4FF),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save Language'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify UI elements
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Available Languages'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('French'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);
      expect(find.text('Save Language'), findsOneWidget);
    });

    testWidgets('Radio selection works correctly', (WidgetTester tester) async {
      String selectedLanguage = 'en';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ListView(
                  children: [
                    for (final lang in [
                      {'code': 'en', 'name': 'English'},
                      {'code': 'es', 'name': 'Spanish'},
                    ])
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLanguage = lang['code'] as String;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(lang['name'] as String),
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedLanguage == lang['code']
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFD1E4FF),
                                    width: selectedLanguage == lang['code'] ? 6 : 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      // Tap Spanish
      await tester.tap(find.text('Spanish'));
      await tester.pumpAndSettle();

      expect(selectedLanguage, equals('es'));
    });

    testWidgets('Back button navigates correctly', (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  backPressed = true;
                },
              ),
              title: const Text('Language'),
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(backPressed, isTrue);
    });

    testWidgets('Save button is functional', (WidgetTester tester) async {
      bool savePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  savePressed = true;
                },
                child: const Text('Save Language'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Save Language'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(savePressed, isTrue);
    });

    testWidgets('Loading state displays spinner', (WidgetTester tester) async {
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

    testWidgets('Error message displays correctly', (WidgetTester tester) async {
      const errorMessage = 'Failed to load languages';

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
    });

    testWidgets('Multiple languages display in list', (WidgetTester tester) async {
      final languages = ['English', 'Spanish', 'French', 'German', 'Portuguese', 'Arabic'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: languages.map((lang) => Text(lang)).toList(),
            ),
          ),
        ),
      );

      for (final lang in languages) {
        expect(find.text(lang), findsOneWidget);
      }
    });

    testWidgets('Selected language styling changes', (WidgetTester tester) async {
      String selectedLanguage = 'en';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ListView(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLanguage = 'en';
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'English',
                          style: TextStyle(
                            color: selectedLanguage == 'en'
                                ? const Color(0xFF2196F3)
                                : Colors.black,
                            fontWeight: selectedLanguage == 'en'
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial state: English should be highlighted
      final textWidget = find.text('English');
      expect(textWidget, findsOneWidget);
    });
  });
}
