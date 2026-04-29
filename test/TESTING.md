# Test Suite — Plant DD AI

## Structure

```
test/
└── unit/
    ├── prediction_model_test.dart        # Prediction data model
    ├── disease_classifier_test.dart      # DiseaseClassifier.getTopPrediction logic
    ├── validators_test.dart              # Validators utility (format, size, confidence, URL, timestamp)
    ├── date_time_utils_test.dart         # DateTimeUtils utility
    ├── error_codes_test.dart             # ErrorCodes constants & getErrorType()
    ├── history_controller_test.dart      # HistoryController (mocked DatabaseManager)
    └── prediction_controller_test.dart   # PredictionController (all deps mocked)
```

## One-time setup

Mock files are **generated** by `build_runner` and are **not** committed to git.
You must generate them before running tests:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This produces:
- `test/unit/history_controller_test.mocks.dart`
- `test/unit/prediction_controller_test.mocks.dart`

## Running tests

```bash
# All unit tests
flutter test test/unit/

# Single file
flutter test test/unit/validators_test.dart

# With coverage
flutter test test/unit/ --coverage
genhtml coverage/lcov.info -o coverage/html

# Or use the convenience script
bash run_tests.sh
```

## Test count by file

| File | Groups | Tests |
|------|--------|-------|
| prediction_model_test.dart | 1 | 9 |
| disease_classifier_test.dart | 1 | 7 |
| validators_test.dart | 6 | 20 |
| date_time_utils_test.dart | 6 | 14 |
| error_codes_test.dart | 2 | 12 |
| history_controller_test.dart | 4 | 10 |
| prediction_controller_test.dart | 3 | 8 |
| **Total** | **23** | **80** |

## What is NOT tested here

| Area | Reason |
|------|--------|
| TFLite model loading (`loadModel`, `runInference`) | Requires physical device + bundled `.tflite` asset; tested via system/integration tests |
| OpenCV image preprocessing | Native C++ bindings; not runnable in Dart unit test environment |
| SQLite DAO layer | Requires `sqflite` FFI or integration test device; use `flutter test integration_test/` |
| UI / widget tests | Covered in `test/widget_test.dart` and integration tests |
| Firebase sync | Requires live Firebase project; tested manually or with emulator |

## Notes

- `DiseaseClassifier` tests only cover `getTopPrediction()` — the pure Dart
  scoring logic. Model loading and inference are hardware-dependent.
- `PredictionController` tests use `File('/tmp/test_leaf.jpg')` as a stand-in
  for an image file. The preprocessor mock intercepts before any real I/O.
- All confidence thresholds tested match `AppConstants.confidenceThreshold = 0.60`
  and `AppConstants.highConfidenceThreshold = 0.85`.
