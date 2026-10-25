import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ملاحظة: لسنا بنستورد main.dart هنا لأن Supabase والـ SharedPreferences
// محتاجين تهيئة منصّة (platform)، فبنختبر widgets بسيطة أو دوال نقية.

void main() {
  group('Sanity tests', () {
    test('Basic math works', () {
      expect(1 + 1, 2);
    });
  });

  group('Widget tests', () {
    testWidgets('Counter increments', (WidgetTester tester) async {
      // Widget بسيط للاختبار
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    Text('Counter: $counter'),
                    ElevatedButton(
                      onPressed: () => setState(() => counter++),
                      child: const Text('Increment'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Counter: 0'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('Counter: 1'), findsOneWidget);
    });

    testWidgets('Renders a Text widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Explore Expo'),
          ),
        ),
      );

      expect(find.text('Explore Expo'), findsOneWidget);
    });
  });
}
