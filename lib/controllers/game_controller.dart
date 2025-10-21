import 'dart:async';
import '../core/base/base_controller.dart';
import '../core/utils/result.dart';
import '../models/game_session.dart';
import '../models/question_object.dart';
import '../models/match_result.dart';
import '../models/user_profile.dart';
import '../services/game_service.dart';
import '../core/utils/validators.dart';

/// Controller for game session management
/// Handles game-related UI state and operations
class GameController extends BaseController {
  final GameService _gameService;
  
  GameSession? _currentSession;
  List<QuestionObject> _questions = [];
  int _timer = 10;
  Timer? _timerInstance;
  
  GameController(this._gameService);
  
  GameSession? get currentSession => _currentSession;
  List<QuestionObject> get questions => List.unmodifiable(_questions);
  int get timer => _timer;
  int get bounty => _currentSession?.bounty ?? 100;
  
  @override
  Future<void> initialize() async {
    // No initialization needed for game controller
  }
  
  /// Create a new game session
  Future<bool> createSession({
    required UserProfile player1,
    UserProfile? player2,
    String? roomCode,
  }) async {
    setLoading(true);
    clearError();
    
    try {
      final result = await _gameService.createSession(
        player1: player1,
        player2: player2,
        roomCode: roomCode,
      );
      
      if (result.isSuccess) {
        _currentSession = result.dataOrNull;
        _questions = [];
        _startTimer();
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to create session: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  /// Join an existing game session
  Future<bool> joinSession(String roomCode, UserProfile player) async {
    final validation = Validators.validateRoomCode(roomCode);
    if (validation != null) {
      setError(validation);
      return false;
    }
    
    setLoading(true);
    clearError();
    
    try {
      final result = await _gameService.joinSession(roomCode, player);
      
      if (result.isSuccess) {
        _currentSession = result.dataOrNull;
        _questions = [];
        _startTimer();
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to join session: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  /// Submit a question
  Future<bool> submitQuestion(String playerId, String questionText) async {
    if (_currentSession == null) {
      setError('No active session');
      return false;
    }
    
    final validation = Validators.validateQuestion(questionText);
    if (validation != null) {
      setError(validation);
      return false;
    }
    
    clearError();
    
    try {
      final result = await _gameService.submitQuestion(
        sessionId: _currentSession!.sessionId,
        playerId: playerId,
        questionText: questionText,
      );
      
      if (result.isSuccess) {
        _questions.insert(0, result.dataOrNull!);
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to submit question: $e');
      return false;
    }
  }
  
  /// Update question with answer
  void updateQuestion(String questionId, QuestionAnswer answer) {
    final index = _questions.indexWhere((q) => q.questionId == questionId);
    if (index != -1) {
      _questions[index] = _questions[index].copyWith(answer: answer);
      notifyListeners();
    }
  }
  
  /// End game session
  Future<MatchResult?> endSession({
    required String winnerId,
    required String loserId,
    required WinCondition winCondition,
  }) async {
    if (_currentSession == null) {
      setError('No active session');
      return null;
    }
    
    try {
      final result = await _gameService.endSession(
        sessionId: _currentSession!.sessionId,
        winnerId: winnerId,
        loserId: loserId,
        winCondition: winCondition,
      );
      
      _stopTimer();
      
      if (result.isSuccess) {
        return result.dataOrNull;
      } else {
        setError(result.errorOrNull);
        return null;
      }
    } catch (e) {
      setError('Failed to end session: $e');
      return null;
    }
  }
  
  /// Start game timer
  void _startTimer() {
    _timer = 10;
    _timerInstance?.cancel();
    
    _timerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        _timer--;
        notifyListeners();
      } else {
        _timer = 10;
        _decreaseBounty();
      }
    });
  }
  
  /// Stop game timer
  void _stopTimer() {
    _timerInstance?.cancel();
    _timerInstance = null;
  }
  
  /// Decrease bounty
  void _decreaseBounty() async {
    if (_currentSession == null) return;
    
    final result = await _gameService.decreaseBounty(_currentSession!.sessionId, 5);
    
    if (result.isSuccess) {
      _currentSession = result.dataOrNull;
      notifyListeners();
    }
  }
  
  /// Generate room code
  String generateRoomCode() {
    return _gameService.generateRoomCode();
  }
  
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
