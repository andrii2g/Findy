import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/services/logger.dart';
import 'data/db/app_database.dart';
import 'data/repositories/thing_repository.dart';
import 'data/services/image_storage_service.dart';
import 'data/services/thumbnail_service.dart';
import 'domain/usecases/add_thing_usecase.dart';
import 'domain/usecases/delete_thing_usecase.dart';
import 'domain/usecases/get_all_things_usecase.dart';
import 'domain/usecases/get_thing_by_id_usecase.dart';
import 'domain/usecases/search_things_usecase.dart';
import 'domain/usecases/update_thing_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = AppLogger();
  final database = AppDatabase(logger: logger);
  await database.database;

  final imageStorageService = ImageStorageService(logger: logger);
  await imageStorageService.ensureInitialized();

  final thumbnailService = ThumbnailService(
    imageStorageService: imageStorageService,
    logger: logger,
  );

  final repository = ThingRepository(
    appDatabase: database,
    logger: logger,
  );

  runApp(
    FindyApp(
      logger: logger,
      thingRepository: repository,
      addThingUseCase: AddThingUseCase(
        repository: repository,
        imageStorageService: imageStorageService,
        thumbnailService: thumbnailService,
        logger: logger,
      ),
      getAllThingsUseCase: GetAllThingsUseCase(repository),
      searchThingsUseCase: SearchThingsUseCase(repository),
      getThingByIdUseCase: GetThingByIdUseCase(repository),
      updateThingUseCase: UpdateThingUseCase(
        repository: repository,
        imageStorageService: imageStorageService,
        thumbnailService: thumbnailService,
        logger: logger,
      ),
      deleteThingUseCase: DeleteThingUseCase(
        repository: repository,
        imageStorageService: imageStorageService,
        logger: logger,
      ),
    ),
  );
}
