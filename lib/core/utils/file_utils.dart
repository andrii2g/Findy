String buildOriginalImageFileName({
  required String thingId,
  String? versionToken,
}) {
  final suffix = versionToken == null || versionToken.isEmpty
      ? ''
      : '_$versionToken';
  return '$thingId$suffix.jpg';
}

String buildThumbnailFileName({
  required String thingId,
  String? versionToken,
}) {
  final suffix = versionToken == null || versionToken.isEmpty
      ? ''
      : '_$versionToken';
  return '$thingId${suffix}_thumb.jpg';
}
