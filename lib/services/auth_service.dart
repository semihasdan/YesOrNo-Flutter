import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/base/base_service.dart';
import '../core/utils/result.dart';

/// Service for Firebase Authentication operations
/// Handles anonymous sign-in and authentication state management
class AuthService implements BaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> initialize() async {
    // Listen to auth state changes if needed
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('AuthService: User signed in: ${user.uid}');
      } else {
        debugPrint('AuthService: User signed out');
      }
    });
  }

  @override
  void dispose() {
    // Cleanup if needed
  }

  /// Sign in anonymously via Firebase Authentication
  /// 
  /// Returns:
  /// - Success with userId (UID) if authentication succeeds
  /// - Failure with error message if authentication fails
  /// 
  /// Note: If user is already signed in, returns existing UID
  Future<Result<String>> signInAnonymously() async {
    try {
      // Check if user is already signed in
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        debugPrint('User already authenticated: ${currentUser.uid}');
        return Success(currentUser.uid);
      }

      // Perform anonymous sign-in
      debugPrint('Attempting anonymous sign-in...');
      final UserCredential userCredential = 
          await _firebaseAuth.signInAnonymously();
      
      if (userCredential.user == null) {
        return const Failure('Authentication succeeded but user is null');
      }
      
      final String uid = userCredential.user!.uid;
      debugPrint('New anonymous user created: $uid');
      
      return Success(uid);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      
      // Handle specific error codes
      switch (e.code) {
        case 'network-request-failed':
          return const Failure('Network error. Please check your internet connection.');
        case 'operation-not-allowed':
          return const Failure('Anonymous authentication is not enabled. Please contact support.');
        default:
          return Failure('Authentication failed: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Unexpected error during authentication: $e');
      return Failure('Unexpected error: $e');
    }
  }

  /// Check if user is currently signed in
  bool isUserSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get current user ID (UID)
  /// Returns null if no user is signed in
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  /// Get current authenticated user
  /// Returns null if no user is signed in
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Verify if the current user session is valid
  /// 
  /// This method performs several checks:
  /// 1. Checks if user is authenticated locally
  /// 2. Reloads user data from Firebase to verify account still exists
  /// 3. Cleans up invalid sessions
  /// 
  /// Returns true if user session is valid, false otherwise
  Future<bool> verifyCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      
      // No user signed in locally
      if (user == null) {
        debugPrint('verifyCurrentUser: No user signed in locally');
        return false;
      }
      
      debugPrint('verifyCurrentUser: Verifying user session for UID: ${user.uid}');
      
      // Reload user data from Firebase to check if account still exists
      try {
        await user.reload();
        
        // After reload, check if user still exists
        final refreshedUser = _firebaseAuth.currentUser;
        if (refreshedUser == null) {
          debugPrint('verifyCurrentUser: User account no longer exists on Firebase');
          // Clean up local session
          await _firebaseAuth.signOut();
          return false;
        }
        
        debugPrint('verifyCurrentUser: User session verified successfully');
        return true;
        
      } on FirebaseAuthException catch (e) {
        debugPrint('verifyCurrentUser: Firebase auth error - ${e.code}');
        
        // Handle specific error cases
        switch (e.code) {
          case 'user-not-found':
          case 'user-disabled':
          case 'user-token-expired':
            debugPrint('verifyCurrentUser: User account is invalid, cleaning up session');
            await _firebaseAuth.signOut();
            return false;
          
          case 'network-request-failed':
            // Network error - assume user is valid for now
            // They can still use the app offline
            debugPrint('verifyCurrentUser: Network error, allowing offline access');
            return true;
          
          default:
            // For unknown errors, sign out for safety
            debugPrint('verifyCurrentUser: Unknown auth error, signing out for safety');
            await _firebaseAuth.signOut();
            return false;
        }
      }
    } catch (e) {
      debugPrint('verifyCurrentUser: Unexpected error: $e');
      // For safety, sign out on unexpected errors
      await _firebaseAuth.signOut();
      return false;
    }
  }

  /// Sign out current user
  /// Used for testing or when implementing full sign-out feature
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('User signed out successfully');
      return const Success(null);
    } catch (e) {
      debugPrint('Error signing out: $e');
      return Failure('Sign out failed: $e');
    }
  }

  /// Delete current user account
  /// Use with caution - this is irreversible
  Future<Result<void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Failure('No user signed in');
      }
      
      await user.delete();
      debugPrint('User account deleted successfully');
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during delete: ${e.code} - ${e.message}');
      return Failure('Failed to delete account: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return Failure('Failed to delete account: $e');
    }
  }


}
