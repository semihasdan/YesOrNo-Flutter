import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yes_or_no/widgets/countdown_timer_widget.dart';

void main() {
  group('CountdownTimerWidget Tests', () {
    testWidgets('displays initial time correctly', (WidgetTester tester) async {
      final endTime = DateTime.now().add(const Duration(seconds: 10));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerWidget(
              endTime: endTime,
              showText: true,
            ),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });

    testWidgets('updates countdown every second', (WidgetTester tester) async {
      final endTime = DateTime.now().add(const Duration(seconds: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerWidget(
              endTime: endTime,
              showText: true,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('calls onTimerEnd when timer expires', (WidgetTester tester) async {
      bool callbackCalled = false;
      final endTime = DateTime.now().add(const Duration(seconds: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerWidget(
              endTime: endTime,
              onTimerEnd: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // Wait for timer to expire
      await tester.pump(const Duration(seconds: 3));

      expect(callbackCalled, isTrue);
    });

    testWidgets('shows correct color based on remaining time', (WidgetTester tester) async {
      final endTime = DateTime.now().add(const Duration(seconds: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerWidget(
              endTime: endTime,
              activeColor: Colors.green,
              warningColor: Colors.orange,
              dangerColor: Colors.red,
              dangerThreshold: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be in danger zone (red) since remaining time <= 3 seconds
      final textWidget = tester.widget<Text>(find.byType(Text).first);
      expect(textWidget.style?.color, equals(Colors.red));
    });
  });

  group('CountdownTimerBar Tests', () {
    testWidgets('displays linear progress bar', (WidgetTester tester) async {
      final endTime = DateTime.now().add(const Duration(seconds: 10));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerBar(
              endTime: endTime,
              showText: true,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('10 saniye'), findsOneWidget);
    });

    testWidgets('updates progress value over time', (WidgetTester tester) async {
      final endTime = DateTime.now().add(const Duration(seconds: 10));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerBar(
              endTime: endTime,
            ),
          ),
        ),
      );

      final initialProgressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final initialValue = initialProgressBar.value;

      await tester.pump(const Duration(seconds: 2));

      final updatedProgressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final updatedValue = updatedProgressBar.value;

      expect(updatedValue, lessThan(initialValue ?? 1.0));
    });
  });
}
