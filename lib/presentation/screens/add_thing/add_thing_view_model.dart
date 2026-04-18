import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger.dart';
import '../../../domain/usecases/add_thing_usecase.dart';
import '../shared/thing_form_validator.dart';

enum ThingFormStatus { idle, saving, success, error }

class AddThingViewModel extends ChangeNotifier {
  AddThingViewModel({
    required AddThingUseCase addThingUseCase,
    required AppLogger logger,
    ImagePicker? imagePicker,
  })  : _addThingUseCase = addThingUseCase,
        _logger = logger,
        _imagePicker = imagePicker ?? ImagePicker();

  final AddThingUseCase _addThingUseCase;
  final AppLogger _logger;
  final ImagePicker _imagePicker;

  ThingFormStatus status = ThingFormStatus.idle;
  String description = '';
  XFile? selectedPhoto;
  String? errorMessage;

  bool get canSave => ThingFormValidator.canSave(
        description: description,
        selectedPhoto: selectedPhoto,
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

  Future<bool> save() async {
    final descriptionError = ThingFormValidator.validateDescription(description);
    final photoError = ThingFormValidator.validatePhoto(selectedPhoto: selectedPhoto);

    if (descriptionError != null || photoError != null) {
      errorMessage = descriptionError ?? photoError;
      status = ThingFormStatus.error;
      notifyListeners();
      return false;
    }

    status = ThingFormStatus.saving;
    errorMessage = null;
    notifyListeners();

    try {
      await _addThingUseCase(
        description: description,
        photo: selectedPhoto!,
      );
      status = ThingFormStatus.success;
      notifyListeners();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (error, stackTrace) {
      _logger.error('Unexpected add failure', error, stackTrace);
      errorMessage = 'Could not save this thing.';
    }

    status = ThingFormStatus.error;
    notifyListeners();
    return false;
  }
}
