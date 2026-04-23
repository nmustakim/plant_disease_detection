
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../permission/permission_manager.dart';
import '../file/file_manager.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/logger.dart';

class ImageService {
  final ImagePicker       _picker     = ImagePicker();
  final PermissionManager _permissions = PermissionManager();
  final FileManager       _files       = FileManager();


  Future<File> captureImage() async {
    await _permissions.requestCameraPermission();
    final picked = await _picker.pickImage(
      source:    ImageSource.camera,
      imageQuality: 90,
    );
    return _toValidatedFile(picked, 'captureImage');
  }


  Future<File> selectImage() async {
    await _permissions.requestGalleryPermission();
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    return _toValidatedFile(picked, 'selectImage');
  }

  Future<File> _toValidatedFile(XFile? picked, String caller) async {
    if (picked == null) {
      throw AppError(
        code: AppErrorCode.unknown,
        message: 'No image selected.',
      );
    }
    final file = File(picked.path);
    await _files.validateImage(file);
    AppLogger.info('Image ready: ${picked.path}', caller);
    return file;
  }


  Future<bool> validateImageFormat(File file) =>
      _files.validateImage(file).then((_) => true).catchError((_) => false);

  Future<bool> validateImageSize(File file) async {
    final bytes = await _files.getFileSize(file.path);
    return bytes <= 10 * 1024 * 1024;
  }
}
