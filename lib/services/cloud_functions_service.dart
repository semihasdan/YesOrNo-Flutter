import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../core/base/base_service.dart';
import '../core/utils/result.dart';

/// Service for calling Cloud Functions
/// Provides a wrapper around Firebase Callable Functions with error handling
class CloudFunctionsService implements BaseService {
  final FirebaseFunctions _functions;

  CloudFunctionsService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<void> initialize() async {
    // Configure functions region
    _functions.useFunctionsEmulator('localhost', 5001);
    debugPrint('CloudFunctionsService initialized');
  }

  @override
  void dispose() {
    // Cleanup if needed
  }

  /// Join matchmaking queue
  /// Returns gameId if match found, null if added to queue
  Future<Result<String?>> joinMatchmaking() async {
    try {
      debugPrint('Calling joinMatchmaking function');
      
      final callable = _functions.httpsCallable('joinMatchmaking');
      final result = await callable.call();
      
      final data = result.data as Map<String, dynamic>;
      final success = data['success'] as bool;
      final gameId = data['gameId'] as String?;
      
      if (!success) {
        return const Failure('Failed to join matchmaking');
      }
      
      debugPrint('joinMatchmaking result: gameId=$gameId');
      return Success(gameId);
      
    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException: ${e.code} - ${e.message}');
      return Failure(_handleFunctionsError(e));
    } catch (e) {
      debugPrint('Unexpected error in joinMatchmaking: $e');
      return Failure('Unexpected error: $e');
    }
  }

  /// Submit a question for the current round
  Future<Result<void>> submitQuestion({
    required String gameId,
    required String question,
  }) async {
    try {
      debugPrint('Calling submitQuestion: gameId=$gameId');
      
      final callable = _functions.httpsCallable('submitQuestion');
      final result = await callable.call({
        'gameId': gameId,
        'question': question,
      });
      
      final data = result.data as Map<String, dynamic>;
      final success = data['success'] as bool;
      
      if (!success) {
        return Failure(data['message'] as String? ?? 'Failed to submit question');
      }
      
      debugPrint('Question submitted successfully');
      return const Success(null);
      
    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException: ${e.code} - ${e.message}');
      return Failure(_handleFunctionsError(e));
    } catch (e) {
      debugPrint('Unexpected error in submitQuestion: $e');
      return Failure('Unexpected error: $e');
    }
  }

  /// Make a final guess for the secret word
  Future<Result<Map<String, dynamic>>> makeFinalGuess({
    required String gameId,
    required String guess,
  }) async {
    try {
      debugPrint('Calling makeFinalGuess: gameId=$gameId, guess=$guess');
      
      final callable = _functions.httpsCallable('makeFinalGuess');
      final result = await callable.call({
        'gameId': gameId,
        'guess': guess,
      });
      
      final data = result.data as Map<String, dynamic>;
      final success = data['success'] as bool;
      
      if (!success) {
        return const Failure('Failed to process guess');
      }
      
      final correct = data['correct'] as bool;
      final remainingGuesses = data['remainingGuesses'] as int;
      
      debugPrint('Guess result: correct=$correct, remaining=$remainingGuesses');
      
      return Success({
        'correct': correct,
        'remainingGuesses': remainingGuesses,
      });
      
    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException: ${e.code} - ${e.message}');
      return Failure(_handleFunctionsError(e));
    } catch (e) {
      debugPrint('Unexpected error in makeFinalGuess: $e');
      return Failure('Unexpected error: $e');
    }
  }

  /// Call AI judge question function (for testing purposes)
  Future<Result<String>> judgeQuestion({
    required String question,
    required String targetWord,
    required String category,
  }) async {
    try {
      debugPrint('Calling judgeQuestion for testing');
      
      final callable = _functions.httpsCallable('judgeQuestion');
      final result = await callable.call({
        'question': question,
        'targetWord': targetWord,
        'category': category,
      });
      
      final data = result.data as Map<String, dynamic>;
      final success = data['success'] as bool;
      
      if (!success) {
        return const Failure('AI adjudication failed');
      }
      
      final answer = data['answer'] as String;
      debugPrint('AI answer: $answer');
      
      return Success(answer);
      
    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException: ${e.code} - ${e.message}');
      return Failure(_handleFunctionsError(e));
    } catch (e) {
      debugPrint('Unexpected error in judgeQuestion: $e');
      return Failure('Unexpected error: $e');
    }
  }

  /// Handle Firebase Functions exceptions and return user-friendly messages
  String _handleFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'You must be signed in to perform this action.';
      case 'invalid-argument':
        return 'Invalid input. Please check your data and try again.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'failed-precondition':
        return 'This action cannot be performed right now.';
      case 'deadline-exceeded':
        return 'The operation took too long. Please try again.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please try again later.';
      case 'internal':
        return 'An internal error occurred. Please try again.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  /// Configure functions emulator for local development
  void useEmulator(String host, int port) {
    if (kDebugMode) {
      _functions.useFunctionsEmulator(host, port);
      debugPrint('Using Cloud Functions emulator: $host:$port');
    }
  }

  /// Set custom region for functions
  void setRegion(String region) {
    // Note: Firebase Functions region is set at initialization
    // This method is for documentation purposes
    debugPrint('Functions region should be set during initialization: $region');
  }
}
