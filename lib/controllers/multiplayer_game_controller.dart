import 'package:flutter/foundation.dart';
import '../providers/multiplayer_game_provider.dart';
import '../models/multiplayer_game_session.dart';
import '../models/player_data.dart';

/// Controller for multiplayer game interactions
/// Wraps MultiplayerGameProvider to provide business logic and validation
class MultiplayerGameController extends ChangeNotifier {
  final MultiplayerGameProvider _gameProvider;
  final String _currentUserId;
  
  // Local UI state
  String? _currentQuestion;
  String? _currentGuess;
  bool _showHistory = false;
  
  MultiplayerGameController({
    required MultiplayerGameProvider gameProvider,
    required String currentUserId,
  })  : _gameProvider = gameProvider,
        _currentUserId = currentUserId {
    // Listen to provider changes
    _gameProvider.addListener(_onGameProviderChanged);
  }

  // Getters - Game State
  MultiplayerGameSession? get game => _gameProvider.currentGame;
  GameState? get gameState => _gameProvider.gameState;
  String? get errorMessage => _gameProvider.errorMessage;
  bool get isSubmittingQuestion => _gameProvider.isSubmittingQuestion;
  bool get isMakingGuess => _gameProvider.isMakingGuess;
  
  // Getters - Round Info
  int get currentRound => _gameProvider.currentRound;
  int? get remainingSeconds => _gameProvider.remainingSeconds;
  bool get isTimerExpired => _gameProvider.isTimerExpired;
  String? get secretWordCategory => game?.category;
  
  // Getters - Player Data
  PlayerData? get myPlayerData => _gameProvider.getPlayerData(_currentUserId);
  PlayerData? get opponentData => _gameProvider.getOpponentData(_currentUserId);
  String? get opponentId => _gameProvider.getOpponentId(_currentUserId);
  
  // Getters - Game Status
  bool get hasSubmittedQuestion => myPlayerData?.hasSubmittedQuestion ?? false;
  bool get opponentHasSubmitted => opponentData?.hasSubmittedQuestion ?? false;
  bool get bothPlayersSubmitted => _gameProvider.bothPlayersSubmitted;
  int get remainingGuesses => myPlayerData?.remainingGuesses ?? 3;
  bool get canMakeFinalGuess => remainingGuesses > 0;
  bool get isWinner => _gameProvider.isWinner(_currentUserId);
  bool get isDraw => _gameProvider.isDraw;
  String? get winnerId => game?.winnerId;
  
  // Getters - Local UI State
  String? get currentQuestion => _currentQuestion;
  String? get currentGuess => _currentGuess;
  bool get showHistory => _showHistory;
  
  // Getters - Last Answers
  String? get myLastAnswer => myPlayerData?.lastAnswer;
  String? get opponentLastAnswer => opponentData?.lastAnswer;

  /// Listen to provider state changes
  void _onGameProviderChanged() {
    notifyListeners();
  }

  /// Start watching a game
  Future<void> watchGame(String gameId) async {
    debugPrint('MultiplayerGameController: Starting to watch game $gameId');
    await _gameProvider.watchGame(gameId);
  }

  /// Stop watching current game
  Future<void> stopWatchingGame() async {
    debugPrint('MultiplayerGameController: Stopping game watch');
    await _gameProvider.stopWatchingGame();
    _resetLocalState();
  }

  /// Update current question input
  void updateQuestion(String question) {
    _currentQuestion = question;
    notifyListeners();
  }

  /// Submit current question
  Future<bool> submitQuestion() async {
    if (_currentQuestion == null || _currentQuestion!.trim().isEmpty) {
      debugPrint('MultiplayerGameController: Cannot submit empty question');
      return false;
    }
    
    if (_currentQuestion!.trim().length < 5) {
      debugPrint('MultiplayerGameController: Question too short');
      return false;
    }
    
    if (_currentQuestion!.trim().length > 200) {
      debugPrint('MultiplayerGameController: Question too long');
      return false;
    }
    
    debugPrint('MultiplayerGameController: Submitting question: $_currentQuestion');
    final success = await _gameProvider.submitQuestion(_currentQuestion!);
    
    if (success) {
      // Clear local question after successful submission
      _currentQuestion = null;
      notifyListeners();
    }
    
    return success;
  }

