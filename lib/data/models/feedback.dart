enum UserFeedback {
  correct,
  incorrect,
  unsure;

  String get displayName {
    switch (this) {
      case UserFeedback.correct:
        return 'Correct';
      case UserFeedback.incorrect:
        return 'Incorrect';
      case UserFeedback.unsure:
        return 'Unsure';
    }
  }

  static UserFeedback fromString(String value) {
    switch (value.toLowerCase()) {
      case 'correct':
        return UserFeedback.correct;
      case 'incorrect':
        return UserFeedback.incorrect;
      case 'unsure':
        return UserFeedback.unsure;
      default:
        return UserFeedback.unsure;
    }
  }
}


class Feedback {
  final int? feedbackId;
  final String predictionId;
  final UserFeedback userFeedback;
  final String? correctDiseaseName;
  final String? comments;
  final int timestamp;

  Feedback({
    this.feedbackId,
    required this.predictionId,
    required this.userFeedback,
    this.correctDiseaseName,
    this.comments,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  bool isUserCorrection() {
    return userFeedback == UserFeedback.incorrect &&
        correctDiseaseName != null &&
        correctDiseaseName!.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'feedback_id': feedbackId,
      'prediction_id': predictionId,
      'user_feedback': userFeedback.displayName,
      'correct_disease_name': correctDiseaseName,
      'comments': comments,
      'timestamp': timestamp,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      feedbackId: map['feedback_id'] as int?,
      predictionId: map['prediction_id'] as String,
      userFeedback: UserFeedback.fromString(map['user_feedback'] as String),
      correctDiseaseName: map['correct_disease_name'] as String?,
      comments: map['comments'] as String?,
      timestamp: map['timestamp'] as int,
    );
  }

  @override
  String toString() {
    return 'Feedback(predictionId: $predictionId, feedback: ${userFeedback.displayName})';
  }
}