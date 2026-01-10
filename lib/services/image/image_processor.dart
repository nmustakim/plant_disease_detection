import 'dart:io';
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';


class ImagePreprocessor {
  final int targetWidth;
  final int targetHeight;
  final double normalizationMin;
  final double normalizationMax;

  ImagePreprocessor({
    this.targetWidth = AppConstants.modelInputSize,
    this.targetHeight = AppConstants.modelInputSize,
    this.normalizationMin = 0.0,
    this.normalizationMax = 1.0,
  });


  Future<List<List<List<double>>>> preprocessImage(File imageFile) async {
    try {
      AppLogger.info('Preprocessing image...', 'ImagePreprocessor');
      final startTime = DateTime.now();

      // Read image bytes
      final bytes = await imageFile.readAsBytes();

      // Decode image using OpenCV (IMREAD_COLOR = 1)
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      // Resize to 224x224
      final resized = resizeImage(mat, targetWidth, targetHeight);

      // Convert BGR to RGB (OpenCV uses BGR by default)
      final rgb = cv.cvtColor(resized, cv.COLOR_BGR2RGB);

      // Normalize pixels to [0.0, 1.0]
      final normalized = normalizePixels(rgb);

      // Convert to 3D list format [height][width][channels]
      final tensor = _matToTensor(normalized);

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.performance('Image preprocessing', duration);

      return tensor;
    } catch (e) {
      AppLogger.error('Failed to preprocess image', 'ImagePreprocessor', e);
      rethrow;
    }
  }


  cv.Mat resizeImage(cv.Mat image, int width, int height) {
    return cv.resize(
      image,
      (width, height),
      interpolation: cv.INTER_LINEAR,
    );
  }


  cv.Mat normalizePixels(cv.Mat mat) {
    // Convert to float32 and divide by 255.0
    final float32Mat = mat.convertTo(
      cv.MatType.CV_32FC3,
      alpha: 1.0 / 255.0,
      beta: 0.0,
    );
    return float32Mat;
  }

  /// Convert OpenCV Mat to 3D tensor [height][width][channels]
  List<List<List<double>>> _matToTensor(cv.Mat mat) {
    final height = mat.rows;
    final width = mat.cols;
    final channels = mat.channels;

    // Get data as typed list
    final data = mat.data;

    final tensor = List<List<List<double>>>.generate(
      height,
          (h) => List<List<double>>.generate(
        width,
            (w) => List<double>.generate(
          channels,
              (c) {
            final index = (h * width + w) * channels + c;
            if (data is Float32List) {
              return data[index].toDouble();
            } else {
              return data[index].toDouble() / 255.0;
            }

          },
        ),
      ),
    );

    return tensor;
  }

  cv.Mat augmentImage(cv.Mat image, {
    double rotation = 0.0,
    double brightness = 0.0,
    double zoom = 1.0,
  }) {
    var augmented = image;

    // Apply rotation (±15°)
    if (rotation != 0.0) {
      final centerX = image.cols / 2;
      final centerY = image.rows / 2;
      final center = cv.Point2f(centerX, centerY);
      final rotMat = cv.getRotationMatrix2D(center, rotation, 1.0);
      augmented = cv.warpAffine(
        augmented,
        rotMat,
        (image.cols, image.rows),
      );
    }

    // Apply brightness adjustment (±10%)
    if (brightness != 0.0) {
      augmented = augmented.convertTo(
        cv.MatType.CV_8UC3,
        alpha: 1.0,
        beta: brightness,
      );
    }

    // Apply zoom (0.8-1.2×)
    if (zoom != 1.0) {
      final newWidth = (image.cols * zoom).toInt();
      final newHeight = (image.rows * zoom).toInt();
      augmented = cv.resize(augmented, (newWidth, newHeight));

      // Crop/pad to original size if needed
      if (zoom > 1.0) {
        // Crop center
        final x = (augmented.cols - image.cols) ~/ 2;
        final y = (augmented.rows - image.rows) ~/ 2;
        final rect = cv.Rect(x, y, image.cols, image.rows);
        augmented = augmented.region(rect);
      }
    }

    return augmented;
  }
}