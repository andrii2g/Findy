import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger.dart';
import '../../../domain/models/thing.dart';
import '../../../domain/usecases/update_thing_usecase.dart';
import '../add_thing/add_thing_view_model.dart';
import '../shared/thing_form_validator.dart';

class EditThingViewModel extends ChangeNotifier {
  EditThingViewModel({
    required Thing thing,
    required UpdateThingUseCase updateThingUseCase,
    required AppLogger logger,
    ImagePicker? imagePicker,
  })  : _thing = thing,
        _updateThingUseCase = updateThingUseCase,
        _logger = logger,
        _imagePicker = imagePicker ?? ImagePicker(),
        description = thing.description;

  final Thing _thing;
  final UpdateThingUseCase _updateThingUseCase;
  final AppLogger _logger;
  final ImagePicker _imagePicker;

  String description;
  XFile? selectedPhoto;
  String? errorMessage;
  ThingFormStatus status = ThingFormStatus.idle;

  String get existingImagePath => _thing.imagePath;

  bool get canSave => ThingFormValidator.canSave(
        description: description,
        selectedPhoto: selectedPhoto,
        existingImagePath: _thing.imagePath,
      );

  void updateDescription(String value) {
    description = value;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> takePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null) {
        errorMessage = 'Camera capture was canceled.';
      } else {
        selectedPhoto = photo;
        errorMessage = null;
      }
    } catch (error, stackTrace) {
      _logger.error('Camera capture failed', error, stackTrace);
      errorMessage = 'Could not take the location photo.';
    }

    notifyListeners();
  }

  Future<Thing?> save() async {
    final descriptionError = ThingFormValidator.validateDescription(description);
    final photoError = ThingFormValidator.validatePhoto(
      selectedPhoto: selectedPhoto,
      existingImagePath: _thing.imagePath,
    );

    if (descriptionError != null || photoError != null) {
      errorMessage = descriptionError ?? photoError;
      status = ThingFormStatus.error;
      notifyListeners();
      return null;
    }

    status = ThingFormStatus.saving;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedThing = await _updateThingUseCase(
        existingThing: _thing,
        description: description,
        replacementPhoto: selectedPhoto,
      );
      status = ThingFormStatus.success;
      notifyListeners();
      return updatedThing;
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (error, stackTrace) {
      _logger.error('Unexpected edit failure', error, stackTrace);
      errorMessage = 'Could not update this thing.';
    }

    status = ThingFormStatus.error;
    notifyListeners();
    return null;
  }
}
