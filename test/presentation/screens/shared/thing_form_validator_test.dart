import 'package:findy/presentation/screens/shared/thing_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rejects blank descriptions', () {
    expect(
      ThingFormValidator.validateDescription('   '),
      'Please describe the thing first.',
    );
  });

  test('requires a photo for a new thing', () {
    expect(
      ThingFormValidator.canSave(description: 'coat'),
      isFalse,
    );
  });

  test('allows save when editing with an existing image path', () {
    expect(
      ThingFormValidator.canSave(
        description: 'coat',
        existingImagePath: '/tmp/coat.jpg',
      ),
      isTrue,
    );
  });
}
