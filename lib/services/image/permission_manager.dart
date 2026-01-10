import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/error_codes.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/logger.dart';


class PermissionManager {

  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        AppLogger.info('Camera permission granted', 'PermissionManager');
        return true;
      } else if (status.isDenied) {
        AppLogger.warning('Camera permission denied', 'PermissionManager');
        throw PermissionException(
          ErrorCodes.errorMessages[ErrorCodes.permCameraDenied]!,
          ErrorCodes.permCameraDenied,
        );
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('Camera permission permanently denied', 'PermissionManager');
        throw PermissionException(
          'Camera permission is permanently denied. Please enable it in settings.',
          ErrorCodes.permCameraDenied,
        );
      }

      return false;
    } catch (e) {
      if (e is PermissionException) rethrow;
      AppLogger.error('Failed to request camera permission', 'PermissionManager', e);
      throw PermissionException(
        'Failed to request camera permission',
        ErrorCodes.permCameraDenied,
      );
    }
  }


  Future<bool> requestGalleryPermission() async {
    try {
      final status = await Permission.photos.request();

      if (status.isGranted || status.isLimited) {
        AppLogger.info('Gallery permission granted', 'PermissionManager');
        return true;
      } else if (status.isDenied) {
        AppLogger.warning('Gallery permission denied', 'PermissionManager');
        throw PermissionException(
          ErrorCodes.errorMessages[ErrorCodes.permGalleryDenied]!,
          ErrorCodes.permGalleryDenied,
        );
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('Gallery permission permanently denied', 'PermissionManager');
        throw PermissionException(
          'Gallery permission is permanently denied. Please enable it in settings.',
          ErrorCodes.permGalleryDenied,
        );
      }

      return false;
    } catch (e) {
      if (e is PermissionException) rethrow;
      AppLogger.error('Failed to request gallery permission', 'PermissionManager', e);
      throw PermissionException(
        'Failed to request gallery permission',
        ErrorCodes.permGalleryDenied,
      );
    }
  }

  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> isGalleryPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}