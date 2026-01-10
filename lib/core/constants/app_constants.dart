
class AppConstants {
  static const String appName = 'Plant Disease Detector';
  static const String appVersion = '1.0.0';

  static const String modelFileName = 'plant_disease_model.tflite';
  static const String modelAssetPath = 'assets/models/$modelFileName';
  static const int modelInputSize = 224;
  static const int modelChannels = 3; 
  static const double confidenceThreshold = 0.60;

  static const int maxImageSizeMB = 10;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];

  static const int maxInferenceTimeSeconds = 3;
  static const int maxInferenceTimeMillis = maxInferenceTimeSeconds * 1000;

  static const String databaseName = 'plant_disease.db';
  static const int databaseVersion = 1;

  static const double highConfidenceThreshold = 0.85;
  static const double mediumConfidenceThreshold = 0.60;

  static const String firebaseModelsCollection = 'models';
  static const String firebaseFeedbackCollection = 'user_feedback';
  static const String firebaseDiseaseInfoCollection = 'disease_info';
  static const String firebaseStorageModelsPath = 'models';

  static const String predictionImagesFolder = 'prediction_images';
  static const String modelCacheFolder = 'model_cache';

  static const int firestoreTimeoutSeconds = 30;
  static const int storageDownloadTimeoutSeconds = 60;
  static const int maxRetryAttempts = 3;

  static const String languageEnglish = 'en';
  static const String languageBengali = 'bn';
  static const List<String> supportedLanguages = [languageEnglish, languageBengali];

  static const String settingsLanguage = 'language';
  static const String settingsModelVersion = 'model_version';
  static const String settingsLastSync = 'last_sync';
  static const String settingsConfidenceThreshold = 'confidence_threshold';

  static const List<String> diseaseClasses = [
    'Healthy',
    'Early Blight',
    'Late Blight',
    'Leaf Mold',
    'Septoria Leaf Spot',
    'Spider Mites',
    'Target Spot',
    'Yellow Leaf Curl Virus',
    'Mosaic Virus',
    'Bacterial Spot',
  ];
}