class Thing {
  const Thing({
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
  final DateTime createdAt;
  final DateTime updatedAt;

  Thing copyWith({
    String? description,
    String? imagePath,
    String? thumbnailPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Thing(
      id: id,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
