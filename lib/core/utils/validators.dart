/// Validation utilities for input validation
class Validators {
  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must not exceed 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
  
  /// Validate room code
  static String? validateRoomCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room code cannot be empty';
    }
    if (value.length != 6) {
      return 'Room code must be 6 characters';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
      return 'Room code can only contain uppercase letters and numbers';
    }
    return null;
  }
  
  /// Validate question text
  static String? validateQuestion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Question cannot be empty';
    }
    if (value.length < 5) {
      return 'Question must be at least 5 characters';
    }
    if (value.length > 200) {
      return 'Question must not exceed 200 characters';
    }
    return null;
  }
  
  /// Validate secret word
  static String? validateSecretWord(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Secret word cannot be empty';
    }
    if (value.length < 3) {
      return 'Secret word must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Secret word must not exceed 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Secret word can only contain letters';
    }
    return null;
  }
}
