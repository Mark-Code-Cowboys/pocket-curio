import 'package:cc_core/cc_core.dart';

/// What the camera read off one souvenir: the line most likely to be the
/// place name and every line, verbatim, for the user to pick from.
///
/// GUARDRAIL (cc_core scan): transcription only. [primary] is chosen by
/// geometry — the tallest printed line — never by guessing what a place
/// "should" be, and nothing is corrected or completed.
class PlaceReading {
  const PlaceReading({required this.primary, required this.lines});

  /// The tallest line's text, or null when nothing was read.
  final String? primary;

  /// Every distinct non-empty line, top to bottom.
  final List<String> lines;

  static const empty = PlaceReading(primary: null, lines: []);
}

/// Souvenirs print the place biggest — "KEY WEST" over a small
/// "Florida". The tallest line wins; ties go to the topmost.
PlaceReading readPlace(List<OcrLine> ocr) {
  final cleaned = [
    for (final l in ocr)
      if (l.text.trim().isNotEmpty)
        OcrLine(l.text.trim(), left: l.left, top: l.top, height: l.height),
  ];
  if (cleaned.isEmpty) return PlaceReading.empty;

  final byPosition = List.of(cleaned)..sort((a, b) => a.top.compareTo(b.top));
  final seen = <String>{};
  final lines = [
    for (final l in byPosition)
      if (seen.add(l.text.toLowerCase())) l.text,
  ];

  var tallest = byPosition.first;
  for (final l in byPosition.skip(1)) {
    if (l.height > tallest.height) tallest = l;
  }
  return PlaceReading(primary: tallest.text, lines: lines);
}
