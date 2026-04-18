import '../../core/services/logger.dart';
import '../../data/repositories/thing_repository.dart';
import '../../data/services/image_storage_service.dart';
import '../models/thing.dart';

class DeleteThingUseCase {
  DeleteThingUseCase({
    required ThingRepository repository,
    required ImageStorageService imageStorageService,
    required AppLogger logger,
  })  : _repository = repository,
        _imageStorageService = imageStorageService,
        _logger = logger;

  final ThingRepository _repository;
  final ImageStorageService _imageStorageService;
  final AppLogger _logger;

  Future<void> call(Thing thing) async {
    await _repository.delete(thing.id);

    try {
      await _imageStorageService.deleteFile(thing.imagePath);
    } catch (error, stackTrace) {
      _logger.warning('Failed to delete original image for ${thing.id}');
      _logger.error('Original image deletion warning', error, stackTrace);
    }

    try {
      await _imageStorageService.deleteFile(thing.thumbnailPath);
    } catch (error, stackTrace) {
      _logger.warning('Failed to delete thumbnail for ${thing.id}');
      _logger.error('Thumbnail deletion warning', error, stackTrace);
    }
  }
}
