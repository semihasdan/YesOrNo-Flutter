import '../../core/base/base_repository.dart';
import '../../models/game_session.dart';
import '../../models/question_object.dart';
import '../../models/match_result.dart';

/// Repository for game data management
/// Handles CRUD operations for game sessions
class GameRepository implements BaseRepository<GameSession> {
  // In-memory storage (will be replaced with real backend)
  final Map<String, GameSession> _sessions = {};
  final Map<String, List<QuestionObject>> _sessionQuestions = {};
  
  @override
  Future<GameSession?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sessions[id];
  }
  
  @override
  Future<List<GameSession>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sessions.values.toList();
  }
  
  @override
  Future<GameSession> create(GameSession entity) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sessions[entity.sessionId] = entity;
    _sessionQuestions[entity.sessionId] = [];
    return entity;
  }
  
  @override
  Future<GameSession> update(String id, GameSession entity) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sessions[id] = entity;
    return entity;
  }
  
  @override
  Future<bool> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sessionQuestions.remove(id);
    return _sessions.remove(id) != null;
  }
  
  /// Get game session by room code
  Future<GameSession?> getByRoomCode(String roomCode) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sessions.values.firstWhere(
      (session) => session.roomCode == roomCode,
      orElse: () => throw Exception('Room not found'),
    );
  }
  
  /// Add question to session
  Future<QuestionObject> addQuestion(String sessionId, QuestionObject question) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_sessionQuestions.containsKey(sessionId)) {
      _sessionQuestions[sessionId] = [];
    }
    
    _sessionQuestions[sessionId]!.add(question);
    return question;
  }
  
  /// Get questions for session
  Future<List<QuestionObject>> getQuestions(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sessionQuestions[sessionId] ?? [];
  }
  
  /// Update question answer
  Future<QuestionObject> updateQuestionAnswer(
    String sessionId,
    String questionId,
    QuestionAnswer answer,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final questions = _sessionQuestions[sessionId];
    if (questions == null) {
      throw Exception('Session not found');
    }
    
    final index = questions.indexWhere((q) => q.questionId == questionId);
    if (index == -1) {
      throw Exception('Question not found');
    }
    
    questions[index] = questions[index].copyWith(answer: answer);
    return questions[index];
  }
  
  /// Save match result
  Future<void> saveMatchResult(MatchResult result) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In real implementation, save to backend/local storage
  }
}
