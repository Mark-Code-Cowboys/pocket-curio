import 'dart:async';

import 'package:cc_core/cc_core.dart' hide PhotoSource;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/photos/photo_capture.dart';
import '../../core/photos/photo_providers.dart';
import 'guided_crop_screen.dart';
import 'place_reader.dart';
import 'scan_providers.dart';
import 'shelf_review_screen.dart';

/// THE converter: one photo of the whole fridge or shelf → the user
/// boxes each souvenir → each box becomes its own photo, read for a
/// place name → review grid → bulk insert. Returns how many were added
/// (0 when the user backed out anywhere along the way).
Future<int> runShelfScan(
  BuildContext context,
  WidgetRef ref, {
  required int collectionId,
  required PhotoSource source,
}) async {
  final capture = ref.read(photoCaptureProvider);
  final cropper = ref.read(photoCropperProvider);
  final store = ref.read(photoStoreProvider);
  final recognizer = ref.read(textRecognitionServiceProvider);

  final shot = await capture.capture(source);
  if (shot == null || !context.mounted) return 0;

  final size = await cropper.imageSize(shot);
  if (!context.mounted) return 0;
  final boxes = await Navigator.of(context).push<List<Rect>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => GuidedCropScreen(imagePath: shot, imageSize: size),
    ),
  );
  if (boxes == null || boxes.isEmpty || !context.mounted) return 0;

  // Crop, read, and store each box behind a small progress dialog — OCR
  // takes a beat per crop on device.
  final candidates = <ShelfCandidate>[];
  var unreadable = 0;
  final progress = _showProgress(context, boxes.length);
  try {
    for (final box in boxes) {
      final cropPath = await cropper.crop(shot, box);
      List<OcrLine> lines;
      try {
        lines = await recognizer.recognize(cropPath);
      } on Exception {
        lines = const [];
        unreadable++;
      }
      final reading = readPlace(lines);
      candidates.add(
        ShelfCandidate(
          photoPath: await store.import(cropPath),
          place: reading.primary ?? '',
          readLines: reading.lines,
        ),
      );
    }
  } finally {
    await progress;
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
  if (!context.mounted) {
    for (final c in candidates) {
      await store.delete(c.photoPath);
    }
    return 0;
  }

  final added = await Navigator.of(context).push<int>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ShelfReviewScreen(
        collectionId: collectionId,
        candidates: candidates,
        unreadableCount: unreadable,
      ),
    ),
  );

  // Whatever wasn't saved leaves no file behind.
  for (final c in candidates) {
    if (added == null || !c.kept) await store.delete(c.photoPath);
  }
  return added ?? 0;
}

/// Non-dismissible progress dialog; resolves once it is on screen so the
/// caller can safely pop it later.
Future<void> _showProgress(BuildContext context, int count) {
  final shown = Completer<void>();
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) {
      if (!shown.isCompleted) shown.complete();
      return PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Reading $count ${count == 1 ? 'souvenir' : 'souvenirs'}…',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return shown.future;
}
