import 'package:image_picker/image_picker.dart';

class ThingFormValidator {
  const ThingFormValidator._();

  static String? validateDescription(String description) {
    if (description.trim().isEmpty) {
      return 'Please describe the thing first.';
    }

    return null;
  }

  static String? validatePhoto({
    XFile? selectedPhoto,
    String? existingImagePath,
  }) {
    final hasPhoto = selectedPhoto != null || (existingImagePath?.isNotEmpty ?? false);
    if (!hasPhoto) {
      return 'Please take a location photo.';
    }

    return null;
  }

  static bool canSave({
    required String description,
    XFile? selectedPhoto,
    String? existingImagePath,
  }) {
    return validateDescription(description) == null &&
        validatePhoto(
              selectedPhoto: selectedPhoto,
              existingImagePath: existingImagePath,
            ) ==
            null;
  }
}
