

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class ImagePreprocessor {
  static const int _targetSize = AppConstants.modelInputSize; // 224


  Float32List preprocessImage(File imageFile) {
    AppLogger.info('Preprocessing image: ${imageFile.path}', 'ImagePreprocessor');

    final bytes  = imageFile.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Failed to decode image: ${imageFile.path}');
    }

    final resized = img.copyResize(
      decoded,
      width:  _targetSize,
      height: _targetSize,
      interpolation: img.Interpolation.linear,
    );

    return _toFloat32Tensor(resized);
  }

  Float32List _toFloat32Tensor(img.Image image) {
    final buffer = Float32List(1 * _targetSize * _targetSize * 3);
    int idx = 0;
    for (int y = 0; y < _targetSize; y++) {
      for (int x = 0; x < _targetSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[idx++] = pixel.r / 255.0;
        buffer[idx++] = pixel.g / 255.0;
        buffer[idx++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }


  img.Image resizeImage(img.Image source, int width, int height) =>
      img.copyResize(source, width: width, height: height);

  Float32List normalizePixels(img.Image image) => _toFloat32Tensor(image);
}
