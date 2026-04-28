import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

abstract class PreprocessingStrategy {
  /// Preprocesses [imageFile] and returns a normalised [Float32List] tensor
  /// ready for model inference.
  Future<Float32List> preprocess(File imageFile);
}


class MobileNetV2Preprocessor implements PreprocessingStrategy {
  static const int TARGET_SIZE = AppConstants.modelInputSize; // 224

  final int size;

  MobileNetV2Preprocessor({this.size = TARGET_SIZE});

  @override
  Future<Float32List> preprocess(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final mat     = cv.imdecode(bytes, cv.IMREAD_COLOR);
      final resized = cv.resize(mat, (size, size));

      final rgb = cv.cvtColor(resized, cv.COLOR_BGR2RGB);

      return _imageToFloat32List(rgb);
    } catch (e) {
      AppLogger.error('Preprocessing failed', 'MobileNetV2Preprocessor', e);
      rethrow;
    }
  }

  Float32List _imageToFloat32List(cv.Mat mat) {
    final w = mat.cols;
    final h = mat.rows;

    final buffer = Float32List(w * h * 3);
    int index = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = mat.at<cv.Vec3b>(y, x);
        buffer[index++] = pixel.val[0] / 255.0;
        buffer[index++] = pixel.val[1] / 255.0;
        buffer[index++] = pixel.val[2] / 255.0;
      }
    }

    if (kDebugMode) {
      print('[MobileNetV2Preprocessor] First 10 values: ${buffer.take(10).toList()}');
    }

    return buffer;
  }
}


class ImagePreprocessor {
  final PreprocessingStrategy strategy;

  ImagePreprocessor({PreprocessingStrategy? strategy})
      : strategy = strategy ?? MobileNetV2Preprocessor();

  Future<Float32List> preprocessImage(File imageFile) =>
      strategy.preprocess(imageFile);
}