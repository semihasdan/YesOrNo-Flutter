import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/multiplayer_game_session.dart';
import '../data/repositories/multiplayer_game_repository.dart';
import '../core/utils/result.dart';

/// Provider for managing multiplayer game state
/// Listens to real-time game updates and provides game interaction methods
class MultiplayerGameProvider extends ChangeNotifier {
  final MultiplayerGameRepository _repository;
  
  // Current game state
  MultiplayerGameSession? _currentGame;
  String? _currentGameId;
  StreamSubscription<MultiplayerGameSession>? _gameSubscription;
  
  // Error state
  String? _errorMessage;
  
  // Loading states
  bool _isSubmittingQuestion = false;
  bool _isMakingGuess = false;
  
  MultiplayerGameProvider({
    required MultiplayerGameRepository repository,
  }) : _repository = repository;

  // Getters
  MultiplayerGameSession? get currentGame => _currentGame;
  String? get currentGameId => _currentGameId;
  String? get errorMessage => _errorMessage;
  bool get isSubmittingQuestion => _isSubmittingQuestion;
  bool get isMakingGuess => _isMakingGuess;
  bool get hasActiveGame => _currentGame != null && _currentGame!.isActive;
  
  // Game state helpers
  GameState? get gameState => _currentGame?.state;
  int get currentRound => _currentGame?.currentRound ?? 0;
  bool get bothPlayersSubmitted => _currentGame?.bothPlayersSubmitted ?? false;
  int? get remainingSeconds => _currentGame?.remainingSeconds;
  bool get isTimerExpired => _currentGame?.isTimerExpired ?? false;

  /// Start listening to a game session
  Future<void> watchGame(String gameId) async {
    debugPrint('MultiplayerGameProvider: Starting to watch game $gameId');
    
    // Cancel previous subscription
    await _gameSubscription?.cancel();
    
    _currentGameId = gameId;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _gameSubscription = _repository.watchGame(gameId).listen(
        (game) {
          debugPrint('MultiplayerGameProvider: Received game update - state: ${game.state}, round: ${game.currentRound}');
          _currentGame = game;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('MultiplayerGameProvider: Error watching game: $error');
          _errorMessage = 'Failed to load game: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('MultiplayerGameProvider: Exception starting game watch: $e');
      _errorMessage = 'Failed to start watching game: $e';
      notifyListeners();
    }
  }

  /// Stop listening to current game
  Future<void> stopWatchingGame() async {
    debugPrint('MultiplayerGameProvider: Stopping game watch');
    await _gameSubscription?.cancel();
    _gameSubscription = null;
    _currentGame = null;
    _currentGameId = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Submit a question for the current round
  Future<bool> submitQuestion(String question) async {
    if (_currentGameId == null) {
      _errorMessage = 'No active game';
      notifyListeners();
      return false;
    }
    
    if (_isSubmittingQuestion) {
      debugPrint('MultiplayerGameProvider: Already submitting a question');
      return false;
    }
    
    _isSubmittingQuestion = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('MultiplayerGameProvider: Submitting question: $question');
      
      final result = await _repository.submitQuestion(_currentGameId!, question);
      
      if (result is Success) {
        debugPrint('MultiplayerGameProvider: Question submitted successfully');
        _isSubmittingQuestion = false;
        notifyListeners();
        return true;
      } else if (result is Failure) {
        debugPrint('MultiplayerGameProvider: Failed to submit question: ${result.message}');
        _errorMessage = result.message;
        _isSubmittingQuestion = false;
        notifyListeners();
        return false;
      }
      
      _isSubmittingQuestion = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      debugPrint('MultiplayerGameProvider: Exception submitting question: $e');
      _errorMessage = 'Failed to submit question: $e';
      _isSubmittingQuestion = false;
      notifyListeners();
      return false;
    }
  }

  /// Make a final guess for the secret word
  Future<Map<String, dynamic>?> makeFinalGuess(String guess) async {
    if (_currentGameId == null) {
      _errorMessage = 'No active game';
      notifyListeners();
      return null;
    }
    
    if (_isMakingGuess) {
      debugPrint('MultiplayerGameProvider: Already making a guess');
      return null;
    }
    
    _isMakingGuess = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('MultiplayerGameProvider: Making final guess: $guess');
      
      final result = await _repository.makeFinalGuess(_currentGameId!, guess);
      
      if (result is Success<Map<String, dynamic>>) {
        debugPrint('MultiplayerGameProvider: Guess result: ${result.data}');
        _isMakingGuess = false;
        notifyListeners();
        return result.data;
      } else if (result is Failure) {
        debugPrint('MultiplayerGameProvider: Failed to make guess: ${result.message}');
        _errorMessage = result.message;
        _isMakingGuess = false;
        notifyListeners();
        return null;
      }
      
      _isMakingGuess = false;
      notifyListeners();
      return null;
      
    } catch (e) {
      debugPrint('MultiplayerGameProvider: Exception making guess: $e');
      _errorMessage = 'Failed to make guess: $e';
      _isMakingGuess = false;
      notifyListeners();
      return null;
    }
  }

  /// Get player data for current user
  PlayerData? getPlayerData(String userId) {
    return _currentGame?.getPlayerData(userId);
  }

  /// Get opponent data
  PlayerData? getOpponentData(String userId) {
    return _currentGame?.getOpponentData(userId);
  }

  /// Get opponent ID
  String? getOpponentId(String userId) {
    return _currentGame?.getOpponentId(userId);
  }

  /// Check if current user is winner
  bool isWinner(String userId) {
    return _currentGame?.isWinner(userId) ?? false;
  }

  /// Check if game ended in draw
  bool get isDraw => _currentGame?.isDraw ?? false;

  /// Get time remaining for current timer
  Duration? getTimeRemaining() {
    if (_currentGame == null) return null;
    return _repository.getTimeRemaining(_currentGame!);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _gameSubscription?.cancel();
    super.dispose();
  }
}
