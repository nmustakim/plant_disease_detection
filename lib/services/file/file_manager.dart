import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';


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

  /// Save image to permanent storage
  /// Returns the path to the saved image
  Future<String> saveImage(File imageFile, String predictionId) async {
    try {
      final imagesDir = await getPredictionImagesDirectory();
      final extension = path.extension(imageFile.path);
      final fileName = '${predictionId}$extension';
      final destinationPath = path.join(imagesDir.path, fileName);

      await imageFile.copy(destinationPath);

      AppLogger.info('Image saved: $destinationPath', 'FileManager');
      return destinationPath;
    } catch (e) {
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

  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
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

      AppLogger.info('Deleted $deletedCount old images', 'FileManager');
      return deletedCount;
    } catch (e) {
      AppLogger.error('Failed to delete old images', 'FileManager', e);
      return 0;
    }
  }
}