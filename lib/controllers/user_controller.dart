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
}
