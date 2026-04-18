import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/logger.dart';
import 'thing_table.dart';

class AppDatabase {
  AppDatabase({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = path.join(
      documentsDirectory.path,
      AppConstants.databaseName,
    );

    _logger.info('Opening database at $databasePath');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(ThingTable.createStatement);
      },
    );

    return _database!;
  }
}
