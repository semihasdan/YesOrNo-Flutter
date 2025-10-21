/// Win condition enum
enum WinCondition {
  correctGuess,
  opponentQuit,
  timeout,
}

/// Match result model representing the outcome of a game
class MatchResult {
  final String winnerId;
  final String loserId;
  final String secretWord;
  final int finalBounty;
  final int totalRounds;
  final WinCondition winCondition;

  MatchResult({
    required this.winnerId,
    required this.loserId,
    required this.secretWord,
    required this.finalBounty,
    required this.totalRounds,
    required this.winCondition,
  });

  /// Create a copy with modified fields
  MatchResult copyWith({
    String? winnerId,
    String? loserId,
    String? secretWord,
    int? finalBounty,
    int? totalRounds,
    WinCondition? winCondition,
  }) {
    return MatchResult(
      winnerId: winnerId ?? this.winnerId,
      loserId: loserId ?? this.loserId,
      secretWord: secretWord ?? this.secretWord,
      finalBounty: finalBounty ?? this.finalBounty,
      totalRounds: totalRounds ?? this.totalRounds,
      winCondition: winCondition ?? this.winCondition,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'winnerId': winnerId,
      'loserId': loserId,
      'secretWord': secretWord,
      'finalBounty': finalBounty,
      'totalRounds': totalRounds,
      'winCondition': winCondition.name,
    };
  }

  /// Create from JSON
  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      winnerId: json['winnerId'] as String,
      loserId: json['loserId'] as String,
      secretWord: json['secretWord'] as String,
      finalBounty: json['finalBounty'] as int,
      totalRounds: json['totalRounds'] as int,
      winCondition: WinCondition.values.firstWhere(
        (e) => e.name == json['winCondition'],
        orElse: () => WinCondition.correctGuess,
      ),
    );
  }

  /// Create a mock result for prototype
  factory MatchResult.mock({
    String winnerId = 'user123',
    String loserId = 'user456',
    String secretWord = 'BUTTERFLY',
    int finalBounty = 75,
    int totalRounds = 5,
    WinCondition winCondition = WinCondition.correctGuess,
  }) {
    return MatchResult(
      winnerId: winnerId,
      loserId: loserId,
      secretWord: secretWord,
      finalBounty: finalBounty,
      totalRounds: totalRounds,
      winCondition: winCondition,
    );
  }
}
