import 'package:cc_core/cc_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/features/scan/place_reader.dart';

void main() {
  OcrLine line(String text, {double top = 0, double height = 20}) =>
      OcrLine(text, left: 0, top: top, height: height);

  test('the tallest line is the place; every line is offered, in order', () {
    final reading = readPlace([
      line('Florida', top: 80, height: 14),
      line('KEY WEST', top: 20, height: 48),
      line('Southernmost Point', top: 120, height: 12),
    ]);
    expect(reading.primary, 'KEY WEST');
    expect(reading.lines, ['KEY WEST', 'Florida', 'Southernmost Point']);
  });

  test('ties on height go to the topmost line', () {
    final reading = readPlace([
      line('Second', top: 50, height: 30),
      line('First', top: 10, height: 30),
    ]);
    expect(reading.primary, 'First');
  });

  test('blank lines are dropped and duplicates collapse', () {
    final reading = readPlace([
      line('   ', top: 0),
      line('Sedona', top: 10, height: 30),
      line('SEDONA', top: 40, height: 10),
      line('Arizona', top: 60),
    ]);
    expect(reading.primary, 'Sedona');
    expect(reading.lines, ['Sedona', 'Arizona']);
  });

  test('nothing read means no prefill', () {
    expect(readPlace(const []).primary, isNull);
    expect(readPlace([line(' ')]).lines, isEmpty);
  });

  test('text is verbatim — never trimmed beyond whitespace or corrected', () {
    final reading = readPlace([line('  NIAGRA FALLS  ', height: 40)]);
    expect(reading.primary, 'NIAGRA FALLS');
  });
}
