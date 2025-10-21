import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

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

  /// Add coins
  void addCoins(int amount) {
    _userProfile = _userProfile.copyWith(coins: _userProfile.coins + amount);
    notifyListeners();
  }

  /// Spend coins (returns true if successful)
  bool spendCoins(int amount) {
    if (_userProfile.coins >= amount) {
      _userProfile = _userProfile.copyWith(coins: _userProfile.coins - amount);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update avatar frame
  void updateAvatarFrame(String frameStyle) {
    _userProfile = _userProfile.copyWith(avatarFrame: frameStyle);
    notifyListeners();
  }

  /// Update bubble skin
  void updateBubbleSkin(String? bubbleSkin) {
    _userProfile = _userProfile.copyWith(equippedBubbleSkin: bubbleSkin);
    notifyListeners();
  }

  /// Update victory taunt
  void updateVictoryTaunt(String? taunt) {
    _userProfile = _userProfile.copyWith(equippedVictoryTaunt: taunt);
    notifyListeners();
  }

  /// Add hint refills
  void addHintRefills(int amount) {
    _userProfile = _userProfile.copyWith(
      hintRefills: _userProfile.hintRefills + amount,
    );
    notifyListeners();
  }

  /// Use a hint refill (returns true if successful)
  bool useHintRefill() {
    if (_userProfile.hintRefills > 0) {
      _userProfile = _userProfile.copyWith(
        hintRefills: _userProfile.hintRefills - 1,
      );
      notifyListeners();
      return true;
    }
    return false;
  }
}
