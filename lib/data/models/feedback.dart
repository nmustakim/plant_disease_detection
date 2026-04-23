enum FeedbackType { correct, incorrect, unsure }

class FeedbackModel {
  final int? feedbackId;
  final String predictionId;
  final FeedbackType userFeedback;
  final String? correctDiseaseName;
  final String? comments;
  final DateTime timestamp;

  const FeedbackModel({
    this.feedbackId,
    required this.predictionId,
    required this.userFeedback,
    this.correctDiseaseName,
    this.comments,
    required this.timestamp,
  });

  bool isUserCorrection() =>
      userFeedback == FeedbackType.incorrect && correctDiseaseName != null;

  Map<String, dynamic> toMap() => {
    if (feedbackId != null) 'feedback_id': feedbackId,
    'prediction_id': predictionId,
    'user_feedback':
        userFeedback.name[0].toUpperCase() + userFeedback.name.substring(1),
    'correct_disease_name': correctDiseaseName,
    'comments': comments,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory FeedbackModel.fromMap(Map<String, dynamic> map) => FeedbackModel(
    feedbackId: map['feedback_id'] as int?,
    predictionId: map['prediction_id'] as String,
    userFeedback: FeedbackType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() ==
          (map['user_feedback'] as String).toLowerCase(),
      orElse: () => FeedbackType.unsure,
    ),
    correctDiseaseName: map['correct_disease_name'] as String?,
    comments: map['comments'] as String?,
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
  );
}
