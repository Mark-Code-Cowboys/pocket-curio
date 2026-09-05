import 'package:cc_core/cc_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'photo_cropper.dart';

/// Overridden in main() with the ML Kit recognizer (on-device, bundled
/// Latin model, no network), and in tests with cc_core's
/// [FakeTextRecognitionService].
final textRecognitionServiceProvider = Provider<TextRecognitionService>(
  (ref) => throw UnimplementedError(
    'textRecognitionServiceProvider must be overridden',
  ),
);

/// Crops the shelf photo into one file per drawn box. Tests inject a fake.
final photoCropperProvider = Provider<PhotoCropper>(
  (ref) => const UiPhotoCropper(),
);
