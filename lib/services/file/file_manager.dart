import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/logger.dart';

const _kAllowedExtensions = {'.jpg', '.jpeg', '.png'};

const _kMaxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

class FileManager {
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  Future<Directory> getPredictionImagesDirectory() async {
    final docsDir = await getDocumentsDirectory();
    final imagesDir = Directory(
      path.join(docsDir.path, AppConstants.predictionImagesFolder),
    );
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  Future<bool> validateImage(File imageFile) async {
    if (!await imageFile.exists()) {
      AppLogger.error('Image file not found', 'FileManager');
      throw AppError(
        code: AppErrorCode.imgCorrupt,
        message: 'Image file is corrupted or missing.',
      );
    }

    final ext = path.extension(imageFile.path).toLowerCase();
    if (!_kAllowedExtensions.contains(ext)) {
      AppLogger.warning('Unsupported image format: $ext', 'FileManager');
      throw AppError(
        code: AppErrorCode.imgInvalidFormat,
        message: 'Image format not supported. Please use JPG or PNG.',
      );
    }

    final sizeBytes = await getFileSize(imageFile.path);
    if (sizeBytes > _kMaxFileSizeBytes) {
      AppLogger.warning(
        'Image too large: ${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB',
        'FileManager',
      );
      throw AppError(
        code: AppErrorCode.imgFileTooLarge,
        message: 'Image exceeds 10 MB limit. Please compress and retry.',
      );
    }

    AppLogger.info(
      'Image validated: $ext, ${getFileSizeInMB(sizeBytes).toStringAsFixed(2)} MB',
      'FileManager',
    );
    return true;
  }

  double getFileSizeInMB(int bytes) => bytes / (1024 * 1024);

  Future<String> saveImage(File imageFile, String predictionId) async {
    await validateImage(imageFile);

    try {
      final imagesDir = await getPredictionImagesDirectory();
      final ext = path.extension(imageFile.path).toLowerCase();
      final fileName = '$predictionId$ext';
      final destinationPath = path.join(imagesDir.path, fileName);

      await imageFile.copy(destinationPath);
      AppLogger.info('Image saved: $destinationPath', 'FileManager');
      return destinationPath;
    } catch (e) {
      if (e is AppError) rethrow;
      AppLogger.error('Failed to save image', 'FileManager', e);
      rethrow;
    }
  }

  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('File deleted: $filePath', 'FileManager');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to delete file', 'FileManager', e);
      return false;
    }
  }

  Future<int> deleteOldImages(int daysOld) async {
    try {
      final imagesDir = await getPredictionImagesDirectory();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      AppLogger.info(
        'Deleted $deletedCount image(s) older than $daysOld day(s)',
        'FileManager',
      );
      return deletedCount;
    } catch (e) {
      AppLogger.error('Failed to delete old images', 'FileManager', e);
      return 0;
    }
  }

  Future<bool> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
        AppLogger.info('Cache cleared', 'FileManager');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to clear cache', 'FileManager', e);
      return false;
    }
  }

  Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  Future<int> getFileSize(String filePath) async {
    return await File(filePath).length();
  }
}
