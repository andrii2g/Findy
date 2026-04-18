import 'package:flutter/foundation.dart';

import '../../../core/services/logger.dart';
import '../../../domain/models/thing.dart';
import '../../../domain/usecases/get_all_things_usecase.dart';
import '../../../domain/usecases/search_things_usecase.dart';

enum ThingListStatus { initial, loading, loaded, empty, error }

class ThingListViewModel extends ChangeNotifier {
  ThingListViewModel({
    required GetAllThingsUseCase getAllThingsUseCase,
    required SearchThingsUseCase searchThingsUseCase,
    required AppLogger logger,
  })  : _getAllThingsUseCase = getAllThingsUseCase,
        _searchThingsUseCase = searchThingsUseCase,
        _logger = logger;

  final GetAllThingsUseCase _getAllThingsUseCase;
  final SearchThingsUseCase _searchThingsUseCase;
  final AppLogger _logger;

  ThingListStatus status = ThingListStatus.initial;
  List<Thing> things = const [];
  String searchQuery = '';
  String? errorMessage;

  Future<void> loadThings() async {
    await _runLoad(() => _getAllThingsUseCase());
  }

  Future<void> updateSearchQuery(String value) async {
    searchQuery = value;
    await _runLoad(() => _searchThingsUseCase(value));
  }

  Future<void> _runLoad(Future<List<Thing>> Function() loader) async {
    status = ThingListStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      things = await loader();
      status = things.isEmpty ? ThingListStatus.empty : ThingListStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error('List loading failed', error, stackTrace);
      status = ThingListStatus.error;
      errorMessage = 'Could not load your saved things.';
    }

    notifyListeners();
  }
}
