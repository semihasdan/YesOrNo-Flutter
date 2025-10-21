import 'dart:math';
import '../core/base/base_service.dart';
import '../core/utils/result.dart';
import '../data/repositories/game_repository.dart';
import '../models/game_session.dart';
import '../models/question_object.dart';
import '../models/match_result.dart';
import '../models/user_profile.dart';

/// Service for game-related business logic
/// Encapsulates game operations and rules
class GameService implements BaseService {
  final GameRepository _gameRepository;
  
  GameService(this._gameRepository);
  
  @override
  Future<void> initialize() async {
    // Initialize game service
  }
  
  @override
  void dispose() {
    // Cleanup resources
  }
  
  /// Create a new game session
  Future<Result<GameSession>> createSession({
    required UserProfile player1,
    UserProfile? player2,
    String? roomCode,
  }) async {
    try {
      final sessionId = _generateSessionId();
      final secretWord = _generateSecretWord();
      
      final session = GameSession(
        sessionId: sessionId,
        roomCode: roomCode,
        player1: player1,
        player2: player2,
        secretWord: secretWord,
        bounty: 100,
        currentRound: 1,
        timer: 10,
        gameStatus: player2 != null ? GameStatus.active : GameStatus.waiting,
      );
      
      final created = await _gameRepository.create(session);
      return Success(created);
    } catch (e) {
      return Failure('Failed to create session: $e');
    }
  }
  
  /// Join an existing game session
  Future<Result<GameSession>> joinSession(String roomCode, UserProfile player) async {
    try {
      final session = await _gameRepository.getByRoomCode(roomCode);
      if (session == null) {
        return const Failure('Room not found');
      }
      
      if (session.player2 != null) {
        return const Failure('Room is full');
      }
      
      final updatedSession = session.copyWith(
        player2: player,
        gameStatus: GameStatus.active,
      );
      
      final updated = await _gameRepository.update(session.sessionId, updatedSession);
      return Success(updated);
    } catch (e) {
      return Failure('Failed to join session: $e');
    }
  }
  
  /// Submit a question in the game
  Future<Result<QuestionObject>> submitQuestion({
    required String sessionId,
    required String playerId,
    required String questionText,
  }) async {
    try {
      final session = await _gameRepository.getById(sessionId);
      if (session == null) {
        return const Failure('Session not found');
      }
      
      final questions = await _gameRepository.getQuestions(sessionId);
      final questionId = 'q${questions.length}';
      
      final question = QuestionObject(
        questionId: questionId,
        playerId: playerId,
        text: questionText,
        answer: QuestionAnswer.pending,
        roundNumber: questions.length + 1,
      );
      
      final created = await _gameRepository.addQuestion(sessionId, question);
      
      // Simulate answer generation (in real app, this would be opponent's response)
      _simulateAnswer(sessionId, questionId, session.secretWord, questionText);
      
      return Success(created);
    } catch (e) {
      return Failure('Failed to submit question: $e');
    }
  }
  
  /// Update game timer
  Future<Result<GameSession>> updateTimer(String sessionId, int seconds) async {
    try {
      final session = await _gameRepository.getById(sessionId);
      if (session == null) {
        return const Failure('Session not found');
      }
      
      final updatedSession = session.copyWith(timer: seconds);
      final updated = await _gameRepository.update(sessionId, updatedSession);
      
      return Success(updated);
    } catch (e) {
      return Failure('Failed to update timer: $e');
    }
  }
  
  /// Decrease bounty
  Future<Result<GameSession>> decreaseBounty(String sessionId, int amount) async {
    try {
      final session = await _gameRepository.getById(sessionId);
      if (session == null) {
        return const Failure('Session not found');
      }
      
      final newBounty = (session.bounty - amount).clamp(0, 100);
      final updatedSession = session.copyWith(bounty: newBounty);
      final updated = await _gameRepository.update(sessionId, updatedSession);
      
      return Success(updated);
    } catch (e) {
      return Failure('Failed to decrease bounty: $e');
    }
  }
  
  /// End game session with result
  Future<Result<MatchResult>> endSession({
    required String sessionId,
    required String winnerId,
    required String loserId,
    required WinCondition winCondition,
  }) async {
    try {
      final session = await _gameRepository.getById(sessionId);
      if (session == null) {
        return const Failure('Session not found');
      }
      
      final questions = await _gameRepository.getQuestions(sessionId);
      
      final result = MatchResult(
        winnerId: winnerId,
        loserId: loserId,
        secretWord: session.secretWord,
        finalBounty: session.bounty,
        totalRounds: questions.length,
        winCondition: winCondition,
      );
      
      await _gameRepository.saveMatchResult(result);
      
      final updatedSession = session.copyWith(gameStatus: GameStatus.finished);
      await _gameRepository.update(sessionId, updatedSession);
      
      return Success(result);
    } catch (e) {
      return Failure('Failed to end session: $e');
    }
  }
  
  /// Generate unique session ID
  String _generateSessionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(999999).toString().padLeft(6, '0');
    return 'session_${timestamp}_$randomPart';
  }
  
  /// Generate random secret word
  String _generateSecretWord() {
    final words = [
      'BUTTERFLY', 'ELEPHANT', 'MOUNTAIN', 'OCEAN', 'RAINBOW',
      'THUNDER', 'VOLCANO', 'CRYSTAL', 'DRAGON', 'PHOENIX',
    ];
    final random = Random();
    return words[random.nextInt(words.length)];
  }
  
  /// Simulate answer generation (mock AI logic)
  Future<void> _simulateAnswer(
    String sessionId,
    String questionId,
    String secretWord,
    String questionText,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic - random answer
    final random = Random();
    final answer = random.nextBool() ? QuestionAnswer.yes : QuestionAnswer.no;
    
    await _gameRepository.updateQuestionAnswer(sessionId, questionId, answer);
  }
  
  /// Generate room code
  String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
