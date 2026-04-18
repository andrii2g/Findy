import 'package:image_picker/image_picker.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/services/logger.dart';
import '../../data/repositories/thing_repository.dart';
import '../../data/services/image_storage_service.dart';
import '../../data/services/thumbnail_service.dart';
import '../models/thing.dart';

class UpdateThingUseCase {
  UpdateThingUseCase({
    required ThingRepository repository,
    required ImageStorageService imageStorageService,
    required ThumbnailService thumbnailService,
    required AppLogger logger,
  })  : _repository = repository,
        _imageStorageService = imageStorageService,
        _thumbnailService = thumbnailService,
        _logger = logger;

  final ThingRepository _repository;
  final ImageStorageService _imageStorageService;
  final ThumbnailService _thumbnailService;
  final AppLogger _logger;

  Future<Thing> call({
    required Thing existingThing,
    required String description,
    XFile? replacementPhoto,
  }) async {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) {
      throw const ValidationException('Please describe the thing first.');
    }

    final now = DateTime.now().toUtc();
    var imagePath = existingThing.imagePath;
    var thumbnailPath = existingThing.thumbnailPath;
    String? newImagePath;
    String? newThumbnailPath;

    try {
      if (replacementPhoto != null) {
        final versionToken = now.millisecondsSinceEpoch.toString();
        newImagePath = await _imageStorageService.saveOriginalImage(
          source: replacementPhoto,
          thingId: existingThing.id,
          versionToken: versionToken,
        );
        newThumbnailPath = await _thumbnailService.createThumbnail(
          sourceImagePath: newImagePath,
          thingId: existingThing.id,
          versionToken: versionToken,
        );
        imagePath = newImagePath;
        thumbnailPath = newThumbnailPath;
      }

      final updatedThing = existingThing.copyWith(
        description: trimmedDescription,
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
        updatedAt: now,
      );

      await _repository.update(updatedThing);

      if (replacementPhoto != null) {
        await _imageStorageService.deleteFileQuietly(existingThing.imagePath);
        await _imageStorageService.deleteFileQuietly(
          existingThing.thumbnailPath,
        );
      }

      return updatedThing;
    } catch (error, stackTrace) {
      _logger.error('Update thing failed', error, stackTrace);
      await _imageStorageService.deleteFileQuietly(newImagePath);
      await _imageStorageService.deleteFileQuietly(newThumbnailPath);
      rethrow;
    }
  }
}
