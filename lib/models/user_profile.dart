/// User profile model representing a player's account information
class UserProfile {
  final String userId;
  final String username;
  final String avatar;
  final String rank;
  final String rankIcon;
  final int xp;
  final int xpMax;
  final String avatarFrame; // Equipped avatar frame style (legacy)
  final String activeAvatarFrameId; // Currently active avatar frame ID
  final String? activeVictoryTauntId; // Currently active victory taunt ID
  final int coins; // User's coin balance
  final String? equippedBubbleSkin; // Equipped question bubble skin
  final String? equippedVictoryTaunt; // Equipped victory taunt/emote (legacy)
  final int hintRefills; // Number of hint refills owned
  
  // User statistics
  final UserStats stats;
  
  // Device tracking and session management
  final String deviceId; // Device unique identifier
  final DateTime createTime; // Account creation timestamp
  final int totalPoints; // Total points earned
  final int gamesPlayed; // Total games played
  final int gamesLosed;
  final int streakCount;
  final String activeFrameId; // Currently active frame
  final Map<String, int> powerUps; // Power-ups inventory
  final List<String> unlockedFrames; // List of unlocked frame IDs

  UserProfile({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.rank,
    required this.rankIcon,
    required this.xp,
    required this.xpMax,
    this.avatarFrame = 'basic',
    this.activeAvatarFrameId = 'basic',
    this.activeVictoryTauntId,
    this.coins = 0,
    this.equippedBubbleSkin,
    this.equippedVictoryTaunt,
    this.hintRefills = 0,
    required this.deviceId,
    required this.createTime,
    this.totalPoints = 1000,
    this.gamesPlayed = 0,
    this.gamesLosed = 0,
    this.streakCount = 0,
    this.activeFrameId = 'default_frame',
    Map<String, int>? powerUps,
    List<String>? unlockedFrames,
    UserStats? stats,
  }) : powerUps = powerUps ?? {'mindShieldsCount': 0, 'hintRefillsCount': 3},
       unlockedFrames = unlockedFrames ?? ['basic', 'default_frame'],
       stats = stats ?? UserStats.initial();

