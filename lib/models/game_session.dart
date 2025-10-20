import 'user_profile.dart';

/// Game status enum
enum GameStatus {
  waiting,
  active,
  finished,
}

/// Game session model representing an active game
class GameSession {
  final String sessionId;
  final String? roomCode;
  final UserProfile player1;
  final UserProfile? player2;
  final String secretWord;
  final int bounty;
  final int currentRound;
  final int timer;
  final GameStatus gameStatus;

  GameSession({
    required this.sessionId,
    this.roomCode,
    required this.player1,
    this.player2,
    required this.secretWord,
    required this.bounty,
    required this.currentRound,
    required this.timer,
    required this.gameStatus,
  });

  /// Create a copy with modified fields
  GameSession copyWith({
    String? sessionId,
    String? roomCode,
    UserProfile? player1,
    UserProfile? player2,
    String? secretWord,
    int? bounty,
    int? currentRound,
    int? timer,
    GameStatus? gameStatus,
  }) {
    return GameSession(
      sessionId: sessionId ?? this.sessionId,
      roomCode: roomCode ?? this.roomCode,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      secretWord: secretWord ?? this.secretWord,
      bounty: bounty ?? this.bounty,
      currentRound: currentRound ?? this.currentRound,
      timer: timer ?? this.timer,
      gameStatus: gameStatus ?? this.gameStatus,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'roomCode': roomCode,
      'player1': player1.toJson(),
      'player2': player2?.toJson(),
      'secretWord': secretWord,
      'bounty': bounty,
      'currentRound': currentRound,
      'timer': timer,
      'gameStatus': gameStatus.name,
    };
  }

  /// Create from JSON
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      sessionId: json['sessionId'] as String,
      roomCode: json['roomCode'] as String?,
      player1: UserProfile.fromJson(json['player1'] as Map<String, dynamic>),
      player2: json['player2'] != null
          ? UserProfile.fromJson(json['player2'] as Map<String, dynamic>)
          : null,
      secretWord: json['secretWord'] as String,
      bounty: json['bounty'] as int,
      currentRound: json['currentRound'] as int,
      timer: json['timer'] as int,
      gameStatus: GameStatus.values.firstWhere(
        (e) => e.name == json['gameStatus'],
        orElse: () => GameStatus.waiting,
      ),
    );
  }

  /// Create a mock game session for prototype
  factory GameSession.mock({
    String sessionId = 'session123',
    String? roomCode,
    UserProfile? player1,
    UserProfile? player2,
    String secretWord = 'BUTTERFLY',
    int bounty = 100,
    int currentRound = 1,
    int timer = 10,
    GameStatus gameStatus = GameStatus.active,
  }) {
    return GameSession(
      sessionId: sessionId,
      roomCode: roomCode,
      player1: player1 ?? UserProfile.mock(username: 'Player 1'),
      player2: player2 ?? UserProfile.mock(userId: 'user456', username: 'Player 2', avatar: 'https://i.pravatar.cc/150?img=2'),
      secretWord: secretWord,
      bounty: bounty,
      currentRound: currentRound,
      timer: timer,
      gameStatus: gameStatus,
    );
  }
}
