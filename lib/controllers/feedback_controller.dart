import '../data/database/daos/feedback_dao.dart';
import '../data/models/feedback.dart';
import '../core/errors/error_handler.dart';
import '../core/constants/error_codes.dart';
import '../core/utils/logger.dart';

class FeedbackController {
  final FeedbackDao _feedbackDao;
  final ErrorHandler _errorHandler;

  FeedbackController({
    required FeedbackDao feedbackDao,
    required ErrorHandler errorHandler,
  })  : _feedbackDao = feedbackDao,
        _errorHandler = errorHandler;

  Future<FeedbackResult> submitFeedback({
    required String predictionId,
    required UserFeedback userFeedback,
    String? correctDiseaseName,
    String? comments,
  }) async {
    try {
      AppLogger.info(
        'Submitting feedback for prediction: $predictionId',
        'FeedbackController',
      );

      final feedback = Feedback(
        predictionId: predictionId,
        userFeedback: userFeedback,
        correctDiseaseName: correctDiseaseName,
        comments: comments,
      );

      final id = await _feedbackDao.submitFeedback(feedback);

      AppLogger.info('Feedback submitted with id: $id', 'FeedbackController');
      return FeedbackResult(success: true, feedbackId: id);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit feedback', 'FeedbackController', e, stackTrace);
      await _errorHandler.handleError(
        ErrorCodes.dbInsertFailed,
        userAction: 'submitFeedback',
        originalError: e,
        stackTrace: stackTrace,
      );
      return FeedbackResult(
        success: false,
        errorMessage: 'Failed to save feedback. Please try again.',
      );
    }
  }

  Future<AccuracyStats?> getAccuracyMetrics(String diseaseName) async {
    try {
      return await _feedbackDao.getAccuracyMetrics(diseaseName);
    } catch (e) {
      AppLogger.error('Failed to get accuracy metrics', 'FeedbackController', e);
      return null;
    }
  }

  Future<Feedback?> getFeedbackForPrediction(String predictionId) async {
    try {
      return await _feedbackDao.getFeedbackByPredictionId(predictionId);
    } catch (e) {
      AppLogger.error('Failed to get feedback', 'FeedbackController', e);
      return null;
    }
  }
}

class FeedbackResult {
  final bool success;
  final int? feedbackId;
  final String? errorMessage;

  FeedbackResult({
    required this.success,
    this.feedbackId,
    this.errorMessage,
  });
}