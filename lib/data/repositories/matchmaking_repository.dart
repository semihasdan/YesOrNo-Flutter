import '../../core/base/base_repository.dart';
import '../../core/utils/result.dart';
import '../../models/matchmaking_queue.dart';
import '../../services/matchmaking_service.dart';

/// Repository for matchmaking operations
/// Provides data access layer for queue management
class MatchmakingRepository implements BaseRepository<MatchmakingQueue> {
  final MatchmakingService _service;

  MatchmakingRepository({required MatchmakingService service})
      : _service = service;

  /// Join the matchmaking queue
  /// Returns gameId if match found, null if added to queue
  Future<Result<String?>> joinQueue(String userId) async {
    return await _service.joinQueue(userId);
  }

  /// Listen to queue changes for a user
  /// Stream emits null when match is found (queue entry deleted)
  Stream<MatchmakingQueue?> watchQueue(String userId) {
    return _service.listenToQueue(userId);
  }

  /// Cancel matchmaking and leave queue
  Future<Result<void>> leaveQueue(String userId) async {
    return await _service.cancelQueue(userId);
  }

  /// Check if user is currently in queue
  Future<Result<bool>> isUserInQueue(String userId) async {
    return await _service.isInQueue(userId);
  }

  /// Get queue position (0-indexed)
  Future<Result<int>> getPosition(String userId) async {
    return await _service.getQueuePosition(userId);
  }

  /// Get total players in queue
  Future<Result<int>> getTotalPlayers() async {
    return await _service.getQueueSize();
  }

  @override
  Future<MatchmakingQueue?> getById(String id) async {
    // Not typically used for queue - use watchQueue instead
    throw UnimplementedError('Use watchQueue for real-time monitoring');
  }

  @override
  Future<List<MatchmakingQueue>> getAll() async {
    throw UnimplementedError('Not applicable for matchmaking queue');
  }

  @override
  Future<MatchmakingQueue> create(MatchmakingQueue entity) async {
    throw UnimplementedError('Use joinQueue instead');
  }

  @override
  Future<MatchmakingQueue> update(String id, MatchmakingQueue entity) async {
    throw UnimplementedError('Queue entries are immutable');
  }

  @override
  Future<bool> delete(String id) async {
    throw UnimplementedError('Use leaveQueue instead');
  }
}
