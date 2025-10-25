import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/matchmaking_queue.dart';
import '../data/repositories/matchmaking_repository.dart';
import '../core/utils/result.dart';

/// Controller for matchmaking flow
/// Handles queue joining, monitoring, and navigation to game
class MatchmakingController extends ChangeNotifier {
  final MatchmakingRepository _repository;
  
  // Queue state
  MatchmakingQueue? _queueEntry;
  StreamSubscription<MatchmakingQueue?>? _queueSubscription;
  
  // Matchmaking state
  bool _isJoining = false;
  bool _isInQueue = false;
  bool _matchFound = false;
  String? _gameId;
  
  // Error state
  String? _errorMessage;
  
  MatchmakingController({
    required MatchmakingRepository repository,
  }) : _repository = repository;

  // Getters
  MatchmakingQueue? get queueEntry => _queueEntry;
  bool get isJoining => _isJoining;
  bool get isInQueue => _isInQueue;
  bool get matchFound => _matchFound;
  String? get gameId => _gameId;
  String? get errorMessage => _errorMessage;
  
  // Queue info
  DateTime? get joinTime => _queueEntry?.joinTime;
  Duration? get waitingDuration {
    if (_queueEntry == null) return null;
    return DateTime.now().difference(_queueEntry!.joinTime);
  }

  /// Join matchmaking queue
  /// Returns gameId if immediate match found
  Future<String?> joinMatchmaking(String userId) async {
    if (_isJoining || _isInQueue) {
      debugPrint('MatchmakingController: Already in matchmaking process');
      return null;
    }
    
    _isJoining = true;
    _errorMessage = null;
    _matchFound = false;
    _gameId = null;
    notifyListeners();
    
    try {
      debugPrint('MatchmakingController: Joining matchmaking for user $userId');
      
      // Call repository to join queue
      final result = await _repository.joinQueue(userId);
      
      if (result is Success<String?>) {
        final gameId = result.data;
        
        if (gameId != null) {
          // Immediate match found
          debugPrint('MatchmakingController: Immediate match found - gameId: $gameId');
          _matchFound = true;
          _gameId = gameId;
          _isJoining = false;
          _isInQueue = false;
          notifyListeners();
          return gameId;
        } else {
          // Added to queue - start monitoring
          debugPrint('MatchmakingController: Added to queue, starting monitoring');
          _isInQueue = true;
          _isJoining = false;
          notifyListeners();
          
          // Start watching queue
          _startWatchingQueue(userId);
          return null;
        }
      } else if (result is Failure) {
        debugPrint('MatchmakingController: Failed to join queue: ${result.message}');
        _errorMessage = result.message;
        _isJoining = false;
        notifyListeners();
        return null;
      }
      
      _isJoining = false;
      notifyListeners();
      return null;
      
    } catch (e) {
      debugPrint('MatchmakingController: Exception joining matchmaking: $e');
      _errorMessage = 'Failed to join matchmaking: $e';
      _isJoining = false;
      notifyListeners();
      return null;
    }
  }

  /// Start watching queue for match updates
  void _startWatchingQueue(String userId) {
    debugPrint('MatchmakingController: Starting queue watch for user $userId');
    
    // Cancel previous subscription
    _queueSubscription?.cancel();
    
    try {
      _queueSubscription = _repository.watchQueue(userId).listen(
        (queueEntry) {
          if (queueEntry == null) {
            // Queue entry deleted - match found!
            debugPrint('MatchmakingController: Queue entry deleted - checking for game');
            _handleMatchFound(userId);
          } else {
            // Still in queue
            debugPrint('MatchmakingController: Queue update - position updated');
            _queueEntry = queueEntry;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('MatchmakingController: Error watching queue: $error');
          _errorMessage = 'Queue monitoring error: $error';
          _isInQueue = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('MatchmakingController: Exception starting queue watch: $e');
      _errorMessage = 'Failed to monitor queue: $e';
      _isInQueue = false;
      notifyListeners();
    }
  }

  /// Handle match found scenario
  /// Wait briefly then check for active games
  void _handleMatchFound(String userId) async {
    debugPrint('MatchmakingController: Match potentially found, waiting for game creation');
    
    // Wait a moment for game creation
    await Future.delayed(const Duration(milliseconds: 500));
    
    // The game should be created by backend
    // The UI should listen to active games stream to get the gameId
    _matchFound = true;
    _isInQueue = false;
    _queueEntry = null;
    notifyListeners();
  }

  /// Leave matchmaking queue
  Future<bool> leaveQueue(String userId) async {
    if (!_isInQueue) {
      debugPrint('MatchmakingController: Not in queue');
      return true;
    }
    
    debugPrint('MatchmakingController: Leaving queue for user $userId');
    
    try {
      final result = await _repository.leaveQueue(userId);
      
      if (result is Success) {
        debugPrint('MatchmakingController: Successfully left queue');
        await _queueSubscription?.cancel();
        _queueSubscription = null;
        _queueEntry = null;
        _isInQueue = false;
        _matchFound = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else if (result is Failure) {
        debugPrint('MatchmakingController: Failed to leave queue: ${result.message}');
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
      
      return false;
      
    } catch (e) {
      debugPrint('MatchmakingController: Exception leaving queue: $e');
      _errorMessage = 'Failed to leave queue: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check if user is in queue
  Future<bool> checkQueueStatus(String userId) async {
    try {
      final result = await _repository.isUserInQueue(userId);
      
      if (result is Success<bool>) {
        final inQueue = result.data;
        _isInQueue = inQueue;
        notifyListeners();
        return inQueue;
      }
      
      return false;
    } catch (e) {
      debugPrint('MatchmakingController: Error checking queue status: $e');
      return false;
    }
  }

  /// Get queue position
  Future<int?> getQueuePosition(String userId) async {
    try {
      final result = await _repository.getPosition(userId);
      
      if (result is Success<int>) {
        return result.data;
      }
      
      return null;
    } catch (e) {
      debugPrint('MatchmakingController: Error getting queue position: $e');
      return null;
    }
  }

  /// Reset state
  void reset() {
    _queueSubscription?.cancel();
    _queueSubscription = null;
    _queueEntry = null;
    _isJoining = false;
    _isInQueue = false;
    _matchFound = false;
    _gameId = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _queueSubscription?.cancel();
    super.dispose();
  }
}
