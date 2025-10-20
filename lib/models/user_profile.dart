/// User profile model representing a player's account information
class UserProfile {
  final String userId;
  final String username;
  final String avatar;
  final String rank;
  final String rankIcon;
  final int xp;
  final int xpMax;

  UserProfile({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.rank,
    required this.rankIcon,
    required this.xp,
    required this.xpMax,
  });

  /// Create a copy with modified fields
  UserProfile copyWith({
    String? userId,
    String? username,
    String? avatar,
    String? rank,
    String? rankIcon,
    int? xp,
    int? xpMax,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      rank: rank ?? this.rank,
      rankIcon: rankIcon ?? this.rankIcon,
      xp: xp ?? this.xp,
      xpMax: xpMax ?? this.xpMax,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'rank': rank,
      'rankIcon': rankIcon,
      'xp': xp,
      'xpMax': xpMax,
    };
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
      rank: json['rank'] as String,
      rankIcon: json['rankIcon'] as String,
      xp: json['xp'] as int,
      xpMax: json['xpMax'] as int,
    );
  }

  /// Create a mock user for prototype
  factory UserProfile.mock({
    String userId = 'user123',
    String username = 'Player1',
    String avatar = 'https://i.pravatar.cc/150?img=1',
    String rank = 'Bronze Rank',
    String rankIcon = 'military_tech',
    int xp = 250,
    int xpMax = 500,
  }) {
    return UserProfile(
      userId: userId,
      username: username,
      avatar: avatar,
      rank: rank,
      rankIcon: rankIcon,
      xp: xp,
      xpMax: xpMax,
    );
  }
}
