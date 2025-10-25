import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/base/base_service.dart';
import '../core/utils/result.dart';
import '../models/matchmaking_queue.dart';
import 'cloud_functions_service.dart';

/// Service for matchmaking operations
/// Handles queue entry, opponent matching, and queue monitoring
class MatchmakingService implements BaseService {
  final CloudFunctionsService _functionsService;
  final FirebaseFirestore _firestore;

  MatchmakingService({
    required CloudFunctionsService functionsService,
    FirebaseFirestore? firestore,
  })  : _functionsService = functionsService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> initialize() async {
    debugPrint('MatchmakingService initialized');
  }

  @override
  void dispose() {
    // Cleanup if needed
  }

  /// Join the matchmaking queue
  /// Returns gameId if match found immediately, null if added to queue
  Future<Result<String?>> joinQueue(String userId) async {
    try {
      debugPrint('MatchmakingService: Joining queue for user $userId');
      
      // Call cloud function to join queue
      final result = await _functionsService.joinMatchmaking();
      
      return result;
      
    } catch (e) {
      debugPrint('Error joining queue: $e');
      return Failure('Failed to join matchmaking: $e');
    }
  }

  /// Listen to queue changes for a specific user
  /// Returns stream that emits when queue entry is deleted (match found)
  Stream<MatchmakingQueue?> listenToQueue(String userId) {
    try {
      debugPrint('MatchmakingService: Listening to queue for user $userId');
      
      return _firestore
          .collection('matchmakingQueue')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              // Queue entry deleted - match found
              debugPrint('Queue entry deleted - match found!');
              return null;
            }
            
            // Queue entry exists - still waiting
            final doc = snapshot.docs.first;
            return MatchmakingQueue.fromFirestore(doc);
          });
          
    } catch (e) {
      debugPrint('Error listening to queue: $e');
      return Stream.error('Failed to listen to queue: $e');
    }
  }

  /// Cancel matchmaking by removing user from queue
  Future<Result<void>> cancelQueue(String userId) async {
    try {
      debugPrint('MatchmakingService: Cancelling queue for user $userId');
      
      // Query for user's queue entry
      final querySnapshot = await _firestore
          .collection('matchmakingQueue')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        debugPrint('No queue entry found for user $userId');
        return const Success(null);
      }
      
      // Delete queue entry
      await querySnapshot.docs.first.reference.delete();
      
      debugPrint('Queue entry deleted successfully');
      return const Success(null);
      
    } catch (e) {
      debugPrint('Error cancelling queue: $e');
      return Failure('Failed to cancel matchmaking: $e');
    }
  }

  /// Check if user is currently in queue
  Future<Result<bool>> isInQueue(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('matchmakingQueue')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      final inQueue = querySnapshot.docs.isNotEmpty;
      debugPrint('User $userId in queue: $inQueue');
      
      return Success(inQueue);
      
    } catch (e) {
      debugPrint('Error checking queue status: $e');
      return Failure('Failed to check queue status: $e');
    }
  }

  /// Get estimated queue position (for future implementation)
  Future<Result<int>> getQueuePosition(String userId) async {
    try {
      // Get user's queue entry
      final userSnapshot = await _firestore
          .collection('matchmakingQueue')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (userSnapshot.docs.isEmpty) {
        return const Failure('User not in queue');
      }
      
      final userEntry = MatchmakingQueue.fromFirestore(userSnapshot.docs.first);
      
      // Count entries that joined before this user
      final earlierEntries = await _firestore
          .collection('matchmakingQueue')
          .where('joinTime', isLessThan: Timestamp.fromDate(userEntry.joinTime))
          .count()
          .get();
      
      final position = earlierEntries.count ?? 0;
      debugPrint('Queue position for $userId: $position');
      
      return Success(position.toInt());
      
    } catch (e) {
      debugPrint('Error getting queue position: $e');
      return Failure('Failed to get queue position: $e');
    }
  }

  /// Get total number of players in queue
  Future<Result<int>> getQueueSize() async {
    try {
      final snapshot = await _firestore
          .collection('matchmakingQueue')
          .count()
          .get();
      
      final size = snapshot.count ?? 0;
      debugPrint('Total queue size: $size');
      
      return Success(size.toInt());
      
    } catch (e) {
      debugPrint('Error getting queue size: $e');
      return Failure('Failed to get queue size: $e');
    }
  }
}
