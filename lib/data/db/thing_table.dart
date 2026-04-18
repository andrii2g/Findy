import '../../core/constants/app_constants.dart';

class ThingTable {
  const ThingTable._();

  static const tableName = AppConstants.thingsTable;
  static const id = 'id';
  static const description = 'description';
  static const imagePath = 'image_path';
  static const thumbnailPath = 'thumbnail_path';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';

  static const createStatement = '''
    CREATE TABLE $tableName (
      $id TEXT PRIMARY KEY NOT NULL,
      $description TEXT NOT NULL,
      $imagePath TEXT NOT NULL,
      $thumbnailPath TEXT NOT NULL,
      $createdAt TEXT NOT NULL,
      $updatedAt TEXT NOT NULL
    )
  ''';
}
