/// Player data within a multiplayer game session
/// Contains player-specific game state information
class PlayerData {
  final String username;
  final String avatarUrl;
  final String avatarFrameId;
  final int remainingGuesses;
  final String? currentQuestion;
  final String? lastAnswer;
  final bool isReadyForNextRound;

  PlayerData({
    required this.username,
    required this.avatarUrl,
    required this.avatarFrameId,
    required this.remainingGuesses,
    this.currentQuestion,
    this.lastAnswer,
    this.isReadyForNextRound = false,
  });

  /// Create a copy with modified fields
  PlayerData copyWith({
    String? username,
    String? avatarUrl,
    String? avatarFrameId,
    int? remainingGuesses,
    String? currentQuestion,
    String? lastAnswer,
    bool? isReadyForNextRound,
  }) {
    return PlayerData(
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarFrameId: avatarFrameId ?? this.avatarFrameId,
      remainingGuesses: remainingGuesses ?? this.remainingGuesses,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      isReadyForNextRound: isReadyForNextRound ?? this.isReadyForNextRound,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatarUrl': avatarUrl,
      'avatarFrameId': avatarFrameId,
      'remainingGuesses': remainingGuesses,
      'currentQuestion': currentQuestion,
      'lastAnswer': lastAnswer,
      'isReadyForNextRound': isReadyForNextRound,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Create from Firestore document
  factory PlayerData.fromFirestore(Map<String, dynamic> data) {
    return PlayerData(
      username: data['username'] as String,
      avatarUrl: data['avatarUrl'] as String,
      avatarFrameId: data['avatarFrameId'] as String? ?? 'basic',
      remainingGuesses: data['remainingGuesses'] as int? ?? 3,
      currentQuestion: data['currentQuestion'] as String?,
      lastAnswer: data['lastAnswer'] as String?,
      isReadyForNextRound: data['isReadyForNextRound'] as bool? ?? false,
    );
  }

  /// Create from JSON
  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData.fromFirestore(json);
  }

  /// Factory for initial player data creation
  factory PlayerData.initial({
    required String username,
    required String avatarUrl,
    String avatarFrameId = 'basic',
  }) {
    return PlayerData(
      username: username,
      avatarUrl: avatarUrl,
      avatarFrameId: avatarFrameId,
      remainingGuesses: 3,
      currentQuestion: null,
      lastAnswer: null,
      isReadyForNextRound: false,
    );
  }

  /// Check if player has submitted current question
  bool get hasSubmittedQuestion => currentQuestion != null && currentQuestion!.isNotEmpty;

  /// Check if player can still make final guesses
  bool get canMakeFinalGuess => remainingGuesses > 0;
}
