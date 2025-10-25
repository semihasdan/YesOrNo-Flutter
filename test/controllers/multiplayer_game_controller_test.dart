import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:yes_or_no/controllers/multiplayer_game_controller.dart';
import 'package:yes_or_no/providers/multiplayer_game_provider.dart';
import 'package:yes_or_no/models/multiplayer_game_session.dart';
import 'package:yes_or_no/models/player_data.dart';

@GenerateMocks([MultiplayerGameProvider])
import 'multiplayer_game_controller_test.mocks.dart';

void main() {
  group('MultiplayerGameController Tests', () {
    late MockMultiplayerGameProvider mockProvider;
    late MultiplayerGameController controller;
    const String currentUserId = 'user_123';

    setUp(() {
      mockProvider = MockMultiplayerGameProvider();
      controller = MultiplayerGameController(
        gameProvider: mockProvider,
        currentUserId: currentUserId,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    group('Question Validation', () {
      test('rejects null or empty question', () {
        expect(controller.validateQuestion(null), isNotNull);
        expect(controller.validateQuestion(''), isNotNull);
        expect(controller.validateQuestion('   '), isNotNull);
      });

      test('rejects question that is too short', () {
        expect(controller.validateQuestion('No'), isNotNull);
        expect(controller.validateQuestion('Yes'), isNotNull);
      });

      test('rejects question that is too long', () {
        final longQuestion = 'a' * 201;
        expect(controller.validateQuestion(longQuestion), isNotNull);
      });

      test('rejects question without question mark', () {
        expect(controller.validateQuestion('Is this valid'), isNotNull);
      });

      test('accepts valid question', () {
        expect(controller.validateQuestion('Is it an animal?'), isNull);
        expect(controller.validateQuestion('Does it have fur?'), isNull);
      });
    });

    group('Guess Validation', () {
      test('rejects null or empty guess', () {
        expect(controller.validateGuess(null), isNotNull);
        expect(controller.validateGuess(''), isNotNull);
        expect(controller.validateGuess('   '), isNotNull);
      });

      test('rejects guess that is too short', () {
        expect(controller.validateGuess('a'), isNotNull);
      });

      test('accepts valid guess', () {
        expect(controller.validateGuess('Cat'), isNull);
        expect(controller.validateGuess('Computer'), isNull);
      });
    });

    group('Game State Helpers', () {
      test('canSubmitQuestion returns correct value', () {
        // Mock game state
        when(mockProvider.gameState).thenReturn(GameState.roundInProgress);
        when(mockProvider.getPlayerData(currentUserId)).thenReturn(
          PlayerData(
            username: 'Test',
            avatarUrl: '',
            avatarFrameId: '',
            remainingGuesses: 3,
            currentQuestion: null,
            lastAnswer: null,
            isReadyForNextRound: false,
          ),
        );

        expect(controller.canSubmitQuestion, isTrue);
      });

      test('waitingForOpponent returns correct value', () {
        when(mockProvider.gameState).thenReturn(GameState.roundInProgress);
        when(mockProvider.getPlayerData(currentUserId)).thenReturn(
          PlayerData(
            username: 'Test',
            avatarUrl: '',
            avatarFrameId: '',
            remainingGuesses: 3,
            currentQuestion: 'My question?',
            lastAnswer: null,
            isReadyForNextRound: false,
          ),
        );
        when(mockProvider.getOpponentData(currentUserId)).thenReturn(
          PlayerData(
            username: 'Opponent',
            avatarUrl: '',
            avatarFrameId: '',
            remainingGuesses: 3,
            currentQuestion: null,
            lastAnswer: null,
            isReadyForNextRound: false,
          ),
        );

        expect(controller.waitingForOpponent, isTrue);
      });

      test('isInFinalGuessPhase returns correct value', () {
        when(mockProvider.gameState).thenReturn(GameState.finalGuessPhase);
        expect(controller.isInFinalGuessPhase, isTrue);

        when(mockProvider.gameState).thenReturn(GameState.roundInProgress);
        expect(controller.isInFinalGuessPhase, isFalse);
      });

      test('isGameOver returns correct value', () {
        when(mockProvider.gameState).thenReturn(GameState.gameOver);
        expect(controller.isGameOver, isTrue);

        when(mockProvider.gameState).thenReturn(GameState.roundInProgress);
        expect(controller.isGameOver, isFalse);
      });
    });

    group('Answer Display', () {
      test('formats YES answer correctly', () {
        expect(controller.getAnswerDisplay('YES'), equals('EVET'));
        expect(controller.getAnswerDisplay('yes'), equals('EVET'));
      });

      test('formats NO answer correctly', () {
        expect(controller.getAnswerDisplay('NO'), equals('HAYIR'));
        expect(controller.getAnswerDisplay('no'), equals('HAYIR'));
      });

      test('formats NEUTRAL answer correctly', () {
        expect(controller.getAnswerDisplay('NEUTRAL'), equals('BİLİNMİYOR'));
        expect(controller.getAnswerDisplay('neutral'), equals('BİLİNMİYOR'));
      });

      test('handles null or empty answer', () {
        expect(controller.getAnswerDisplay(null), equals('-'));
        expect(controller.getAnswerDisplay(''), equals('-'));
      });
    });

    group('Game Result Messages', () {
      test('returns correct message for draw', () {
        when(mockProvider.gameState).thenReturn(GameState.gameOver);
        when(mockProvider.isDraw).thenReturn(true);

        expect(controller.getGameResultMessage(), equals('Berabere!'));
      });

      test('returns correct message for win', () {
        when(mockProvider.gameState).thenReturn(GameState.gameOver);
        when(mockProvider.isDraw).thenReturn(false);
        when(mockProvider.isWinner(currentUserId)).thenReturn(true);

        expect(controller.getGameResultMessage(), equals('Kazandın!'));
      });

      test('returns correct message for loss', () {
        when(mockProvider.gameState).thenReturn(GameState.gameOver);
        when(mockProvider.isDraw).thenReturn(false);
        when(mockProvider.isWinner(currentUserId)).thenReturn(false);

        expect(controller.getGameResultMessage(), equals('Kaybettin!'));
      });
    });
  });
}
