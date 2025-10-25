import '../../core/base/base_repository.dart';
import '../../core/utils/result.dart';
import '../../models/multiplayer_game_session.dart';
import '../../services/multiplayer_game_service.dart';

/// Repository for multiplayer game operations
/// Provides data access layer for game sessions
class MultiplayerGameRepository implements BaseRepository<MultiplayerGameSession> {
  final MultiplayerGameService _service;

  MultiplayerGameRepository({required MultiplayerGameService service})
      : _service = service;

  /// Watch game session changes in real-time
  Stream<MultiplayerGameSession> watchGame(String gameId) {
    return _service.listenToGame(gameId);
  }

  /// Get game session once
  @override
  Future<MultiplayerGameSession?> getById(String gameId) async {
    final result = await _service.getGame(gameId);
    if (result is Success<MultiplayerGameSession>) {
      return result.data;
    }
    return null;
  }

  /// Submit question for current round
  Future<Result<void>> submitQuestion(String gameId, String question) async {
    return await _service.submitQuestion(
      gameId: gameId,
      question: question,
    );
  }

  /// Make final guess for secret word
  Future<Result<Map<String, dynamic>>> makeFinalGuess(
    String gameId,
    String guess,
  ) async {
    return await _service.makeFinalGuess(
      gameId: gameId,
      guess: guess,
    );
  }

  /// Check if user is player in game
  Future<bool> isPlayerInGame(String gameId, String userId) async {
    final result = await _service.isPlayerInGame(gameId, userId);
    if (result is Success<bool>) {
      return result.data;
    }
    return false;
  }

  /// Get opponent ID
  Future<String?> getOpponentId(String gameId, String userId) async {
    final result = await _service.getOpponentId(gameId, userId);
    if (result is Success<String>) {
      return result.data;
    }
    return null;
  }

  /// Check if game is still active
  Future<bool> isGameActive(String gameId) async {
    final result = await _service.isGameActive(gameId);
    if (result is Success<bool>) {
      return result.data;
    }
    return false;
  }

  /// Watch all active games for a user
  Stream<List<MultiplayerGameSession>> watchUserGames(String userId) {
    return _service.listenToUserGames(userId);
  }

  /// Get recent completed games
  Future<List<MultiplayerGameSession>> getRecentGames(
    String userId, {
    int limit = 10,
  }) async {
    final result = await _service.getRecentCompletedGames(userId, limit: limit);
    if (result is Success<List<MultiplayerGameSession>>) {
      return result.data;
    }
    return [];
  }

  /// Get time remaining for timer
  Duration? getTimeRemaining(MultiplayerGameSession game) {
    return _service.getTimeRemaining(game);
  }

  @override
  Future<List<MultiplayerGameSession>> getAll() async {
    throw UnimplementedError('Use watchUserGames for user-specific games');
  }

  @override
  Future<MultiplayerGameSession> create(MultiplayerGameSession entity) async {
    throw UnimplementedError('Games are created via Cloud Functions');
  }

  @override
  Future<MultiplayerGameSession> update(
    String id,
    MultiplayerGameSession entity,
  ) async {
    throw UnimplementedError('Games are updated via Cloud Functions');
  }

  @override
  Future<bool> delete(String id) async {
    throw UnimplementedError('Games cannot be manually deleted');
  }
}
