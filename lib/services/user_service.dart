import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/base/base_service.dart';
import '../core/utils/result.dart';
import '../core/utils/device_utils.dart';
import '../data/repositories/user_repository.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

/// Service for user-related business logic
/// Encapsulates user operations and business rules
class UserService implements BaseService {
  final UserRepository _userRepository;
  final AuthService _authService;
  
  UserService(this._userRepository, this._authService);
  
  @override
  Future<void> initialize() async {
    // Load initial user data if needed
    // await getCurrentUser();
  }
  
  @override
  void dispose() {
    // Cleanup resources if needed
  }
  
  /// MAIN METHOD: Handle complete Quick Start setup flow
  /// This orchestrates the entire authentication and profile creation process
  /// 
  /// Returns Success with UserProfile if setup completes successfully
  /// Returns Failure with error message if any step fails
  Future<Result<UserProfile>> handleQuickStartSetup() async {
    try {
      // STEP 1: Get device unique identifier
      debugPrint('QuickStart Step 1: Retrieving device ID...');
      final String deviceId = await DeviceUtils.getDeviceId();
      debugPrint('Device ID retrieved: $deviceId');

      // STEP 2: Firebase Anonymous Authentication
      debugPrint('QuickStart Step 2: Authenticating user...');
      final authResult = await _authService.signInAnonymously();
      
      if (authResult is Failure) {
        return Failure((authResult as Failure).message);
      }
      
      final String userId = (authResult as Success<String>).data;
      debugPrint('User authenticated with UID: $userId');

      // STEP 3: Check if profile already exists
      debugPrint('QuickStart Step 3: Checking if profile exists...');
      final bool profileExists = await _userRepository.userExists(userId);

      UserProfile userProfile;

      if (profileExists) {
        // STEP 4A: Existing user - Fetch profile
        debugPrint('QuickStart Step 4A: Fetching existing profile...');
        final existingProfile = await _userRepository.getById(userId);
        
        if (existingProfile == null) {
          return const Failure('Failed to retrieve existing profile');
        }
        
        userProfile = existingProfile;
        debugPrint('Existing user profile loaded for: ${userProfile.username}');
      } else {
        // STEP 4B: New user - Create profile
        debugPrint('QuickStart Step 4B: Creating new user profile...');
        
        final newProfile = UserProfile.initial(
          userId: userId,
          deviceId: deviceId,
        );
        
        userProfile = await _userRepository.create(newProfile);
        debugPrint('New user profile created: ${userProfile.username}');
      }

      return Success(userProfile);
      
    } on FirebaseException catch (e) {
      debugPrint('Firebase error in QuickStart: ${e.code} - ${e.message}');
      return Failure('Firebase error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error in QuickStart: $e');
      return Failure('Setup failed: $e');
    }
  }
  
  /// Get current logged-in user
  Future<Result<UserProfile>> getCurrentUser() async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        return const Failure('User not found');
      }
      return Success(user);
    } catch (e) {
      return Failure('Failed to get user: $e');
    }
  }
  
  /// Update user profile
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final updatedProfile = await _userRepository.update(profile.userId, profile);
      return Success(updatedProfile);
    } catch (e) {
      return Failure('Failed to update profile: $e');
    }
  }
  
  /// Add XP to user
  Future<Result<UserProfile>> addXP(String userId, int amount) async {
    try {
      final user = await _userRepository.getById(userId);
      if (user == null) {
        return const Failure('User not found');
      }
      
      int newXP = user.xp + amount;
      int newXPMax = user.xpMax;
      
      // Handle level up
      if (newXP >= user.xpMax) {
        newXP = newXP - user.xpMax;
        newXPMax = (user.xpMax * 1.5).toInt(); // Increase XP requirement
        // TODO: Handle rank promotion
      }
      
      final updatedUser = user.copyWith(xp: newXP, xpMax: newXPMax);
      final result = await _userRepository.update(userId, updatedUser);
      
      return Success(result);
    } catch (e) {
      return Failure('Failed to add XP: $e');
    }
  }
  
  /// Update username
  Future<Result<UserProfile>> updateUsername(String userId, String newUsername) async {
    try {
      final user = await _userRepository.getById(userId);
      if (user == null) {
        return const Failure('User not found');
      }
      
      final updatedUser = user.copyWith(username: newUsername);
      final result = await _userRepository.update(userId, updatedUser);
      
      return Success(result);
    } catch (e) {
      return Failure('Failed to update username: $e');
    }
  }
  
  /// Update avatar
  Future<Result<UserProfile>> updateAvatar(String userId, String avatarUrl) async {
    try {
      final result = await _userRepository.updateAvatar(userId, avatarUrl);
      return Success(result);
    } catch (e) {
      return Failure('Failed to update avatar: $e');
    }
  }
}
