import '../models/thing.dart';
import '../../data/repositories/thing_repository.dart';

class GetAllThingsUseCase {
  const GetAllThingsUseCase(this._repository);

  final ThingRepository _repository;

  Future<List<Thing>> call() => _repository.getAll();
}
