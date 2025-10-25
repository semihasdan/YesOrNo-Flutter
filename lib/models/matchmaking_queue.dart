import 'package:cloud_firestore/cloud_firestore.dart';

/// Matchmaking queue entry model
/// Represents a player waiting for an opponent in the matchmaking queue
class MatchmakingQueue {
  final String docId;
  final String userId;
  final int elo;
  final DateTime joinTime;

  MatchmakingQueue({
    required this.docId,
    required this.userId,
    required this.elo,
    required this.joinTime,
  });

  /// Create a copy with modified fields
  MatchmakingQueue copyWith({
    String? docId,
    String? userId,
    int? elo,
    DateTime? joinTime,
  }) {
    return MatchmakingQueue(
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      elo: elo ?? this.elo,
      joinTime: joinTime ?? this.joinTime,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'elo': elo,
      'joinTime': Timestamp.fromDate(joinTime),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'elo': elo,
      'joinTime': Timestamp.fromDate(joinTime),
    };
  }

  /// Create from Firestore document
  factory MatchmakingQueue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchmakingQueue(
      docId: doc.id,
      userId: data['userId'] as String,
      elo: data['elo'] as int? ?? 1200,
      joinTime: (data['joinTime'] as Timestamp).toDate(),
    );
  }

  /// Create from JSON
  factory MatchmakingQueue.fromJson(Map<String, dynamic> json, String docId) {
    return MatchmakingQueue(
      docId: docId,
      userId: json['userId'] as String,
      elo: json['elo'] as int? ?? 1200,
      joinTime: json['joinTime'] is Timestamp
          ? (json['joinTime'] as Timestamp).toDate()
          : DateTime.parse(json['joinTime'] as String),
    );
  }

  /// Factory for creating a new queue entry
  factory MatchmakingQueue.create({
    required String userId,
    int elo = 1200,
  }) {
    return MatchmakingQueue(
      docId: '', // Will be set by Firestore
      userId: userId,
      elo: elo,
      joinTime: DateTime.now(),
    );
  }
}
