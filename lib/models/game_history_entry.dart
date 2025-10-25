/// Game history entry representing one round's questions and answers
/// Stored in the game session's history array
class GameHistoryEntry {
  final int round;
  final Map<String, RoundPlayerData> playerData;

  GameHistoryEntry({
    required this.round,
    required this.playerData,
  });

  /// Create a copy with modified fields
  GameHistoryEntry copyWith({
    int? round,
    Map<String, RoundPlayerData>? playerData,
  }) {
    return GameHistoryEntry(
      round: round ?? this.round,
      playerData: playerData ?? this.playerData,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'round': round,
    };
    
    // Add each player's data as a top-level field
    playerData.forEach((userId, data) {
      result[userId] = data.toJson();
    });
    
    return result;
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Create from Firestore document
  factory GameHistoryEntry.fromFirestore(Map<String, dynamic> data) {
    final round = data['round'] as int;
    final playerData = <String, RoundPlayerData>{};
    
    // Extract player data (all keys except 'round')
    data.forEach((key, value) {
      if (key != 'round' && value is Map<String, dynamic>) {
        playerData[key] = RoundPlayerData.fromJson(value);
      }
    });
    
    return GameHistoryEntry(
      round: round,
      playerData: playerData,
    );
  }

  /// Create from JSON
  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry.fromFirestore(json);
  }

  /// Get a player's data for this round
  RoundPlayerData? getPlayerData(String userId) {
    return playerData[userId];
  }

  /// Check if both players have data
  bool get isComplete => playerData.length == 2;
}

/// Player's question and answer for a specific round
class RoundPlayerData {
  final String question;
  final String answer;

  RoundPlayerData({
    required this.question,
    required this.answer,
  });

  /// Create a copy with modified fields
  RoundPlayerData copyWith({
    String? question,
    String? answer,
  }) {
    return RoundPlayerData(
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  /// Create from JSON
  factory RoundPlayerData.fromJson(Map<String, dynamic> json) {
    return RoundPlayerData(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  /// Check if answer is positive
  bool get isYes => answer.toUpperCase() == 'YES';

  /// Check if answer is negative
  bool get isNo => answer.toUpperCase() == 'NO';

  /// Check if answer is neutral/error
  bool get isNeutral => answer.toUpperCase() == 'NEUTRAL';
}
