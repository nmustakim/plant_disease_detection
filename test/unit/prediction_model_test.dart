import 'package:flutter_test/flutter_test.dart';
import 'package:plant_dd_ai/data/models/prediction.dart';

void main() {
  group('Prediction model', () {
    late Prediction prediction;

    setUp(() {
      prediction = Prediction(
        diseaseId: 'tomato_early_blight',
        diseaseName: 'Tomato Early Blight',
        confidence: 0.87,
        imagePath: '/storage/images/leaf.jpg',
        modelVersion: '1.0.0',
      );
    });

    test('auto-generates a non-empty UUID id when none is provided', () {
      expect(prediction.id, isNotEmpty);
      expect(prediction.id.length, equals(36)); // UUID v4 format
    });

    test('auto-assigns a non-zero timestamp when none is provided', () {
      expect(prediction.timestamp, greaterThan(0));
    });

    test('getConfidencePercentage returns correct formatted string', () {
      expect(prediction.getConfidencePercentage(), equals('87.0%'));
    });

    test('isHighConfidence returns true when confidence >= 0.85', () {
      expect(prediction.isHighConfidence(), isTrue);
    });

    test('isMediumConfidence returns true when confidence is 0.60–0.84', () {
      final medium = prediction.copyWith(confidence: 0.72);
      expect(medium.isMediumConfidence(), isTrue);
      expect(medium.isHighConfidence(), isFalse);
    });

    test('isLowConfidence returns true when confidence < 0.60', () {
      final low = prediction.copyWith(confidence: 0.45);
      expect(low.isLowConfidence(), isTrue);
    });

    test('toMap produces all required keys', () {
      final map = prediction.toMap();
      expect(map.containsKey('id'), isTrue);
      expect(map.containsKey('disease_id'), isTrue);
      expect(map.containsKey('disease_name'), isTrue);
      expect(map.containsKey('confidence'), isTrue);
      expect(map.containsKey('timestamp'), isTrue);
      expect(map.containsKey('image_path'), isTrue);
      expect(map.containsKey('model_version'), isTrue);
    });

    test('fromMap reconstructs equivalent object', () {
      final map = prediction.toMap();
      final restored = Prediction.fromMap(map);
      expect(restored.id, equals(prediction.id));
      expect(restored.diseaseId, equals(prediction.diseaseId));
      expect(restored.diseaseName, equals(prediction.diseaseName));
      expect(restored.confidence, equals(prediction.confidence));
      expect(restored.imagePath, equals(prediction.imagePath));
      expect(restored.modelVersion, equals(prediction.modelVersion));
    });

    test('fromMap falls back to "Unknown Disease" when disease_name is empty', () {
      final map = prediction.toMap();
      map['disease_name'] = '';
      final restored = Prediction.fromMap(map);
      expect(restored.diseaseName, equals('Unknown Disease'));
    });

    test('copyWith overrides only specified fields', () {
      final updated = prediction.copyWith(confidence: 0.55, diseaseName: 'Unknown');
      expect(updated.confidence, equals(0.55));
      expect(updated.diseaseName, equals('Unknown'));
      expect(updated.diseaseId, equals(prediction.diseaseId)); // unchanged
      expect(updated.imagePath, equals(prediction.imagePath)); // unchanged
    });

    test('two Predictions with different ids are not equal by id', () {
      final other = Prediction(
        diseaseId: prediction.diseaseId,
        diseaseName: prediction.diseaseName,
        confidence: prediction.confidence,
        imagePath: prediction.imagePath,
        modelVersion: prediction.modelVersion,
      );
      expect(prediction.id, isNot(equals(other.id)));
    });
  });
}
