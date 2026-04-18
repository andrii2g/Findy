import 'package:flutter/foundation.dart';

import '../../../core/services/logger.dart';
import '../../../domain/models/thing.dart';
import '../../../domain/usecases/delete_thing_usecase.dart';
import '../../../domain/usecases/get_thing_by_id_usecase.dart';

enum ThingDetailsStatus { initial, loading, loaded, error, deleting }

class ThingDetailsViewModel extends ChangeNotifier {
  ThingDetailsViewModel({
    required String thingId,
    required GetThingByIdUseCase getThingByIdUseCase,
    required DeleteThingUseCase deleteThingUseCase,
    required AppLogger logger,
  })  : _thingId = thingId,
        _getThingByIdUseCase = getThingByIdUseCase,
        _deleteThingUseCase = deleteThingUseCase,
        _logger = logger;

  final String _thingId;
  final GetThingByIdUseCase _getThingByIdUseCase;
  final DeleteThingUseCase _deleteThingUseCase;
  final AppLogger _logger;

  ThingDetailsStatus status = ThingDetailsStatus.initial;
  Thing? thing;
  String? errorMessage;

  Future<void> load() async {
    status = ThingDetailsStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      thing = await _getThingByIdUseCase(_thingId);
      if (thing == null) {
        status = ThingDetailsStatus.error;
        errorMessage = 'This thing no longer exists.';
      } else {
        status = ThingDetailsStatus.loaded;
      }
    } catch (error, stackTrace) {
      _logger.error('Thing details load failed', error, stackTrace);
      status = ThingDetailsStatus.error;
      errorMessage = 'Could not load this thing.';
    }

    notifyListeners();
  }

  Future<bool> deleteThing() async {
    final currentThing = thing;
    if (currentThing == null) {
      return false;
    }

    status = ThingDetailsStatus.deleting;
    errorMessage = null;
    notifyListeners();

    try {
      await _deleteThingUseCase(currentThing);
      return true;
    } catch (error, stackTrace) {
      _logger.error('Thing delete failed', error, stackTrace);
      status = ThingDetailsStatus.loaded;
      errorMessage = 'Could not delete this thing.';
      notifyListeners();
      return false;
    }
  }
}
