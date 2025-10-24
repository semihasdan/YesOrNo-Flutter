import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/base/base_repository.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';

/// Repository for user data management
/// Handles CRUD operations for user profiles using Cloud Firestore
class UserRepository implements BaseRepository<UserProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';
  final AuthService _authService;
  
  UserRepository(this._authService);
  
  /// Check if user profile exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }
  
  @override
  Future<UserProfile?> getById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      
      if (!doc.exists || doc.data() == null) {
        debugPrint('User document not found: $id');
        return null;
      }
      
      return UserProfile.fromFirestore(doc.data()!);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }
  
  @override
  Future<List<UserProfile>> getAll() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all users: $e');
      return [];
    }
  }
  
  @override
  Future<UserProfile> create(UserProfile entity) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(entity.userId)
          .set(entity.toFirestore());
      
      debugPrint('User profile created: ${entity.userId}');
      return entity;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }
  
  @override
  Future<UserProfile> update(String id, UserProfile entity) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(entity.toFirestore());
      
      debugPrint('User profile updated: $id');
      return entity;
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }
  
  @override
  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      debugPrint('User profile deleted: $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
  
  /// Get current logged-in user from Firebase
  Future<UserProfile?> getCurrentUser() async {
    try {
      // Get current user's UID from Firebase Auth
      final String? userId = _authService.getCurrentUserId();
      
      if (userId == null) {
        debugPrint('No authenticated user found');
        return null;
      }
      
      debugPrint('Fetching user profile for UID: $userId');
      
      // Fetch user profile from 'users' collection using UID
      final userProfile = await getById(userId);
      
      if (userProfile == null) {
        debugPrint('User profile not found in Firestore for UID: $userId');
        return null;
      }
      
      debugPrint('Successfully loaded user profile: ${userProfile.username}');
      return userProfile;
    } catch (e) {
      debugPrint('Error fetching current user profile: $e');
      return null;
    }
  }
  
  /// Update user XP
  Future<UserProfile> updateXP(String userId, int newXP) async {
    final user = await getById(userId);
    if (user == null) {
      throw Exception('User not found');
    }
    
    final updatedUser = user.copyWith(xp: newXP);
    return update(userId, updatedUser);
  }
  
  /// Update user avatar
  Future<UserProfile> updateAvatar(String userId, String avatarUrl) async {
    final user = await getById(userId);
    if (user == null) {
      throw Exception('User not found');
    }
    
    final updatedUser = user.copyWith(avatar: avatarUrl);
    return update(userId, updatedUser);
  }
}
