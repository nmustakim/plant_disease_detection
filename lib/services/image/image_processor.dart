import 'dart:io';
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class ImagePreprocessor {
  final int targetWidth;
  final int targetHeight;

  ImagePreprocessor({
    this.targetWidth = AppConstants.modelInputSize,
    this.targetHeight = AppConstants.modelInputSize,
  });

  /// Preprocess image: decode, resize, convert to RGB, and return Uint8List [H,W,C]
  Future<Uint8List> preprocessImage(File imageFile) async {
    try {
      AppLogger.info('Preprocessing image...', 'ImagePreprocessor');
      final startTime = DateTime.now();

      // Read bytes
      final bytes = await imageFile.readAsBytes();

      // Decode image
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      // Resize to targetWidth x targetHeight
      final resized = cv.resize(mat, (targetWidth, targetHeight));

      // Convert BGR -> RGB
      final rgb = cv.cvtColor(resized, cv.COLOR_BGR2RGB);

      // Convert OpenCV data to Uint8List
      final buffer = _matToUint8List(rgb);

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.performance('Image preprocessing', duration);

      return buffer;
    } catch (e) {
      AppLogger.error('Failed to preprocess image', 'ImagePreprocessor', e);
      rethrow;
    }
  }

  /// Convert OpenCV Mat to Uint8List for uint8 TFLite model
  Uint8List _matToUint8List(cv.Mat mat) {
    final data = mat.data;

    if (data is Float32List) {
      // Float32List -> Uint8List
      final buffer = Uint8List(data.length);
      for (int i = 0; i < data.length; i++) {
        buffer[i] = (data[i] * 255).clamp(0, 255).toInt();
      }
      return buffer;
    } else {
      // Already uint8
    return data;
    }

  }
}
