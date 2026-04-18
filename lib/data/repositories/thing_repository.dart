import '../../core/services/logger.dart';
import '../../data/db/app_database.dart';
import '../../data/db/thing_table.dart';
import '../../data/models/thing_entity.dart';
import '../../domain/models/thing.dart';

class ThingRepository {
  ThingRepository({
    required AppDatabase appDatabase,
    required AppLogger logger,
  })  : _appDatabase = appDatabase,
        _logger = logger;

  final AppDatabase _appDatabase;
  final AppLogger _logger;

  Future<void> insert(Thing thing) async {
    final database = await _appDatabase.database;
    _logger.info('Inserting thing ${thing.id}');
    await database.insert(
      ThingTable.tableName,
      ThingEntity.fromDomain(thing).toMap(),
    );
  }

  Future<List<Thing>> getAll() async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      ThingTable.tableName,
      orderBy: '${ThingTable.updatedAt} DESC',
    );

    return rows.map(ThingEntity.fromMap).map((entity) => entity.toDomain()).toList();
  }

  Future<Thing?> getById(String id) async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      ThingTable.tableName,
      where: '${ThingTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return ThingEntity.fromMap(rows.first).toDomain();
  }

  Future<List<Thing>> searchByDescription(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return getAll();
    }

    final database = await _appDatabase.database;
    final rows = await database.query(
      ThingTable.tableName,
      where: 'LOWER(${ThingTable.description}) LIKE ?',
      whereArgs: [buildSearchPattern(trimmedQuery)],
      orderBy: '${ThingTable.updatedAt} DESC',
    );

    return rows.map(ThingEntity.fromMap).map((entity) => entity.toDomain()).toList();
  }

  Future<void> update(Thing thing) async {
    final database = await _appDatabase.database;
    _logger.info('Updating thing ${thing.id}');
    await database.update(
      ThingTable.tableName,
      ThingEntity.fromDomain(thing).toMap(),
      where: '${ThingTable.id} = ?',
      whereArgs: [thing.id],
    );
  }

  Future<void> delete(String id) async {
    final database = await _appDatabase.database;
    _logger.info('Deleting thing $id');
    await database.delete(
      ThingTable.tableName,
      where: '${ThingTable.id} = ?',
      whereArgs: [id],
    );
  }

  static String buildSearchPattern(String query) {
    return '%${query.toLowerCase()}%';
  }
}
