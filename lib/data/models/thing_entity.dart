import '../../data/db/thing_table.dart';
import '../../domain/models/thing.dart';

class ThingEntity {
  const ThingEntity({
    required this.id,
    required this.description,
    required this.imagePath,
    required this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String description;
  final String imagePath;
  final String thumbnailPath;
  final String createdAt;
  final String updatedAt;

  Map<String, Object?> toMap() {
    return {
      ThingTable.id: id,
      ThingTable.description: description,
      ThingTable.imagePath: imagePath,
      ThingTable.thumbnailPath: thumbnailPath,
      ThingTable.createdAt: createdAt,
      ThingTable.updatedAt: updatedAt,
    };
  }

  Thing toDomain() {
    return Thing(
      id: id,
      description: description,
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory ThingEntity.fromDomain(Thing thing) {
    return ThingEntity(
      id: thing.id,
      description: thing.description,
      imagePath: thing.imagePath,
      thumbnailPath: thing.thumbnailPath,
      createdAt: thing.createdAt.toUtc().toIso8601String(),
      updatedAt: thing.updatedAt.toUtc().toIso8601String(),
    );
  }

  factory ThingEntity.fromMap(Map<String, Object?> map) {
    return ThingEntity(
      id: map[ThingTable.id]! as String,
      description: map[ThingTable.description]! as String,
      imagePath: map[ThingTable.imagePath]! as String,
      thumbnailPath: map[ThingTable.thumbnailPath]! as String,
      createdAt: map[ThingTable.createdAt]! as String,
      updatedAt: map[ThingTable.updatedAt]! as String,
    );
  }
}
