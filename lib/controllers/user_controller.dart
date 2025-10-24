import '../core/base/base_controller.dart';
import '../core/utils/result.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

/// Controller for user profile management
/// Handles user-related UI state and operations
class UserController extends BaseController {
  final UserService _userService;
  
  UserProfile? _currentUser;
  
  UserController(this._userService);
  
  UserProfile? get currentUser => _currentUser;
  
  @override
  Future<void> initialize() async {
    setLoading(true);
    clearError();
    
    try {
      final result = await _userService.getCurrentUser();
      
      result
        .onSuccess((user) {
          _currentUser = user;
        })
        .onFailure((error) {
          setError(error);
        });
    } catch (e) {
      setError('Failed to initialize user: $e');
    } finally {
      setLoading(false);
    }
  }
  
  /// Update user profile
  Future<bool> updateProfile(UserProfile profile) async {
    setLoading(true);
    clearError();
    
    try {
      final result = await _userService.updateProfile(profile);
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to update profile: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  /// Add XP to user
  Future<bool> addXP(int amount) async {
    if (_currentUser == null) return false;
    
    try {
      final result = await _userService.addXP(_currentUser!.userId, amount);
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to add XP: $e');
      return false;
    }
  }
  
  /// Update username
  Future<bool> updateUsername(String newUsername) async {
    if (_currentUser == null) return false;
    
    setLoading(true);
    clearError();
    
    try {
      final result = await _userService.updateUsername(_currentUser!.userId, newUsername);
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to update username: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  /// Update avatar
  Future<bool> updateAvatar(String avatarUrl) async {
    if (_currentUser == null) return false;
    
    setLoading(true);
    clearError();
    
    try {
      final result = await _userService.updateAvatar(_currentUser!.userId, avatarUrl);
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to update avatar: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  /// Equip avatar frame (must be unlocked first)
  Future<bool> equipAvatarFrame(String frameId) async {
    if (_currentUser == null) return false;
    
    // Check if frame is unlocked
    if (!_currentUser!.unlockedFrames.contains(frameId)) {
      setError('Frame is not unlocked');
      return false;
    }
    
    try {
      final updatedUser = _currentUser!.copyWith(
        avatarFrame: frameId,
        activeFrameId: frameId,
      );
      
      final result = await _userService.updateProfile(updatedUser);
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to equip frame: $e');
      return false;
    }
  }
  
  /// Purchase and unlock a frame
  Future<bool> purchaseFrame(String frameId, int cost) async {
    if (_currentUser == null) return false;
    
    // Check if user has enough coins
    if (_currentUser!.coins < cost) {
      setError('Not enough coins');
      return false;
    }
    
    // Check if already unlocked
    if (_currentUser!.unlockedFrames.contains(frameId)) {
      setError('Frame already unlocked');
      return false;
    }
    
    try {
      final updatedFrames = List<String>.from(_currentUser!.unlockedFrames)..add(frameId);
      final updatedUser = _currentUser!.copyWith(
        coins: _currentUser!.coins - cost,
        unlockedFrames: updatedFrames,
      );
      
      final result = await _userService.updateProfile(updatedUser);
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to purchase frame: $e');
      return false;
    }
  }
  
  /// Check if a frame is unlocked
  bool isFrameUnlocked(String frameId) {
    if (_currentUser == null) return false;
    return _currentUser!.unlockedFrames.contains(frameId);
  }
  
  /// Add coins to user
  Future<bool> addCoins(int amount) async {
    if (_currentUser == null) return false;
    
    try {
      final updatedUser = _currentUser!.copyWith(
        coins: _currentUser!.coins + amount,
      );
      
      final result = await _userService.updateProfile(updatedUser);
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } catch (e) {
      setError('Failed to add coins: $e');
      return false;
    }
  }
}