  /// Validate question
  String? validateQuestion(String? question) {
    if (question == null || question.trim().isEmpty) {
      return 'Soru boş olamaz';
    }
    
    if (question.trim().length < 5) {
      return 'Soru en az 5 karakter olmalı';
    }
    
    if (question.trim().length > 200) {
      return 'Soru en fazla 200 karakter olabilir';
    }
    
    if (!question.trim().endsWith('?')) {
      return 'Soru soru işareti ile bitmelidir';
    }
    
    return null;
  }

  /// Update current guess input
  void updateGuess(String guess) {
    _currentGuess = guess;
    notifyListeners();
  }

  /// Submit final guess
  Future<Map<String, dynamic>?> submitFinalGuess() async {
    if (_currentGuess == null || _currentGuess!.trim().isEmpty) {
      debugPrint('MultiplayerGameController: Cannot submit empty guess');
      return null;
    }
    
    if (!canMakeFinalGuess) {
      debugPrint('MultiplayerGameController: No guesses remaining');
      return null;
    }
    
    debugPrint('MultiplayerGameController: Submitting final guess: $_currentGuess');
    final result = await _gameProvider.makeFinalGuess(_currentGuess!);
    
    if (result != null) {
      // Clear local guess after submission
      _currentGuess = null;
      notifyListeners();
    }
    
    return result;
  }

  /// Validate guess
  String? validateGuess(String? guess) {
    if (guess == null || guess.trim().isEmpty) {
      return 'Tahmin boş olamaz';
    }
    
    if (guess.trim().length < 2) {
      return 'Tahmin en az 2 karakter olmalı';
    }
    
    return null;
  }

  /// Toggle history visibility
  void toggleHistory() {
    _showHistory = !_showHistory;
    notifyListeners();
  }

  /// Show history
  void openHistory() {
    _showHistory = true;
    notifyListeners();
  }

  /// Hide history
  void closeHistory() {
    _showHistory = false;
    notifyListeners();
  }

  /// Get time remaining as Duration
  Duration? getTimeRemaining() {
    return _gameProvider.getTimeRemaining();
  }

  /// Check if in specific game state
  bool isInState(GameState state) {
    return gameState == state;
  }

  /// Check if can submit question
  bool get canSubmitQuestion {
    return !hasSubmittedQuestion && 
           !isSubmittingQuestion &&
           isInState(GameState.roundInProgress);
  }

  /// Check if waiting for opponent
  bool get waitingForOpponent {
    return hasSubmittedQuestion && 
           !opponentHasSubmitted &&
           isInState(GameState.roundInProgress);
  }

  /// Check if round is being processed
  bool get isProcessingRound {
    return isInState(GameState.waitingForAnswers);
  }

  /// Check if in final guess phase
  bool get isInFinalGuessPhase {
    return isInState(GameState.finalGuessPhase);
  }

  /// Check if game is over
  bool get isGameOver {
    return isInState(GameState.gameOver);
  }

  /// Get game result message
  String getGameResultMessage() {
    if (!isGameOver) return '';
    
    if (isDraw) {
      return 'Berabere!';
    } else if (isWinner) {
      return 'Kazandın!';
    } else {
      return 'Kaybettin!';
    }
  }

  /// Get answer display text
  String getAnswerDisplay(String? answer) {
    if (answer == null || answer.isEmpty) {
      return '-';
    }
    
    switch (answer.toUpperCase()) {
      case 'YES':
        return 'EVET';
      case 'NO':
        return 'HAYIR';
      case 'NEUTRAL':
        return 'BİLİNMİYOR';
      default:
        return answer;
    }
  }

  /// Reset local state
  void _resetLocalState() {
    _currentQuestion = null;
    _currentGuess = null;
    _showHistory = false;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _gameProvider.clearError();
  }

  @override
  void dispose() {
    _gameProvider.removeListener(_onGameProviderChanged);
    super.dispose();
  }
}
