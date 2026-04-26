import 'package:uuid/uuid.dart';
import '../../core/utils/date_time_utils.dart';


class Prediction {
  final String id;
  final String diseaseId; // FK to disease_info
  final String diseaseName;
  final double confidence; // 0.0-1.0
  final int timestamp;
  final String imagePath;
  final String modelVersion;
  final String? deviceId;

  Prediction({
    String? id,
    required this.diseaseId,
    required this.diseaseName,
    required this.confidence,
    int? timestamp,
    required this.imagePath,
    required this.modelVersion,
    this.deviceId,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTimeUtils.getCurrentTimestamp();

  String getFormattedDate() {
    return DateTimeUtils.formatDate(
      DateTimeUtils.fromUnixTimestamp(timestamp),
    );
  }

  String getFormattedDateTime() {
    return DateTimeUtils.formatDateTime(
      DateTimeUtils.fromUnixTimestamp(timestamp),
    );
  }

  String getConfidencePercentage() {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  /// Check if confidence is high (>= 85%)
  bool isHighConfidence() {
    return confidence >= 0.85;
  }

  /// Check if confidence is medium (60-85%)
  bool isMediumConfidence() {
    return confidence >= 0.60 && confidence < 0.85;
  }

  bool isLowConfidence() {
    return confidence < 0.60;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'disease_id': diseaseId,
      'disease_name': diseaseName,
      'confidence': confidence,
      'timestamp': timestamp,
      'image_path': imagePath,
      'model_version': modelVersion,
      'device_id': deviceId,
      'created_at': DateTimeUtils.getCurrentTimestamp(),
    };
  }

  factory Prediction.fromMap(Map<String, dynamic> map) {

    String diseaseName = map['disease_name'] as String? ?? '';
    if (diseaseName.isEmpty) {
      diseaseName = 'Unknown Disease';
    }

    return Prediction(
      id: map['id'] as String,
      diseaseId: map['disease_id'] as String,
      diseaseName: diseaseName,
      confidence: map['confidence'] as double,
      timestamp: map['timestamp'] as int,
      imagePath: map['image_path'] as String,
      modelVersion: map['model_version'] as String,
      deviceId: map['device_id'] as String?,
    );
  }

  Prediction copyWith({
    String? id,
    String? diseaseId,
    String? diseaseName,
    double? confidence,
    int? timestamp,
    String? imagePath,
    String? modelVersion,
    String? deviceId,
  }) {
    return Prediction(
      id: id ?? this.id,
      diseaseId: diseaseId ?? this.diseaseId,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      modelVersion: modelVersion ?? this.modelVersion,
      deviceId: deviceId ?? this.deviceId,
    );
  }



  @override
  String toString() {
    return 'Prediction(id: $id, disease: $diseaseName, confidence: ${getConfidencePercentage()})';
  }
}