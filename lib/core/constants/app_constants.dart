
class AppConstants {
  static const String appName = 'Plant Disease Detector';
  static const String appVersion = '1.0.0';

  static const String modelFileName = 'plant_disease_model.tflite';
  static const String modelAssetPath = 'assets/models/$modelFileName';
  static const int modelInputSize = 380;
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
    'Apple___Apple_scab',
    'Apple___Black_rot',
    'Apple___Cedar_apple_rust',
    'Apple___healthy',
    'Blueberry___healthy',
    'Cherry_(including_sour)___Powdery_mildew',
    'Cherry_(including_sour)___healthy',
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
    'Corn_(maize)___Common_rust',
    'Corn_(maize)___Northern_Leaf_Blight',
    'Corn_(maize)___healthy',
    'Grape___Black_rot',
    'Grape___Esca_(Black_Measles)',
    'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    'Grape___healthy',
    'Orange___Haunglongbing_(Citrus_greening)',
    'Peach___Bacterial_spot',
    'Peach___healthy',
    'Pepper,_bell___Bacterial_spot',
    'Pepper,_bell___healthy',
    'Potato___Early_blight',
    'Potato___Late_blight',
    'Potato___healthy',
    'Raspberry___healthy',
    'Soybean___healthy',
    'Squash___Powdery_mildew',
    'Strawberry___Leaf_scorch',
    'Strawberry___healthy',
    'Tomato___Bacterial_spot',
    'Tomato___Early_blight',
    'Tomato___Late_blight',
    'Tomato___Leaf_Mold',
    'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_mites Two-spotted_spider_mite',
    'Tomato___Target_Spot',
    'Tomato___Tomato_mosaic_virus',
    'Tomato___healthy',
  ];

}