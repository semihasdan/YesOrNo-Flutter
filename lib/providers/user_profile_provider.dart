import 'package:flutter/foundation.dart';
import 'package:yes_or_no/models/user_profile.dart';

/// Provider for user profile state management
class UserProfileProvider extends ChangeNotifier {
  UserProfile _userProfile = UserProfile.mock();

  UserProfile get userProfile => _userProfile;

  /// Update user profile
  void updateProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners();
  }

  /// Update XP
  void updateXP(int newXP) {
    _userProfile = _userProfile.copyWith(xp: newXP);
    notifyListeners();
  }

  /// Add XP
  void addXP(int amount) {
    final newXP = _userProfile.xp + amount;
    if (newXP >= _userProfile.xpMax) {
      // Level up logic would go here
      _userProfile = _userProfile.copyWith(
        xp: newXP - _userProfile.xpMax,
      );
    } else {
      _userProfile = _userProfile.copyWith(xp: newXP);
    }
    notifyListeners();
  }

  /// Update username
  void updateUsername(String newUsername) {
    _userProfile = _userProfile.copyWith(username: newUsername);
    notifyListeners();
  }

  /// Update avatar
  void updateAvatar(String newAvatar) {
    _userProfile = _userProfile.copyWith(avatar: newAvatar);
    notifyListeners();
  }
}
