import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_data.dart';
import 'game_history_entry.dart';

/// Game state enum representing the current phase of the multiplayer game
enum GameState {
  matching,             // Players matched, waiting for initialization
  initializing,         // Backend selecting secret word and populating data
  roundInProgress,      // Round active, awaiting questions (10s timer)
  waitingForAnswers,    // AI is judging questions
  finalGuessPhase,      // Round 10 complete, 15s final guess timer
  gameOver,             // Match concluded
}

/// Extension for GameState to convert to/from Firestore
extension GameStateExtension on GameState {
  String toFirestore() {
    switch (this) {
      case GameState.matching:
        return 'MATCHING';
      case GameState.initializing:
        return 'INITIALIZING';
      case GameState.roundInProgress:
        return 'ROUND_IN_PROGRESS';
      case GameState.waitingForAnswers:
        return 'WAITING_FOR_ANSWERS';
      case GameState.finalGuessPhase:
        return 'FINAL_GUESS_PHASE';
      case GameState.gameOver:
        return 'GAME_OVER';
    }
  }

  static GameState fromFirestore(String value) {
    switch (value) {
      case 'MATCHING':
        return GameState.matching;
      case 'INITIALIZING':
        return GameState.initializing;
      case 'ROUND_IN_PROGRESS':
        return GameState.roundInProgress;
      case 'WAITING_FOR_ANSWERS':
        return GameState.waitingForAnswers;
      case 'FINAL_GUESS_PHASE':
        return GameState.finalGuessPhase;
      case 'GAME_OVER':
        return GameState.gameOver;
      default:
        return GameState.matching;
    }
  }
}

/// Multiplayer game session model
/// Single source of truth for 1v1 AI-adjudicated game
class MultiplayerGameSession {
  // State & Metadata
  final String gameId;
  final GameState state;
  final int currentRound;
  final DateTime? roundTimerEndsAt;
  final String? secretWord;
  final String? category;
  final String? winnerId;

  // Player Data
  final List<String> playerIds;
  final Map<String, PlayerData> players;

  // Game Log
  final List<GameHistoryEntry> history;

  MultiplayerGameSession({
    required this.gameId,
    required this.state,
    required this.currentRound,
    this.roundTimerEndsAt,
    this.secretWord,
    this.category,
    this.winnerId,
    required this.playerIds,
    required this.players,
    required this.history,
  });

  /// Create a copy with modified fields
  MultiplayerGameSession copyWith({
    String? gameId,
    GameState? state,
    int? currentRound,
    DateTime? roundTimerEndsAt,
    String? secretWord,
    String? category,
    String? winnerId,
    List<String>? playerIds,
    Map<String, PlayerData>? players,
    List<GameHistoryEntry>? history,
  }) {
    return MultiplayerGameSession(
      gameId: gameId ?? this.gameId,
      state: state ?? this.state,
      currentRound: currentRound ?? this.currentRound,
      roundTimerEndsAt: roundTimerEndsAt ?? this.roundTimerEndsAt,
      secretWord: secretWord ?? this.secretWord,
      category: category ?? this.category,
      winnerId: winnerId ?? this.winnerId,
      playerIds: playerIds ?? this.playerIds,
      players: players ?? this.players,
      history: history ?? this.history,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'state': state.toFirestore(),
      'currentRound': currentRound,
      'roundTimerEndsAt': roundTimerEndsAt != null 
          ? Timestamp.fromDate(roundTimerEndsAt!) 
          : null,
      'secretWord': secretWord,
      'category': category,
      'winnerId': winnerId,
      'playerIds': playerIds,
      'players': players.map((key, value) => MapEntry(key, value.toJson())),
      'history': history.map((e) => e.toJson()).toList(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Create from Firestore document
  factory MultiplayerGameSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MultiplayerGameSession._fromMap(doc.id, data);
  }

  /// Create from JSON with gameId
  factory MultiplayerGameSession.fromJson(String gameId, Map<String, dynamic> json) {
    return MultiplayerGameSession._fromMap(gameId, json);
  }

  /// Internal method to parse map data
  static MultiplayerGameSession _fromMap(String gameId, Map<String, dynamic> data) {
    // Parse players map
    final playersMap = <String, PlayerData>{};
    if (data['players'] != null) {
      (data['players'] as Map<String, dynamic>).forEach((key, value) {
        playersMap[key] = PlayerData.fromJson(value as Map<String, dynamic>);
      });
    }

    // Parse history array
    final historyList = <GameHistoryEntry>[];
    if (data['history'] != null) {
      for (var entry in data['history'] as List) {
        historyList.add(GameHistoryEntry.fromJson(entry as Map<String, dynamic>));
      }
    }

    return MultiplayerGameSession(
      gameId: gameId,
      state: GameStateExtension.fromFirestore(data['state'] as String? ?? 'MATCHING'),
      currentRound: data['currentRound'] as int? ?? 0,
      roundTimerEndsAt: data['roundTimerEndsAt'] != null
          ? (data['roundTimerEndsAt'] is Timestamp
              ? (data['roundTimerEndsAt'] as Timestamp).toDate()
              : DateTime.parse(data['roundTimerEndsAt'] as String))
          : null,
      secretWord: data['secretWord'] as String?,
      category: data['category'] as String?,
      winnerId: data['winnerId'] as String?,
      playerIds: List<String>.from(data['playerIds'] as List? ?? []),
      players: playersMap,
      history: historyList,
    );
  }

  /// Factory for creating initial game session (matchmaking)
  factory MultiplayerGameSession.createMatching({
    required String gameId,
    required List<String> playerIds,
  }) {
    return MultiplayerGameSession(
      gameId: gameId,
      state: GameState.matching,
      currentRound: 0,
      playerIds: playerIds,
      players: {},
      history: [],
    );
  }

  /// Get current user's player data
  PlayerData? getPlayerData(String userId) {
    return players[userId];
  }

  /// Get opponent's player data
  PlayerData? getOpponentData(String currentUserId) {
    final opponentId = playerIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return opponentId.isNotEmpty ? players[opponentId] : null;
  }

  /// Get opponent's user ID
  String? getOpponentId(String currentUserId) {
    return playerIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Check if both players have submitted their questions
  bool get bothPlayersSubmitted {
    if (players.length != 2) return false;
    return players.values.every((player) => player.hasSubmittedQuestion);
  }

  /// Check if game is active (not in terminal state)
  bool get isActive {
    return state != GameState.gameOver;
  }

  /// Check if current user is the winner
  bool isWinner(String userId) {
    return winnerId == userId;
  }

  /// Check if game ended in draw
  bool get isDraw {
    return winnerId == 'draw';
  }

  /// Get remaining time in seconds (null if no timer)
  int? get remainingSeconds {
    if (roundTimerEndsAt == null) return null;
    final diff = roundTimerEndsAt!.difference(DateTime.now());
    return diff.inSeconds > 0 ? diff.inSeconds : 0;
  }

  /// Check if timer has expired
  bool get isTimerExpired {
    if (roundTimerEndsAt == null) return false;
    return DateTime.now().isAfter(roundTimerEndsAt!);
  }
}
