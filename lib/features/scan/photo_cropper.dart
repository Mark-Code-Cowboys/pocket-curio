import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:path/path.dart' as p;

/// Cuts one region out of a photo. Rects are *normalized* (0–1 of the
/// image's width and height) so the drawing screen never needs pixel
/// geometry.
///
/// cc_core candidate: the guided-crop batch flow is generic capture UX
/// (docs/cc-core-gaps.md).
abstract class PhotoCropper {
  /// Pixel size of the image at [path].
  Future<Size> imageSize(String path);

  /// Writes the region [normalized] of [sourcePath] to a new transient
  /// PNG and returns its path.
  Future<String> crop(String sourcePath, Rect normalized);
}

/// Crops with the Flutter engine (decode → draw the sub-rect → encode
/// PNG). No image-processing dependency; a 2048px source crops in tens
/// of milliseconds on device.
class UiPhotoCropper implements PhotoCropper {
  const UiPhotoCropper();

  @override
  Future<Size> imageSize(String path) async {
    final image = await _decode(path);
    try {
      return Size(image.width.toDouble(), image.height.toDouble());
    } finally {
      image.dispose();
    }
  }

  @override
  Future<String> crop(String sourcePath, Rect normalized) async {
    final image = await _decode(sourcePath);
    try {
      final src = Rect.fromLTWH(
        normalized.left * image.width,
        normalized.top * image.height,
        normalized.width * image.width,
        normalized.height * image.height,
      );
      final w = src.width.round().clamp(1, image.width);
      final h = src.height.round().clamp(1, image.height);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImageRect(
        image,
        src,
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Paint(),
      );
      final out = await recorder.endRecording().toImage(w, h);
      try {
        final bytes = await out.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory(
          p.join(Directory.systemTemp.path, 'pocket_curio_crops'),
        );
        dir.createSync(recursive: true);
        final file = File(
          p.join(dir.path, '${DateTime.now().microsecondsSinceEpoch}.png'),
        );
        file.writeAsBytesSync(bytes!.buffer.asUint8List());
        return file.path;
      } finally {
        out.dispose();
      }
    } finally {
      image.dispose();
    }
  }

  Future<ui.Image> _decode(String path) async {
    final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }
}
