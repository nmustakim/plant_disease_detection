import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_dd_ai/core/utils/validators.dart';
import 'package:plant_dd_ai/core/constants/error_codes.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Creates a real temp file with the given name and fills it to [sizeBytes].
  Future<File> makeTempFile(String name, {int sizeBytes = 1024}) async {
    final file = File('${Directory.systemTemp.path}/$name');
    await file.writeAsBytes(List.filled(sizeBytes, 0));
    return file;
  }

  // ---------------------------------------------------------------------------
  group('Validators.validateImageFormat', () {
    test('accepts .jpg extension', () async {
      final file = await makeTempFile('leaf.jpg');
      final result = Validators.validateImageFormat(file);
      expect(result.isValid, isTrue);
      await file.delete();
    });

    test('accepts .jpeg extension', () async {
      final file = await makeTempFile('leaf.jpeg');
      final result = Validators.validateImageFormat(file);
      expect(result.isValid, isTrue);
      await file.delete();
    });

    test('accepts .png extension', () async {
      final file = await makeTempFile('leaf.png');
      final result = Validators.validateImageFormat(file);
      expect(result.isValid, isTrue);
      await file.delete();
    });

    test('rejects .bmp extension', () async {
      final file = await makeTempFile('leaf.bmp');
      final result = Validators.validateImageFormat(file);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(ErrorCodes.imgInvalidFormat));
      await file.delete();
    });

    test('rejects .gif extension', () async {
      final file = await makeTempFile('leaf.gif');
      final result = Validators.validateImageFormat(file);
      expect(result.isValid, isFalse);
      await file.delete();
    });

    test('rejects .pdf extension', () async {
      final file = await makeTempFile('leaf.pdf');
      final result = Validators.validateImageFormat(file);
      expect(result.isValid, isFalse);
      await file.delete();
    });

    test('is case-insensitive — accepts .JPG', () async {
      // Validators lower-cases the extension via .toLowerCase()
      final file = await makeTempFile('leaf.JPG');
      final result = Validators.validateImageFormat(file);
      expect(result.isValid, isTrue);
      await file.delete();
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.validateImageSize', () {
    const int tenMB = 10 * 1024 * 1024;

    test('accepts file exactly at 10 MB limit', () async {
      final file = await makeTempFile('ok.jpg', sizeBytes: tenMB);
      final result = Validators.validateImageSize(file);
      expect(result.isValid, isTrue);
      await file.delete();
    });

    test('accepts file well under 10 MB', () async {
      final file = await makeTempFile('small.jpg', sizeBytes: 512 * 1024); // 512 KB
      final result = Validators.validateImageSize(file);
      expect(result.isValid, isTrue);
      await file.delete();
    });

    test('rejects file larger than 10 MB', () async {
      final file = await makeTempFile('big.jpg', sizeBytes: tenMB + 1);
      final result = Validators.validateImageSize(file);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(ErrorCodes.imgFileTooLarge));
      await file.delete();
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.validateImage (combined)', () {
    test('returns invalid with format error when format is wrong', () async {
      final file = await makeTempFile('leaf.bmp', sizeBytes: 1024);
      final result = Validators.validateImage(file);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(ErrorCodes.imgInvalidFormat));
      await file.delete();
    });

    test('returns invalid with size error when size exceeds limit', () async {
      const int tenMB = 10 * 1024 * 1024;
      final file = await makeTempFile('big.jpg', sizeBytes: tenMB + 1);
      final result = Validators.validateImage(file);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals(ErrorCodes.imgFileTooLarge));
      await file.delete();
    });

    test('returns valid for a normal jpg under 10 MB', () async {
      final file = await makeTempFile('good.jpg', sizeBytes: 2 * 1024 * 1024);
      final result = Validators.validateImage(file);
      expect(result.isValid, isTrue);
      await file.delete();
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.validateConfidence', () {
    test('accepts 0.0 as valid', () {
      expect(Validators.validateConfidence(0.0), isTrue);
    });

    test('accepts 1.0 as valid', () {
      expect(Validators.validateConfidence(1.0), isTrue);
    });

    test('accepts 0.75 as valid', () {
      expect(Validators.validateConfidence(0.75), isTrue);
    });

    test('rejects negative confidence', () {
      expect(Validators.validateConfidence(-0.1), isFalse);
    });

    test('rejects confidence above 1.0', () {
      expect(Validators.validateConfidence(1.01), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.validateDiseaseName', () {
    test('accepts a valid alphanumeric name', () {
      expect(Validators.validateDiseaseName('Tomato Early Blight'), isTrue);
    });

    test('accepts names with hyphens and underscores', () {
      expect(Validators.validateDiseaseName('Apple___Black_rot'), isTrue);
    });

    test('rejects an empty string', () {
      expect(Validators.validateDiseaseName(''), isFalse);
    });

    test('rejects a name longer than 100 characters', () {
      final longName = 'A' * 101;
      expect(Validators.validateDiseaseName(longName), isFalse);
    });

    test('accepts a name exactly 100 characters long', () {
      final exactName = 'A' * 100;
      expect(Validators.validateDiseaseName(exactName), isTrue);
    });

    test('rejects names with special characters like @', () {
      expect(Validators.validateDiseaseName('Disease@2024!'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.validateUrl', () {
    test('accepts https:// URLs', () {
      expect(Validators.validateUrl('https://www.fao.org/disease'), isTrue);
    });

    test('accepts http:// URLs', () {
      expect(Validators.validateUrl('http://example.com'), isTrue);
    });

    test('rejects URL without scheme', () {
      expect(Validators.validateUrl('www.example.com'), isFalse);
    });

    test('rejects ftp:// URLs', () {
      expect(Validators.validateUrl('ftp://example.com'), isFalse);
    });

    test('rejects empty string', () {
      expect(Validators.validateUrl(''), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('Validators.validateTimestamp', () {
    test('accepts a valid past unix timestamp', () {
      final pastTimestamp =
          DateTime(2024, 1, 1).millisecondsSinceEpoch ~/ 1000;
      expect(Validators.validateTimestamp(pastTimestamp), isTrue);
    });

    test('rejects zero timestamp', () {
      expect(Validators.validateTimestamp(0), isFalse);
    });

    test('rejects negative timestamp', () {
      expect(Validators.validateTimestamp(-1), isFalse);
    });

    test('rejects a future timestamp', () {
      final futureTimestamp =
          DateTime(2099, 1, 1).millisecondsSinceEpoch ~/ 1000;
      expect(Validators.validateTimestamp(futureTimestamp), isFalse);
    });

    test('accepts current timestamp', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      expect(Validators.validateTimestamp(now), isTrue);
    });
  });
}
