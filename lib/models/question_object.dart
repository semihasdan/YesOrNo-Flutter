/// Answer enum for yes/no responses
enum QuestionAnswer {
  yes,
  no,
  pending,
}

/// Question object representing a player's question and its answer
class QuestionObject {
  final String questionId;
  final String playerId;
  final String text;
  final QuestionAnswer answer;
  final int roundNumber;

  QuestionObject({
    required this.questionId,
    required this.playerId,
    required this.text,
    required this.answer,
    required this.roundNumber,
  });

  /// Create a copy with modified fields
  QuestionObject copyWith({
    String? questionId,
    String? playerId,
    String? text,
    QuestionAnswer? answer,
    int? roundNumber,
  }) {
    return QuestionObject(
      questionId: questionId ?? this.questionId,
      playerId: playerId ?? this.playerId,
      text: text ?? this.text,
      answer: answer ?? this.answer,
      roundNumber: roundNumber ?? this.roundNumber,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'playerId': playerId,
      'text': text,
      'answer': answer.name,
      'roundNumber': roundNumber,
    };
  }

  /// Create from JSON
  factory QuestionObject.fromJson(Map<String, dynamic> json) {
    return QuestionObject(
      questionId: json['questionId'] as String,
      playerId: json['playerId'] as String,
      text: json['text'] as String,
      answer: QuestionAnswer.values.firstWhere(
        (e) => e.name == json['answer'],
        orElse: () => QuestionAnswer.pending,
      ),
      roundNumber: json['roundNumber'] as int,
    );
  }
}
