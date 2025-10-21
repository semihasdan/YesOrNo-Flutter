import 'package:flutter/foundation.dart';
import '../models/game_session.dart';
import '../models/question_object.dart';

/// Provider for game state management
class GameStateProvider extends ChangeNotifier {
  GameSession? _currentSession;
  final List<QuestionObject> _questions = [];
  int _timer = 10;
  int _bounty = 100;

  GameSession? get currentSession => _currentSession;
  List<QuestionObject> get questions => List.unmodifiable(_questions);
  int get timer => _timer;
  int get bounty => _bounty;

  /// Start a new game session
  void startSession(GameSession session) {
    _currentSession = session;
    _questions.clear();
    _timer = 10;
    _bounty = 100;
    notifyListeners();
  }

  /// End current session
  void endSession() {
    _currentSession = null;
    _questions.clear();
    notifyListeners();
  }

  /// Add a question
  void addQuestion(QuestionObject question) {
    _questions.add(question);
    notifyListeners();
  }

  /// Update a question (e.g., add answer)
  void updateQuestion(String questionId, QuestionAnswer answer) {
    final index = _questions.indexWhere((q) => q.questionId == questionId);
    if (index != -1) {
      _questions[index] = _questions[index].copyWith(answer: answer);
      notifyListeners();
    }
  }

  /// Update timer
  void updateTimer(int seconds) {
    _timer = seconds;
    notifyListeners();
  }

  /// Update bounty
  void updateBounty(int newBounty) {
    _bounty = newBounty;
    notifyListeners();
  }

  /// Decrease bounty
  void decreaseBounty(int amount) {
    _bounty = (_bounty - amount).clamp(0, 100);
    notifyListeners();
  }
}
