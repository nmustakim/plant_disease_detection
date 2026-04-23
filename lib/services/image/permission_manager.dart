import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
        // Open settings automatically
        final opened = await openAppSettings();
        if (opened) {
          AppLogger.info('Opened app settings to allow user to grant camera permission', 'PermissionManager');
        }
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
      PermissionStatus status;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
          AppLogger.info('Requesting photos permission (Android 13+)', 'PermissionManager');
        } else {
          status = await Permission.storage.request();
          AppLogger.info('Requesting storage permission (Android 12 and below)', 'PermissionManager');
        }
      } else if (Platform.isIOS) {
        status = await Permission.photos.request();
        AppLogger.info('Requesting photos permission (iOS)', 'PermissionManager');
      } else {
        status = await Permission.photos.request();
      }

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
        final opened = await openAppSettings();
        if (opened) {
          AppLogger.info('Opened app settings to allow user to grant gallery permission', 'PermissionManager');
        }
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
    try {
      PermissionStatus status;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.status;
        } else {
          status = await Permission.storage.status;
        }
      } else {
        status = await Permission.photos.status;
      }

      return status.isGranted || status.isLimited;
    } catch (e) {
      AppLogger.error('Failed to check gallery permission', 'PermissionManager', e);
      return false;
    }
  }

  Future<bool> openSettings() async {
    try {
      final opened = await openAppSettings();
      if (opened) {
        AppLogger.info('App settings opened', 'PermissionManager');
      } else {
        AppLogger.warning('Failed to open app settings', 'PermissionManager');
      }
      return opened;
    } catch (e) {
      AppLogger.error('Error opening app settings', 'PermissionManager', e);
      return false;
    }
  }
}