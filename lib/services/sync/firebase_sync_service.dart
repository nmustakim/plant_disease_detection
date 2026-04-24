import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/feedback.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';

class FirebaseSyncService {
  static FirebaseSyncService? _instance;
  static FirebaseSyncService get instance {
    _instance ??= FirebaseSyncService._();
    return _instance!;
  }

  FirebaseSyncService._();

  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _isInitialized = true;
      AppLogger.info('Firebase initialized successfully', 'FirebaseSync');
    } catch (e) {
      AppLogger.warning('Firebase initialization failed: $e', 'FirebaseSync');
      _isInitialized = false;
    }
  }

  bool get isAvailable => _isInitialized;

  Future<bool> syncFeedback(Feedback feedback) async {
    if (!_isInitialized) return false;

    try {
      await _firestore!.collection('user_feedback').add({
        'prediction_id': feedback.predictionId,
        'user_feedback': feedback.userFeedback.displayName,
        'correct_disease_name': feedback.correctDiseaseName,
        'comments': feedback.comments,
        'timestamp': FieldValue.serverTimestamp(),
        'app_version': AppConstants.appVersion,
        'sync_status': 'synced',
      });

      AppLogger.info('Feedback synced: ${feedback.predictionId}', 'FirebaseSync');
      return true;
    } catch (e) {
      AppLogger.error('Failed to sync feedback', 'FirebaseSync', e);
      return false;
    }
  }

  Future<void> syncPendingFeedback(List<Feedback> pendingFeedback) async {
    if (!_isInitialized) return;

    for (final feedback in pendingFeedback) {
      await syncFeedback(feedback);
    }
  }

  Future<Map<String, dynamic>?> checkForModelUpdate() async {
    if (!_isInitialized) return null;

    try {
      final doc = await _firestore!
          .collection('models')
          .doc('current_model')
          .get();

      if (doc.exists) {
        return {
          'version': doc.data()?['version'],
          'download_url': doc.data()?['download_url'],
          'size_mb': doc.data()?['size_mb'],
          'release_date': doc.data()?['release_date'],
        };
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to check model update', 'FirebaseSync', e);
      return null;
    }
  }

  Future<String?> downloadModel(String downloadUrl, String version) async {
    if (!_isInitialized) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final ref = _storage!.refFromURL(downloadUrl);

      final tempDir = Directory.systemTemp;
      final localPath = '${tempDir.path}/model_v$version.tflite';

      await ref.writeToFile(File(localPath));

      await prefs.setString('model_version', version);

      AppLogger.info('Model downloaded: v$version', 'FirebaseSync');
      return localPath;
    } catch (e) {
      AppLogger.error('Failed to download model', 'FirebaseSync', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getDiseaseInfoUpdates() async {
    if (!_isInitialized) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt('disease_info_sync') ?? 0;

      final query = _firestore!
          .collection('disease_info')
          .where('updated_at', isGreaterThan: lastSync);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        await prefs.setInt('disease_info_sync', DateTime.now().millisecondsSinceEpoch);
        return snapshot.docs.map((doc) => doc.data()).toList();
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to get disease info updates', 'FirebaseSync', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAggregatedStats(String diseaseName) async {
    if (!_isInitialized) return null;

    try {
      final query = await _firestore!
          .collection('accuracy_metrics')
          .doc(diseaseName)
          .get();

      if (query.exists) {
        return query.data();
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get aggregated stats', 'FirebaseSync', e);
      return null;
    }
  }

  Future<void> submitUsageData(Map<String, dynamic> data) async {
    if (!_isInitialized) return;

    try {
      await _firestore!.collection('usage_analytics').add({
        ...data,
        'timestamp': FieldValue.serverTimestamp(),
        'app_version': AppConstants.appVersion,
      });
    } catch (e) {
      AppLogger.error('Failed to submit usage data', 'FirebaseSync', e);
    }
  }
}