import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/base/base_service.dart';
import '../core/utils/result.dart';
import '../models/multiplayer_game_session.dart';
import 'cloud_functions_service.dart';

/// Service for multiplayer game operations
/// Handles game interactions, question submission, and real-time game monitoring
class MultiplayerGameService implements BaseService {
  final CloudFunctionsService _functionsService;
  final FirebaseFirestore _firestore;

  MultiplayerGameService({
    required CloudFunctionsService functionsService,
    FirebaseFirestore? firestore,
  })  : _functionsService = functionsService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> initialize() async {
    debugPrint('MultiplayerGameService initialized');
  }

  @override
  void dispose() {
    // Cleanup if needed
  }

  /// Listen to game session changes
  /// Returns stream of game state updates
  Stream<MultiplayerGameSession> listenToGame(String gameId) {
    try {
      debugPrint('MultiplayerGameService: Listening to game $gameId');
      
      return _firestore
          .collection('games')
          .doc(gameId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              throw Exception('Game not found');
            }
            
            return MultiplayerGameSession.fromFirestore(snapshot);
          });
          
    } catch (e) {
      debugPrint('Error listening to game: $e');
      return Stream.error('Failed to listen to game: $e');
    }
  }

  /// Get game session once
  Future<Result<MultiplayerGameSession>> getGame(String gameId) async {
    try {
      debugPrint('MultiplayerGameService: Getting game $gameId');
      
      final snapshot = await _firestore
          .collection('games')
          .doc(gameId)
          .get();
      
      if (!snapshot.exists) {
        return const Failure('Game not found');
      }
      
      final game = MultiplayerGameSession.fromFirestore(snapshot);
      return Success(game);
      
    } catch (e) {
      debugPrint('Error getting game: $e');
      return Failure('Failed to get game: $e');
    }
  }

  /// Submit a question for the current round
  Future<Result<void>> submitQuestion({
    required String gameId,
    required String question,
  }) async {
    try {
      debugPrint('MultiplayerGameService: Submitting question for game $gameId');
      
      // Validate question length
      if (question.trim().length < 5 || question.trim().length > 200) {
        return const Failure('Question must be between 5 and 200 characters');
      }
      
      // Call cloud function
      final result = await _functionsService.submitQuestion(
        gameId: gameId,
        question: question.trim(),
      );
      
      return result;
      
    } catch (e) {
      debugPrint('Error submitting question: $e');
      return Failure('Failed to submit question: $e');
    }
  }

  /// Make a final guess for the secret word
  Future<Result<Map<String, dynamic>>> makeFinalGuess({
    required String gameId,
    required String guess,
  }) async {
    try {
      debugPrint('MultiplayerGameService: Making final guess for game $gameId');
      
      // Validate guess
      if (guess.trim().isEmpty) {
        return const Failure('Guess cannot be empty');
      }
      
      // Call cloud function
      final result = await _functionsService.makeFinalGuess(
        gameId: gameId,
        guess: guess.trim(),
      );
      
      return result;
      
    } catch (e) {
      debugPrint('Error making final guess: $e');
      return Failure('Failed to make final guess: $e');
    }
  }

  /// Check if user is a player in the game
  Future<Result<bool>> isPlayerInGame(String gameId, String userId) async {
    try {
      final gameResult = await getGame(gameId);
      
      if (gameResult is Failure) {
        return Failure(gameResult.message);
      }
      
      final game = (gameResult as Success<MultiplayerGameSession>).data;
      final isPlayer = game.playerIds.contains(userId);
      
      debugPrint('User $userId is player in game $gameId: $isPlayer');
      return Success(isPlayer);
      
    } catch (e) {
      debugPrint('Error checking player status: $e');
      return Failure('Failed to check player status: $e');
    }
  }

  /// Get opponent ID for a user in a game
  Future<Result<String>> getOpponentId(String gameId, String userId) async {
    try {
      final gameResult = await getGame(gameId);
      
      if (gameResult is Failure) {
        return Failure(gameResult.message);
      }
      
      final game = (gameResult as Success<MultiplayerGameSession>).data;
      final opponentId = game.getOpponentId(userId);
      
      if (opponentId == null || opponentId.isEmpty) {
        return const Failure('Opponent not found');
      }
      
      return Success(opponentId);
      
    } catch (e) {
      debugPrint('Error getting opponent ID: $e');
      return Failure('Failed to get opponent ID: $e');
    }
  }

  /// Check if game is still active
  Future<Result<bool>> isGameActive(String gameId) async {
    try {
      final gameResult = await getGame(gameId);
      
      if (gameResult is Failure) {
        return Failure(gameResult.message);
      }
      
      final game = (gameResult as Success<MultiplayerGameSession>).data;
      return Success(game.isActive);
      
    } catch (e) {
      debugPrint('Error checking game status: $e');
      return Failure('Failed to check game status: $e');
    }
  }

  /// Listen to active games for a user
  Stream<List<MultiplayerGameSession>> listenToUserGames(String userId) {
    try {
      debugPrint('MultiplayerGameService: Listening to games for user $userId');
      
      return _firestore
          .collection('games')
          .where('playerIds', arrayContains: userId)
          .where('state', whereIn: ['MATCHING', 'INITIALIZING', 'ROUND_IN_PROGRESS', 'WAITING_FOR_ANSWERS', 'FINAL_GUESS_PHASE'])
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MultiplayerGameSession.fromFirestore(doc))
                .toList();
          });
          
    } catch (e) {
      debugPrint('Error listening to user games: $e');
      return Stream.error('Failed to listen to user games: $e');
    }
  }

  /// Get recent completed games for a user
  Future<Result<List<MultiplayerGameSession>>> getRecentCompletedGames(String userId, {int limit = 10}) async {
    try {
      debugPrint('MultiplayerGameService: Getting recent completed games for user $userId');
      
      final snapshot = await _firestore
          .collection('games')
          .where('playerIds', arrayContains: userId)
          .where('state', isEqualTo: 'GAME_OVER')
          .orderBy('roundTimerEndsAt', descending: true)
          .limit(limit)
          .get();
      
      final games = snapshot.docs
          .map((doc) => MultiplayerGameSession.fromFirestore(doc))
          .toList();
      
      return Success(games);
      
    } catch (e) {
      debugPrint('Error getting recent games: $e');
      return Failure('Failed to get recent games: $e');
    }
  }

  /// Calculate time remaining for current timer
  Duration? getTimeRemaining(MultiplayerGameSession game) {
    if (game.roundTimerEndsAt == null) {
      return null;
    }
    
    final now = DateTime.now();
    final diff = game.roundTimerEndsAt!.difference(now);
    
    return diff.isNegative ? Duration.zero : diff;
  }
}
