import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/services/logger.dart';
import '../../data/repositories/thing_repository.dart';
import '../../data/services/image_storage_service.dart';
import '../../data/services/thumbnail_service.dart';
import '../models/thing.dart';

class AddThingUseCase {
  AddThingUseCase({
    required ThingRepository repository,
    required ImageStorageService imageStorageService,
    required ThumbnailService thumbnailService,
    required AppLogger logger,
    Uuid? uuid,
  })  : _repository = repository,
        _imageStorageService = imageStorageService,
        _thumbnailService = thumbnailService,
        _logger = logger,
        _uuid = uuid ?? const Uuid();

  final ThingRepository _repository;
  final ImageStorageService _imageStorageService;
  final ThumbnailService _thumbnailService;
  final AppLogger _logger;
  final Uuid _uuid;

  Future<Thing> call({
    required String description,
    required XFile photo,
  }) async {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) {
      throw const ValidationException('Please describe the thing first.');
    }

    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    String? imagePath;
    String? thumbnailPath;

    try {
      imagePath = await _imageStorageService.saveOriginalImage(
        source: photo,
        thingId: id,
      );
      thumbnailPath = await _thumbnailService.createThumbnail(
        sourceImagePath: imagePath,
        thingId: id,
      );

      final thing = Thing(
        id: id,
        description: trimmedDescription,
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.insert(thing);
      return thing;
    } catch (error, stackTrace) {
      _logger.error('Add thing failed', error, stackTrace);
      await _imageStorageService.deleteFileQuietly(imagePath);
      await _imageStorageService.deleteFileQuietly(thumbnailPath);
      rethrow;
    }
  }
}
