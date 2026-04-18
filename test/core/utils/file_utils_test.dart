import 'package:findy/core/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds deterministic original image file name without version token', () {
    expect(
      buildOriginalImageFileName(thingId: 'abc'),
      'abc.jpg',
    );
  });

  test('builds versioned thumbnail file name with token', () {
    expect(
      buildThumbnailFileName(thingId: 'abc', versionToken: '123'),
      'abc_123_thumb.jpg',
    );
  });
}
