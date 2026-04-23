

class AppConstants {
  AppConstants._();

  static const String appName        = 'Plant DD AI';
  static const String appVersion     = '1.0.1';

  static const String modelAssetPath       = 'assets/models/mobilenetv2.tflite';
  static const String modelVersion         = '1.0';
  static const int    modelInputSize       = 224;
  static const int    numDiseaseClasses    = 38;
  static const double confidenceThreshold  = 0.60;

  static const int    maxImageSizeBytes    = 10 * 1024 * 1024;
  static const List<String> allowedImageExtensions = ['.jpg', '.jpeg', '.png'];

  static const int inferenceTimeoutMs = 2000;

  static const String predictionImagesFolder = 'prediction_images';

  static const String databaseName    = 'plant_doctor.db';
  static const int    databaseVersion = 1;

  static const String defaultLanguage            = 'en';
  static const String defaultConfidenceThreshold = '0.60';
  static const String defaultLastSync            = '0';

  static const double highConfidence   = 0.85;
  static const double mediumConfidence = 0.60;

  static const List<String> diseaseClassNames = [
    'Apple___Apple_scab','Apple___Black_rot','Apple___Cedar_apple_rust','Apple___healthy',
    'Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot','Corn_(maize)___Common_rust',
    'Corn_(maize)___Northern_Leaf_Blight','Corn_(maize)___healthy',
    'Grape___Black_rot','Grape___Esca_(Black_Measles)','Grape___Leaf_blight_(Isariopsis_Leaf_Spot)','Grape___healthy',
    'Potato___Early_blight','Potato___Late_blight','Potato___healthy',
    'Tomato___Bacterial_spot','Tomato___Early_blight','Tomato___Late_blight','Tomato___Leaf_Mold',
    'Tomato___Septoria_leaf_spot','Tomato___Spider_mites_Two-spotted_spider_mite',
    'Tomato___Target_Spot','Tomato___Tomato_Yellow_Leaf_Curl_Virus','Tomato___Tomato_mosaic_virus','Tomato___healthy',
    'Pepper,_bell___Bacterial_spot','Pepper,_bell___healthy',
    'Strawberry___Leaf_scorch','Strawberry___healthy',
    'Peach___Bacterial_spot','Peach___healthy',
    'Squash___Powdery_mildew',
    'Cherry_(including_sour)___Powdery_mildew','Cherry_(including_sour)___healthy',
    'Raspberry___healthy','Soybean___healthy','Blueberry___healthy',
    'Orange___Haunglongbing_(Citrus_greening)',
  ];
}
