

import 'package:flutter/foundation.dart';
import '../data/database/database_manager.dart';
import '../data/database/daos/feedback_dao.dart';
import '../data/models/feedback.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackDao _dao;
  bool isSubmitting = false;

  FeedbackProvider(DatabaseManager db) : _dao = FeedbackDao(db);

  Future<bool> submitFeedback(FeedbackModel feedback) async {
    isSubmitting = true;
    notifyListeners();
    try {
      await _dao.insert(feedback);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> getAccuracyMetrics() =>
      _dao.getAccuracyMetrics();
}
