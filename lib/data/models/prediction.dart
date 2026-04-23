
import 'package:intl/intl.dart';

class Prediction {
  Prediction({
    required this.id,
    required this.diseaseId,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
    required this.imagePath,
    this.modelVersion = '1.0',
    this.deviceId,
  });

  final String id;
  final String diseaseId;
  final String diseaseName;
  final double confidence;
  final DateTime timestamp;
  final String imagePath;
  final String modelVersion;
  final String? deviceId;

  String getFormattedDate() =>
      DateFormat('MMM dd, yyyy · hh:mm a').format(timestamp);

  int getConfidencePercentage() => (confidence * 100).round();

  bool isHighConfidence() => confidence >= 0.85;

  bool get isUnknown => diseaseName == 'Unknown';

  Map<String, dynamic> toMap() => {
    'id': id, 'disease_id': diseaseId, 'confidence': confidence,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'image_path': imagePath, 'model_version': modelVersion,
    if (deviceId != null) 'device_id': deviceId,
    'created_at': DateTime.now().millisecondsSinceEpoch,
  };

  factory Prediction.fromMap(Map<String, dynamic> map) => Prediction(
    id: map['id'] as String,
    diseaseId: map['disease_id'] as String,
    diseaseName: map['disease_name'] as String? ?? map['disease_id'] as String,
    confidence: (map['confidence'] as num).toDouble(),
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    imagePath: map['image_path'] as String,
    modelVersion: map['model_version'] as String? ?? '1.0',
    deviceId: map['device_id'] as String?,
  );
}
