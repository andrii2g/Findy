import '../models/thing.dart';
import '../../data/repositories/thing_repository.dart';

class GetThingByIdUseCase {
  const GetThingByIdUseCase(this._repository);

  final ThingRepository _repository;

  Future<Thing?> call(String id) => _repository.getById(id);
}
