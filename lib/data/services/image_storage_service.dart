import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/services/logger.dart';
import '../../core/utils/file_utils.dart';

class ImageStorageService {
  ImageStorageService({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  Future<void> ensureInitialized() async {
    await _ensureDirectory(await _imagesDirectoryPath);
    await _ensureDirectory(await _thumbnailsDirectoryPath);
  }

  Future<String> saveOriginalImage({
    required XFile source,
    required String thingId,
    String? versionToken,
  }) async {
    final destinationPath = await buildImagePath(
      thingId: thingId,
      versionToken: versionToken,
    );

    try {
      final bytes = await source.readAsBytes();
      final file = File(destinationPath);
      await file.writeAsBytes(bytes, flush: true);
      _logger.info('Saved image to $destinationPath');
      return destinationPath;
    } catch (error, stackTrace) {
      _logger.error('Failed to persist image', error, stackTrace);
      throw const StorageException('Could not save the location photo.');
    }
  }

  Future<String> buildImagePath({
    required String thingId,
    String? versionToken,
  }) async {
    return path.join(
      await _imagesDirectoryPath,
      buildOriginalImageFileName(
        thingId: thingId,
        versionToken: versionToken,
      ),
    );
  }

  Future<String> buildThumbnailPath({
    required String thingId,
    String? versionToken,
  }) async {
    return path.join(
      await _thumbnailsDirectoryPath,
      buildThumbnailFileName(
        thingId: thingId,
        versionToken: versionToken,
      ),
    );
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return;
    }

    await file.delete();
  }

  Future<void> deleteFileQuietly(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    try {
      await deleteFile(filePath);
    } catch (error, stackTrace) {
      _logger.warning('Failed to delete file $filePath');
      _logger.error('File deletion warning', error, stackTrace);
    }
  }

  Future<String> get _imagesDirectoryPath async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return path.join(documentsDirectory.path, AppConstants.imagesDirectory);
  }

  Future<String> get _thumbnailsDirectoryPath async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return path.join(documentsDirectory.path, AppConstants.thumbnailsDirectory);
  }

  Future<void> _ensureDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      return;
    }

    _logger.info('Creating directory $directoryPath');
    await directory.create(recursive: true);
  }
}
