import 'dart:io';

import 'package:image/image.dart' as img;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/services/logger.dart';
import 'image_storage_service.dart';

class ThumbnailService {
  ThumbnailService({
    required ImageStorageService imageStorageService,
    required AppLogger logger,
  })  : _imageStorageService = imageStorageService,
        _logger = logger;

  final ImageStorageService _imageStorageService;
  final AppLogger _logger;

  Future<String> createThumbnail({
    required String sourceImagePath,
    required String thingId,
    String? versionToken,
  }) async {
    final thumbnailPath = await _imageStorageService.buildThumbnailPath(
      thingId: thingId,
      versionToken: versionToken,
    );

    try {
      final sourceFile = File(sourceImagePath);
      final bytes = await sourceFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw const StorageException('Could not process the location photo.');
      }

      final resizedImage = img.copyResize(
        decodedImage,
        width: AppConstants.thumbnailMaxWidth,
      );

      final encodedBytes = img.encodeJpg(
        resizedImage,
        quality: AppConstants.thumbnailQuality,
      );

      await File(thumbnailPath).writeAsBytes(encodedBytes, flush: true);
      _logger.info('Created thumbnail at $thumbnailPath');

      return thumbnailPath;
    } catch (error, stackTrace) {
      _logger.error('Failed to create thumbnail', error, stackTrace);
      throw const StorageException('Could not generate the thumbnail.');
    }
  }
}
