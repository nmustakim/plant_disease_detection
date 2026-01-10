import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/error_codes.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/logger.dart';
import 'permission_manager.dart';
import '../file/file_manager.dart';


class ImageService {
  final PermissionManager permissionManager;
  final FileManager fileManager;
  final ImagePicker _picker = ImagePicker();

  ImageService({
    PermissionManager? permissionManager,
    FileManager? fileManager,
  })  : permissionManager = permissionManager ?? PermissionManager(),
        fileManager = fileManager ?? FileManager();


  Future<File> captureImage() async {
    try {
      // Request permission
      await permissionManager.requestCameraPermission();

      AppLogger.info('Opening camera...', 'ImageService');

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) {
        throw ValidationException('No image captured', ErrorCodes.imgCorrupt);
      }

      final imageFile = File(photo.path);

      final validationResult = Validators.validateImage(imageFile);
      if (!validationResult.isValid) {
        throw ValidationException(
          validationResult.errorMessage!,
          validationResult.errorCode,
        );
      }

      AppLogger.info('Image captured successfully: ${photo.path}', 'ImageService');
      return imageFile;
    } catch (e) {
      if (e is PermissionException || e is ValidationException) rethrow;
      AppLogger.error('Failed to capture image', 'ImageService', e);
      throw ValidationException('Failed to capture image', ErrorCodes.imgCorrupt);
    }
  }


  Future<File> selectImage() async {
    try {
      await permissionManager.requestGalleryPermission();

      AppLogger.info('Opening gallery...', 'ImageService');

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) {
        throw ValidationException('No image selected', ErrorCodes.imgCorrupt);
      }

      final imageFile = File(photo.path);

      final validationResult = Validators.validateImage(imageFile);
      if (!validationResult.isValid) {
        throw ValidationException(
          validationResult.errorMessage!,
          validationResult.errorCode,
        );
      }

      AppLogger.info('Image selected successfully: ${photo.path}', 'ImageService');
      return imageFile;
    } catch (e) {
      if (e is PermissionException || e is ValidationException) rethrow;
      AppLogger.error('Failed to select image', 'ImageService', e);
      throw ValidationException('Failed to select image', ErrorCodes.imgCorrupt);
    }
  }


  bool validateImageFormat(File file) {
    final result = Validators.validateImageFormat(file);
    return result.isValid;
  }

  bool validateImageSize(File file) {
    final result = Validators.validateImageSize(file);
    return result.isValid;
  }

  Future<String> saveImage(File imageFile, String predictionId) async {
    try {
      return await fileManager.saveImage(imageFile, predictionId);
    } catch (e) {
      AppLogger.error('Failed to save image', 'ImageService', e);
      rethrow;
    }
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      return await fileManager.deleteFile(imagePath);
    } catch (e) {
      AppLogger.error('Failed to delete image', 'ImageService', e);
      return false;
    }
  }
}