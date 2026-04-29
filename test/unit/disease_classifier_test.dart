import 'package:flutter_test/flutter_test.dart';
import 'package:plant_dd_ai/ml/disease_classifier.dart';
import 'package:plant_dd_ai/core/constants/app_constants.dart';

void main() {
  group('DiseaseClassifier.getTopPrediction', () {
    late DiseaseClassifier classifier;

    setUp(() {
      classifier = DiseaseClassifier(
        classNames: AppConstants.diseaseClasses,
        confidenceThreshold: AppConstants.confidenceThreshold, // 0.60
      );
    });

    test('returns correct class name for the highest scoring index', () {
      // 38 classes; set index 29 (Tomato___Early_blight) to 0.92
      final scores = List<double>.filled(38, 0.01);
      scores[29] = 0.92;

      final result = classifier.getTopPrediction(scores);

      expect(result.className, equals('Tomato___Early_blight'));
      expect(result.classIndex, equals(29));
      expect(result.confidence, closeTo(0.92, 0.001));
    });

    test('returns "Unknown" when max confidence is below threshold (0.60)', () {
      final scores = List<double>.filled(38, 0.01);
      scores[0] = 0.45; // below 0.60 threshold

      final result = classifier.getTopPrediction(scores);

      expect(result.className, equals('Unknown'));
    });

    test('returns class name when confidence is exactly at threshold (0.60)', () {
      final scores = List<double>.filled(38, 0.01);
      scores[3] = 0.60; // Apple___healthy, exactly at threshold

      final result = classifier.getTopPrediction(scores);

      // 0.60 is NOT less than 0.60, so it should pass
      expect(result.className, equals('Apple___healthy'));
      expect(result.confidence, closeTo(0.60, 0.001));
    });

    test('isHighConfidence is true for confidence >= 0.85', () {
      final scores = List<double>.filled(38, 0.0);
      scores[30] = 0.91; // Tomato___healthy

      final result = classifier.getTopPrediction(scores);

      expect(result.isHighConfidence, isTrue);
      expect(result.isMediumConfidence, isFalse);
    });

    test('isMediumConfidence is true for confidence between 0.60 and 0.85', () {
      final scores = List<double>.filled(38, 0.0);
      scores[20] = 0.74; // Potato___Early_blight

      final result = classifier.getTopPrediction(scores);

      expect(result.isMediumConfidence, isTrue);
      expect(result.isHighConfidence, isFalse);
      expect(result.isLowConfidence, isFalse);
    });

    test('returns "Unknown" and does not crash on all-zero scores', () {
      final scores = List<double>.filled(38, 0.0);

      final result = classifier.getTopPrediction(scores);

      expect(result.className, equals('Unknown'));
    });

    test('returns "Unknown" label when classIndex exceeds classNames length', () {
      // Create classifier with only 2 names but feed 38 scores
      final narrowClassifier = DiseaseClassifier(
        classNames: ['ClassA', 'ClassB'],
        confidenceThreshold: 0.60,
      );
      final scores = List<double>.filled(38, 0.0);
      scores[10] = 0.95; // index 10 is out of bounds for 2-class list

      final result = narrowClassifier.getTopPrediction(scores);

      expect(result.className, equals('Unknown'));
    });

    test('correctly picks highest score when multiple classes score above 0.60', () {
      final scores = List<double>.filled(38, 0.0);
      scores[5] = 0.65;
      scores[11] = 0.88; // Grape___Black_rot — should win
      scores[20] = 0.72;

      final result = classifier.getTopPrediction(scores);

      expect(result.className, equals('Grape___Black_rot'));
      expect(result.classIndex, equals(11));
    });
  });
}