  /// Create a copy with modified fields
  UserProfile copyWith({
    String? userId,
    String? username,
    String? avatar,
    String? rank,
    String? rankIcon,
    int? xp,
    int? xpMax,
    String? avatarFrame,
    String? activeAvatarFrameId,
    String? activeVictoryTauntId,
    int? coins,
    String? equippedBubbleSkin,
    String? equippedVictoryTaunt,
    int? hintRefills,
    String? deviceId,
    DateTime? createTime,
    int? totalPoints,
    int? gamesPlayed,
    int? gamesLosed,
    int? streakCount,
    String? activeFrameId,
    Map<String, int>? powerUps,
    List<String>? unlockedFrames,
    UserStats? stats,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      rank: rank ?? this.rank,
      rankIcon: rankIcon ?? this.rankIcon,
      xp: xp ?? this.xp,
      xpMax: xpMax ?? this.xpMax,
      avatarFrame: avatarFrame ?? this.avatarFrame,
      activeAvatarFrameId: activeAvatarFrameId ?? this.activeAvatarFrameId,
      activeVictoryTauntId: activeVictoryTauntId ?? this.activeVictoryTauntId,
      coins: coins ?? this.coins,
      equippedBubbleSkin: equippedBubbleSkin ?? this.equippedBubbleSkin,
      equippedVictoryTaunt: equippedVictoryTaunt ?? this.equippedVictoryTaunt,
      hintRefills: hintRefills ?? this.hintRefills,
      deviceId: deviceId ?? this.deviceId,
      createTime: createTime ?? this.createTime,
      totalPoints: totalPoints ?? this.totalPoints,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesLosed: gamesLosed ?? this.gamesLosed,
      streakCount: streakCount ?? this.streakCount,
      activeFrameId: activeFrameId ?? this.activeFrameId,
      powerUps: powerUps ?? this.powerUps,
      unlockedFrames: unlockedFrames ?? this.unlockedFrames,
      stats: stats ?? this.stats,
    );
  }

  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'rank': rank,
      'rankIcon': rankIcon,
      'xp': xp,
      'xpMax': xpMax,
      'avatarFrame': avatarFrame,
      'activeAvatarFrameId': activeAvatarFrameId,
      'activeVictoryTauntId': activeVictoryTauntId,
      'coins': coins,
      'equippedBubbleSkin': equippedBubbleSkin,
      'equippedVictoryTaunt': equippedVictoryTaunt,
      'hintRefills': hintRefills,
      'deviceId': deviceId,
      'createTime': createTime.toIso8601String(),
      'totalPoints': totalPoints,
      'gamesPlayed': gamesPlayed,
      'gamesLosed': gamesLosed,
      'streakCount': streakCount,
      'activeFrameId': activeFrameId,
      'powerUps': powerUps,
      'unlockedFrames': unlockedFrames,
      'stats': stats.toJson(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'rank': rank,
      'rankIcon': rankIcon,
      'xp': xp,
      'xpMax': xpMax,
      'avatarFrame': avatarFrame,
      'activeAvatarFrameId': activeAvatarFrameId,
      'activeVictoryTauntId': activeVictoryTauntId,
      'coins': coins,
      'equippedBubbleSkin': equippedBubbleSkin,
      'equippedVictoryTaunt': equippedVictoryTaunt,
      'hintRefills': hintRefills,
      'deviceId': deviceId,
      'createTime': createTime.toIso8601String(),
      'totalPoints': totalPoints,
      'gamesPlayed': gamesPlayed,
      'gamesLosed': gamesLosed,
      'streakCount': streakCount,
      'activeFrameId': activeFrameId,
      'powerUps': powerUps,
      'unlockedFrames': unlockedFrames,
      'stats': stats.toJson(),
    };
  }

  /// Create from JSON (for local storage)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
      rank: json['rank'] as String,
      rankIcon: json['rankIcon'] as String,
      xp: json['xp'] as int,
      xpMax: json['xpMax'] as int,
      avatarFrame: json['avatarFrame'] as String? ?? 'basic',
      activeAvatarFrameId: json['activeAvatarFrameId'] as String? ?? 'basic',
      activeVictoryTauntId: json['activeVictoryTauntId'] as String?,
      coins: json['coins'] as int? ?? 0,
      equippedBubbleSkin: json['equippedBubbleSkin'] as String?,
      equippedVictoryTaunt: json['equippedVictoryTaunt'] as String?,
      hintRefills: json['hintRefills'] as int? ?? 0,
      deviceId: json['deviceId'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      totalPoints: json['totalPoints'] as int? ?? 1000,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesLosed: json['gamesLosed'] as int? ?? 0,
      streakCount: json['streakCount'] as int? ?? 0,
      activeFrameId: json['activeFrameId'] as String? ?? 'default_frame',
      powerUps: Map<String, int>.from(json['powerUps'] as Map? ?? {}),
      unlockedFrames: List<String>.from(json['unlockedFrames'] as List? ?? ['basic', 'default_frame']),
      stats: json['stats'] != null 
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : UserStats.initial(),
    );
  }

  /// Create from Firestore document
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] as String,
      username: data['username'] as String,
      avatar: data['avatar'] as String,
      rank: data['rank'] as String,
      rankIcon: data['rankIcon'] as String,
      xp: data['xp'] as int,
      xpMax: data['xpMax'] as int,
      avatarFrame: data['avatarFrame'] as String? ?? 'basic',
      activeAvatarFrameId: data['activeAvatarFrameId'] as String? ?? 'basic',
      activeVictoryTauntId: data['activeVictoryTauntId'] as String?,
      coins: data['coins'] as int? ?? 0,
      equippedBubbleSkin: data['equippedBubbleSkin'] as String?,
      equippedVictoryTaunt: data['equippedVictoryTaunt'] as String?,
      hintRefills: data['hintRefills'] as int? ?? 0,
      deviceId: data['deviceId'] as String,
      createTime: DateTime.parse(data['createTime'] as String),
      totalPoints: data['totalPoints'] as int? ?? 1000,
      gamesPlayed: data['gamesPlayed'] as int? ?? 0,
      gamesLosed: data['gamesLosed'] as int? ?? 0,
      streakCount: data['streakCount'] as int? ?? 0,
      activeFrameId: data['activeFrameId'] as String? ?? 'default_frame',
      powerUps: Map<String, int>.from(data['powerUps'] as Map? ?? {}),
      unlockedFrames: List<String>.from(data['unlockedFrames'] as List? ?? ['basic', 'default_frame']),
      stats: data['stats'] != null 
          ? UserStats.fromJson(data['stats'] as Map<String, dynamic>)
          : UserStats.initial(),
    );
  }

  /// Factory for initial user creation
  factory UserProfile.initial({
    required String userId,
    required String deviceId,
  }) {
    // Generate username from last 4 characters of UID
    final String usernameSuffix = userId.length >= 4 
        ? userId.substring(userId.length - 4) 
        : userId;
    
    return UserProfile(
      userId: userId,
      username: 'Player$usernameSuffix',
      avatar: 'https://i.pravatar.cc/150?u=$userId',
      rank: 'Bronze Rank',
      rankIcon: 'military_tech',
      xp: 0,
      xpMax: 500,
      avatarFrame: 'basic',
      activeAvatarFrameId: 'basic',
      activeVictoryTauntId: null,
      coins: 100,
      hintRefills: 0,
      deviceId: deviceId,
      createTime: DateTime.now(),
      totalPoints: 1000,
      gamesPlayed: 0,
      gamesLosed: 0,
      streakCount: 0,
      activeFrameId: 'default_frame',
      powerUps: {
        'mindShieldsCount': 0,
        'hintRefillsCount': 3,
      },
      unlockedFrames: ['basic', 'default_frame'],
      stats: UserStats.initial(),
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
    String avatarFrame = 'basic',
    String activeAvatarFrameId = 'basic',
    String? activeVictoryTauntId,
    int coins = 0,
    String? equippedBubbleSkin,
    String? equippedVictoryTaunt,
    int hintRefills = 2,
    String deviceId = 'mock_device_id',
    DateTime? createTime,
    int totalPoints = 0,
    int gamesPlayed = 5,
    int gamesLosed = 2,
    int streakCount = 3,
    String activeFrameId = 'default_frame',
    Map<String, int>? powerUps,
    List<String>? unlockedFrames,
    UserStats? stats,
  }) {
    return UserProfile(
      userId: userId,
      username: username,
      avatar: avatar,
      rank: rank,
      rankIcon: rankIcon,
      xp: xp,
      xpMax: xpMax,
      avatarFrame: avatarFrame,
      activeAvatarFrameId: activeAvatarFrameId,
      activeVictoryTauntId: activeVictoryTauntId,
      coins: coins,
      equippedBubbleSkin: equippedBubbleSkin,
      equippedVictoryTaunt: equippedVictoryTaunt,
      hintRefills: hintRefills,
      deviceId: deviceId,
      createTime: createTime ?? DateTime.now(),
      totalPoints: totalPoints,
      gamesPlayed: gamesPlayed,
      gamesLosed: gamesLosed,
      streakCount: streakCount,
      activeFrameId: activeFrameId,
      powerUps: powerUps ?? {'mindShieldsCount': 0, 'hintRefillsCount': 3},
      unlockedFrames: unlockedFrames ?? ['basic', 'default_frame'],
      stats: stats ?? UserStats(gamesPlayed: gamesPlayed, gamesWon: gamesPlayed - gamesLosed, currentStreak: streakCount),
    );
  }
}

/// User statistics model
class UserStats {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;

  UserStats({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.currentStreak,
  });

  /// Create a copy with modified fields
  UserStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
  }) {
    return UserStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'currentStreak': currentStreak,
    };
  }

  /// Create from JSON
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
    );
  }

  /// Factory for initial stats
  factory UserStats.initial() {
    return UserStats(
      gamesPlayed: 0,
      gamesWon: 0,
      currentStreak: 0,
    );
  }

  /// Calculate win rate (0.0 to 1.0)
  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return gamesWon / gamesPlayed;
  }

  /// Calculate loss count
  int get gamesLost => gamesPlayed - gamesWon;
}
