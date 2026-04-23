
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../core/errors/app_error.dart';
import '../../core/utils/logger.dart';

class PermissionManager {
  Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    if (status.isGranted) {
      AppLogger.info('Camera permission granted', 'PermissionManager');
      return true;
    }
    AppLogger.warning('Camera permission denied: $status', 'PermissionManager');
    throw AppError(code: AppErrorCode.permCameraDenied, message: 'Camera permission denied.');
  }

  Future<bool> requestGalleryPermission() async {
    final status = await ph.Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      AppLogger.info('Gallery permission granted', 'PermissionManager');
      return true;
    }
    AppLogger.warning('Gallery permission denied: $status', 'PermissionManager');
    throw AppError(code: AppErrorCode.permGalleryDenied, message: 'Gallery permission denied.');
  }

  Future<bool> isCameraPermissionGranted() async => await ph.Permission.camera.isGranted;

  Future<bool> isGalleryPermissionGranted() async =>
      await ph.Permission.photos.isGranted || await ph.Permission.photos.isLimited;

  Future<void> openAppSettings() async => await ph.openAppSettings();
}
