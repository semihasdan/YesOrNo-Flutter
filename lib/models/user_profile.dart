/// User profile model representing a player's account information
class UserProfile {
  final String userId;
  final String username;
  final String avatar;
  final String rank;
  final String rankIcon;
  final int xp;
  final int xpMax;
  final String avatarFrame; // Equipped avatar frame style
  final int coins; // User's coin balance
  final String? equippedBubbleSkin; // Equipped question bubble skin
  final String? equippedVictoryTaunt; // Equipped victory taunt/emote
  final int hintRefills; // Number of hint refills owned
  
  // Device tracking and session management
  final String deviceId; // Device unique identifier
  final DateTime createTime; // Account creation timestamp
  final int totalPoints; // Total points earned
  final int gamesPlayed; // Total games played
  final String activeFrameId; // Currently active frame
  final Map<String, int> powerUps; // Power-ups inventory

  UserProfile({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.rank,
    required this.rankIcon,
    required this.xp,
    required this.xpMax,
    this.avatarFrame = 'basic',
    this.coins = 0,
    this.equippedBubbleSkin,
    this.equippedVictoryTaunt,
    this.hintRefills = 0,
    required this.deviceId,
    required this.createTime,
    this.totalPoints = 1000,
    this.gamesPlayed = 0,
    this.activeFrameId = 'default_frame',
    Map<String, int>? powerUps,
  }) : powerUps = powerUps ?? {'mindShieldsCount': 0, 'hintRefillsCount': 3};

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
    int? coins,
    String? equippedBubbleSkin,
    String? equippedVictoryTaunt,
    int? hintRefills,
    String? deviceId,
    DateTime? createTime,
    int? totalPoints,
    int? gamesPlayed,
    String? activeFrameId,
    Map<String, int>? powerUps,
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
      coins: coins ?? this.coins,
      equippedBubbleSkin: equippedBubbleSkin ?? this.equippedBubbleSkin,
      equippedVictoryTaunt: equippedVictoryTaunt ?? this.equippedVictoryTaunt,
      hintRefills: hintRefills ?? this.hintRefills,
      deviceId: deviceId ?? this.deviceId,
      createTime: createTime ?? this.createTime,
      totalPoints: totalPoints ?? this.totalPoints,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      activeFrameId: activeFrameId ?? this.activeFrameId,
      powerUps: powerUps ?? this.powerUps,
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
      'coins': coins,
      'equippedBubbleSkin': equippedBubbleSkin,
      'equippedVictoryTaunt': equippedVictoryTaunt,
      'hintRefills': hintRefills,
      'deviceId': deviceId,
      'createTime': createTime.toIso8601String(),
      'totalPoints': totalPoints,
      'gamesPlayed': gamesPlayed,
      'activeFrameId': activeFrameId,
      'powerUps': powerUps,
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
      'coins': coins,
      'equippedBubbleSkin': equippedBubbleSkin,
      'equippedVictoryTaunt': equippedVictoryTaunt,
      'hintRefills': hintRefills,
      'deviceId': deviceId,
      'createTime': createTime.toIso8601String(),
      'totalPoints': totalPoints,
      'gamesPlayed': gamesPlayed,
      'activeFrameId': activeFrameId,
      'powerUps': powerUps,
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
      coins: json['coins'] as int? ?? 0,
      equippedBubbleSkin: json['equippedBubbleSkin'] as String?,
      equippedVictoryTaunt: json['equippedVictoryTaunt'] as String?,
      hintRefills: json['hintRefills'] as int? ?? 0,
      deviceId: json['deviceId'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      totalPoints: json['totalPoints'] as int? ?? 1000,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      activeFrameId: json['activeFrameId'] as String? ?? 'default_frame',
      powerUps: Map<String, int>.from(json['powerUps'] as Map? ?? {}),
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
      coins: data['coins'] as int? ?? 0,
      equippedBubbleSkin: data['equippedBubbleSkin'] as String?,
      equippedVictoryTaunt: data['equippedVictoryTaunt'] as String?,
      hintRefills: data['hintRefills'] as int? ?? 0,
      deviceId: data['deviceId'] as String,
      createTime: DateTime.parse(data['createTime'] as String),
      totalPoints: data['totalPoints'] as int? ?? 1000,
      gamesPlayed: data['gamesPlayed'] as int? ?? 0,
      activeFrameId: data['activeFrameId'] as String? ?? 'default_frame',
      powerUps: Map<String, int>.from(data['powerUps'] as Map? ?? {}),
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
      coins: 100,
      hintRefills: 0,
      deviceId: deviceId,
      createTime: DateTime.now(),
      totalPoints: 1000,
      gamesPlayed: 0,
      activeFrameId: 'default_frame',
      powerUps: {
        'mindShieldsCount': 0,
        'hintRefillsCount': 3,
      },
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
    int coins = 1500,
    String? equippedBubbleSkin,
    String? equippedVictoryTaunt,
    int hintRefills = 2,
    String deviceId = 'mock_device_id',
    DateTime? createTime,
    int totalPoints = 1000,
    int gamesPlayed = 5,
    String activeFrameId = 'default_frame',
    Map<String, int>? powerUps,
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
      coins: coins,
      equippedBubbleSkin: equippedBubbleSkin,
      equippedVictoryTaunt: equippedVictoryTaunt,
      hintRefills: hintRefills,
      deviceId: deviceId,
      createTime: createTime ?? DateTime.now(),
      totalPoints: totalPoints,
      gamesPlayed: gamesPlayed,
      activeFrameId: activeFrameId,
      powerUps: powerUps ?? {'mindShieldsCount': 0, 'hintRefillsCount': 3},
    );
  }
}
