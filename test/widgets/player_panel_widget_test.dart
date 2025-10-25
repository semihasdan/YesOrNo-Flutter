import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yes_or_no/models/multiplayer_game_session.dart';
import 'package:yes_or_no/models/player_data.dart';
import 'package:yes_or_no/widgets/player_panel_widget.dart';

void main() {
  group('PlayerPanelWidget Tests', () {
    testWidgets('displays player information correctly', (WidgetTester tester) async {
      final playerData = PlayerData(
        username: 'TestPlayer',
        avatarUrl: 'https://example.com/avatar.jpg',
        avatarFrameId: 'frame_gold',
        remainingGuesses: 3,
        currentQuestion: null,
        lastAnswer: null,
        isReadyForNextRound: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerPanelWidget(
              playerData: playerData,
              isCurrentUser: true,
            ),
          ),
        ),
      );

      expect(find.text('TestPlayer'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.stars), findsOneWidget);
    });

    testWidgets('shows ready status when player is ready', (WidgetTester tester) async {
      final playerData = PlayerData(
        username: 'TestPlayer',
        avatarUrl: '',
        avatarFrameId: '',
        remainingGuesses: 2,
        currentQuestion: 'Test question?',
        lastAnswer: null,
        isReadyForNextRound: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerPanelWidget(
              playerData: playerData,
            ),
          ),
        ),
      );

      expect(find.text('Hazır'), findsOneWidget);
    });

    testWidgets('shows submitted status indicator', (WidgetTester tester) async {
      final playerData = PlayerData(
        username: 'TestPlayer',
        avatarUrl: '',
        avatarFrameId: '',
        remainingGuesses: 3,
        currentQuestion: 'Is it an animal?',
        lastAnswer: null,
        isReadyForNextRound: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerPanelWidget(
              playerData: playerData,
              showStatus: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('PlayerAnswerWidget Tests', () {
    testWidgets('displays YES answer correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAnswerWidget(
              answer: 'YES',
              isRevealed: true,
            ),
          ),
        ),
      );

      expect(find.text('EVET'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays NO answer correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAnswerWidget(
              answer: 'NO',
              isRevealed: true,
            ),
          ),
        ),
      );

      expect(find.text('HAYIR'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('displays NEUTRAL answer correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAnswerWidget(
              answer: 'NEUTRAL',
              isRevealed: true,
            ),
          ),
        ),
      );

      expect(find.text('BİLİNMİYOR'), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('hides answer when not revealed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerAnswerWidget(
              answer: 'YES',
              isRevealed: false,
            ),
          ),
        ),
      );

      expect(find.text('???'), findsOneWidget);
      expect(find.text('EVET'), findsNothing);
    });
  });
}
