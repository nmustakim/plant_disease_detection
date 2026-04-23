import '../models/prediction.dart';
import '../models/disease_info.dart';
import 'daos/disease_info_dao.dart';
import 'daos/error_logs_dao.dart';
import 'daos/feedback_dao.dart';
import 'daos/predictions_dao.dart';
import 'daos/reference_links_dao.dart';



class DatabaseManager {
  final PredictionsDao predictionsDAO;
  final DiseaseInfoDao diseaseInfoDAO;
  final ReferenceLinksDao referenceLinksDAO;
  final ErrorLogsDao errorLogsDao;
  final FeedbackDao feedbackDao;

  DatabaseManager({
    PredictionsDao? predictionsDao,
    DiseaseInfoDao? diseaseInfoDao,
    ReferenceLinksDao? referenceLinksDao,
    ErrorLogsDao? errorLogsDao,
    FeedbackDao? feedbackDao,
  })  : predictionsDAO = predictionsDao ?? PredictionsDao(),
        diseaseInfoDAO = diseaseInfoDao ?? DiseaseInfoDao(),
        referenceLinksDAO = referenceLinksDao ?? ReferenceLinksDao(),
        errorLogsDao = errorLogsDao ?? ErrorLogsDao(),
        feedbackDao = feedbackDao ?? FeedbackDao();

  Future<String> savePrediction(Prediction prediction) async {
    return await predictionsDAO.insert(prediction);
  }

  Future<List<Prediction>> getAllPredictions() async {
    return await predictionsDAO.getAll();
  }

  Future<Prediction?> getPredictionById(String id) async {
    return await predictionsDAO.getById(id);
  }

  Future<bool> deletePrediction(String id) async {
    return await predictionsDAO.delete(id);
  }

  Future<bool> deleteAllPredictions() async {
    final count = await predictionsDAO.deleteAll();
    return count > 0;
  }

  Future<DiseaseInfo?> getDiseaseInfo(String diseaseName) async {
    return await diseaseInfoDAO.getByName(diseaseName);
  }

  Future<DiseaseInfo?> getDiseaseInfoById(String diseaseId) async {
    return await diseaseInfoDAO.getById(diseaseId);
  }
}