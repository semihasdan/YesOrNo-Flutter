import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/base/base_repository.dart';
import '../../models/user_profile.dart';

/// Repository for user data management
/// Handles CRUD operations for user profiles using Cloud Firestore
class UserRepository implements BaseRepository<UserProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';
  
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
  
  /// Get current logged-in user (returns mock for now, will integrate with auth)
  Future<UserProfile?> getCurrentUser() async {
    // TODO: Integrate with AuthService to get current user ID
    // For now, return mock user for backwards compatibility
    return UserProfile.mock();
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
