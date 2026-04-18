import '../models/thing.dart';
import '../../data/repositories/thing_repository.dart';

class SearchThingsUseCase {
  const SearchThingsUseCase(this._repository);

  final ThingRepository _repository;

  Future<List<Thing>> call(String query) =>
      _repository.searchByDescription(query);
}
