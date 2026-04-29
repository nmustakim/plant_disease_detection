import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:plant_dd_ai/controllers/history_controller.dart';
import 'package:plant_dd_ai/data/database/database_manager.dart';
import 'package:plant_dd_ai/data/models/prediction.dart';

// Run: dart run build_runner build
// to generate history_controller_test.mocks.dart
@GenerateNiceMocks([MockSpec<DatabaseManager>()])
import 'history_controller_test.mocks.dart';

void main() {
  late MockDatabaseManager mockDb;
  late HistoryController controller;

  // Helper to create a minimal Prediction
  Prediction makePrediction({
    String? id,
    String diseaseName = 'Tomato Early Blight',
    double confidence = 0.87,
  }) {
    return Prediction(
      id: id,
      diseaseId: 'tomato_early_blight',
      diseaseName: diseaseName,
      confidence: confidence,
      imagePath: '/images/leaf.jpg',
      modelVersion: '1.0.0',
    );
  }

  setUp(() {
    mockDb = MockDatabaseManager();
    controller = HistoryController(database: mockDb);
  });

  group('HistoryController.getAllPredictions', () {
    test('returns list from DatabaseManager', () async {
      final fakeList = [
        makePrediction(diseaseName: 'Tomato Early Blight'),
        makePrediction(diseaseName: 'Apple Scab'),
      ];

      when(mockDb.getAllPredictions()).thenAnswer((_) async => fakeList);

      final result = await controller.getAllPredictions();

      expect(result.length, equals(2));
      expect(result.first.diseaseName, equals('Tomato Early Blight'));
      verify(mockDb.getAllPredictions()).called(1);
    });

    test('returns empty list when database has no records', () async {
      when(mockDb.getAllPredictions()).thenAnswer((_) async => []);

      final result = await controller.getAllPredictions();

      expect(result, isEmpty);
    });

    test('rethrows exception on database failure', () async {
      when(mockDb.getAllPredictions()).thenThrow(Exception('DB error'));

      expect(() => controller.getAllPredictions(), throwsException);
    });
  });

  group('HistoryController.deletePrediction', () {
    test('returns true when deletion succeeds', () async {
      const targetId = 'abc-123';
      when(mockDb.deletePrediction(targetId)).thenAnswer((_) async => true);

      final result = await controller.deletePrediction(targetId);

      expect(result, isTrue);
      verify(mockDb.deletePrediction(targetId)).called(1);
    });

    test('returns false when record does not exist', () async {
      when(mockDb.deletePrediction(any)).thenAnswer((_) async => false);

      final result = await controller.deletePrediction('nonexistent-id');

      expect(result, isFalse);
    });

    test('returns false (does not rethrow) on database error', () async {
      when(mockDb.deletePrediction(any)).thenThrow(Exception('DB error'));

      final result = await controller.deletePrediction('bad-id');

      expect(result, isFalse);
    });
  });

  group('HistoryController.deleteAllPredictions', () {
    test('returns true when records were deleted', () async {
      when(mockDb.deleteAllPredictions()).thenAnswer((_) async => true);

      final result = await controller.deleteAllPredictions();

      expect(result, isTrue);
      verify(mockDb.deleteAllPredictions()).called(1);
    });

    test('returns false when table is already empty', () async {
      when(mockDb.deleteAllPredictions()).thenAnswer((_) async => false);

      final result = await controller.deleteAllPredictions();

      expect(result, isFalse);
    });
  });

  group('HistoryController.getPredictionById', () {
    test('returns matching prediction when found', () async {
      final p = makePrediction(id: 'id-xyz');
      when(mockDb.getPredictionById('id-xyz')).thenAnswer((_) async => p);

      final result = await controller.getPredictionById('id-xyz');

      expect(result, isNotNull);
      expect(result!.id, equals('id-xyz'));
    });

    test('returns null when prediction not found', () async {
      when(mockDb.getPredictionById(any)).thenAnswer((_) async => null);

      final result = await controller.getPredictionById('missing-id');

      expect(result, isNull);
    });
  });
}