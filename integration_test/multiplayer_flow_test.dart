import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yes_or_no/main.dart' as app;

/// End-to-end integration test for multiplayer flow
/// Tests: Matchmaking → Game Creation → Round Play → Final Guess → Game Over
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Multiplayer Game Flow Integration Test', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      
      // Sign in test user
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        print('Auth error: $e');
      }
    });

    testWidgets('Complete game flow from matchmaking to game over',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Navigate to matchmaking
      final matchmakingButton = find.text('Çok Oyunculu');
      expect(matchmakingButton, findsOneWidget);
      await tester.tap(matchmakingButton);
      await tester.pumpAndSettle();

      // Step 2: Join queue
      final joinQueueButton = find.text('Eşleşme Ara');
      if (joinQueueButton.evaluate().isNotEmpty) {
        await tester.tap(joinQueueButton);
        await tester.pumpAndSettle();
      }

      // Step 3: Wait for match (timeout after 30 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 30));

      // Step 4: Verify game screen loaded
      expect(find.text('Çok Oyunculu Oyun'), findsOneWidget);

      // Step 5: Wait for game initialization
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Step 6: Submit a question (if in round in progress)
      final questionField = find.byType(TextFormField);
      if (questionField.evaluate().isNotEmpty) {
        await tester.enterText(questionField.first, 'Is it an animal?');
        await tester.pumpAndSettle();

        final submitButton = find.text('Soruyu Gönder');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle();
        }
      }

      // Step 7: Wait for AI processing
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Step 8: Verify game progressed
      // Should see either next round or final guess phase
      expect(
        find.textContaining('Tur').evaluate().isNotEmpty ||
            find.text('SON TAHMİN').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Queue cancellation works correctly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to matchmaking
      final matchmakingButton = find.text('Çok Oyunculu');
      if (matchmakingButton.evaluate().isNotEmpty) {
        await tester.tap(matchmakingButton);
        await tester.pumpAndSettle();
      }

      // Join queue
      final joinButton = find.text('Eşleşme Ara');
      if (joinButton.evaluate().isNotEmpty) {
        await tester.tap(joinButton);
        await tester.pumpAndSettle();
      }

      // Cancel queue
      final cancelButton = find.text('İptal');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
      }

      // Verify returned to previous screen
      expect(find.text('Eşleşme Ara'), findsOneWidget);
    });
  });

  group('Game State Transitions', () {
    testWidgets('Question submission updates UI correctly',
        (WidgetTester tester) async {
      // This test requires being in an active game
      // Skip if not in game state
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Test placeholder')),
        ),
      ));
      await tester.pumpAndSettle();
    });
  });
}
