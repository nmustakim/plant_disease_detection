import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class ImagePreprocessor {
  final int size;

  ImagePreprocessor({
    this.size = AppConstants.modelInputSize,
  });

  Future<Float32List> preprocessImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
      final resized = cv.resize(mat, (size, size));

      // Convert to RGB
      final rgb = cv.cvtColor(resized, cv.COLOR_BGR2RGB);

      return _toFloat32(rgb);
    } catch (e) {
      AppLogger.error("Preprocessing failed", "ImagePreprocessor", e);
      rethrow;
    }
  }

  Float32List _toFloat32(cv.Mat mat) {
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
      print(buffer.take(10));
    }
    return buffer;
  }}