import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'photo_capture.dart';
import 'photo_store.dart';

/// Overridden in main() with the on-device store, and in tests with a
/// temp directory.
final photoStoreProvider = Provider<PhotoStore>(
  (ref) => throw UnimplementedError('photoStoreProvider must be overridden'),
);

/// Real camera/library picker; tests override with a fake.
final photoCaptureProvider = Provider<PhotoCapture>(
  (ref) => ImagePickerCapture(),
);
