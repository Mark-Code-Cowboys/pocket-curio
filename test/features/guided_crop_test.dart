import 'dart:io';
import 'dart:ui' show ImageByteFormat, PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/features/scan/guided_crop_screen.dart';
import 'package:pocket_curio/features/scan/photo_cropper.dart';

/// Hosts the crop screen behind a button so the popped result is
/// observable.
class _Host extends StatefulWidget {
  const _Host({required this.imagePath, this.single = false});

  final String imagePath;
  final bool single;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  List<Rect>? result;
  var popped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            result = await Navigator.of(context).push<List<Rect>>(
              MaterialPageRoute(
                builder: (_) => GuidedCropScreen(
                  imagePath: widget.imagePath,
                  imageSize: const Size(400, 300),
                  single: widget.single,
                ),
              ),
            );
            setState(() => popped = true);
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  final canvas = find.byKey(const Key('guided-crop-canvas'));

  Future<_HostState> open(WidgetTester tester, {bool single = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _Host(imagePath: '/nonexistent/shelf.jpg', single: single),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return tester.state<_HostState>(find.byType(_Host, skipOffstage: false));
  }

  /// Drags from one normalized point to another on the image canvas.
  Future<void> drawBox(WidgetTester tester, Offset from, Offset to) async {
    final rect = tester.getRect(canvas);
    Offset at(Offset n) =>
        rect.topLeft + Offset(n.dx * rect.width, n.dy * rect.height);
    await tester.dragFrom(at(from), at(to) - at(from));
    await tester.pumpAndSettle();
  }

  testWidgets('the image fits its aspect ratio and Next waits for a box', (
    tester,
  ) async {
    await open(tester);

    final rect = tester.getRect(canvas);
    expect(rect.width / rect.height, closeTo(4 / 3, 0.01));
    expect(find.text('No boxes yet.'), findsOneWidget);
    final next = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Next'),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('dragging draws boxes; tapping one removes it', (tester) async {
    await open(tester);

    await drawBox(tester, const Offset(0.1, 0.1), const Offset(0.4, 0.5));
    await drawBox(tester, const Offset(0.6, 0.2), const Offset(0.9, 0.7));
    expect(find.text('2 boxes'), findsOneWidget);
    expect(find.text('Next · 2'), findsOneWidget);

    // Tap inside the second box.
    final rect = tester.getRect(canvas);
    await tester.tapAt(
      rect.topLeft + Offset(0.75 * rect.width, 0.45 * rect.height),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 box'), findsOneWidget);

    // A tap on empty canvas changes nothing.
    await tester.tapAt(
      rect.topLeft + Offset(0.75 * rect.width, 0.9 * rect.height),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 box'), findsOneWidget);
  });

  testWidgets('accidental slivers are ignored', (tester) async {
    await open(tester);

    await drawBox(tester, const Offset(0.5, 0.5), const Offset(0.51, 0.52));
    expect(find.text('No boxes yet.'), findsOneWidget);
  });

  testWidgets('Next returns the boxes as normalized rects', (tester) async {
    final host = await open(tester);

    await drawBox(tester, const Offset(0.1, 0.1), const Offset(0.4, 0.5));
    await tester.tap(find.text('Next · 1'));
    await tester.pumpAndSettle();

    expect(host.popped, isTrue);
    final box = host.result!.single;
    expect(box.left, closeTo(0.1, 0.02));
    expect(box.top, closeTo(0.1, 0.02));
    expect(box.right, closeTo(0.4, 0.02));
    expect(box.bottom, closeTo(0.5, 0.02));
  });

  testWidgets('backing out returns null', (tester) async {
    final host = await open(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(host.popped, isTrue);
    expect(host.result, isNull);
  });

  testWidgets('UiPhotoCropper cuts the requested region of a real image', (
    tester,
  ) async {
    await tester.runAsync(() async {
      // A 40×20 image, painted by the engine, saved as PNG.
      final recorder = PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 40, 20),
        Paint()..color = const Color(0xFF336699),
      );
      final image = await recorder.endRecording().toImage(40, 20);
      final png = await image.toByteData(format: ImageByteFormat.png);
      final dir = Directory.systemTemp.createTempSync(
        'pocket_curio_cropper_ut_',
      );
      addTearDown(() => dir.deleteSync(recursive: true));
      final source = File('${dir.path}/shelf.png')
        ..writeAsBytesSync(png!.buffer.asUint8List());

      const cropper = UiPhotoCropper();
      expect(await cropper.imageSize(source.path), const Size(40, 20));

      final out = await cropper.crop(
        source.path,
        const Rect.fromLTWH(0.5, 0.0, 0.5, 0.5),
      );
      addTearDown(() => File(out).deleteSync());
      expect(await cropper.imageSize(out), const Size(20, 10));
    });
  });

  testWidgets('single mode: one box, redrawing replaces it, Crop returns it', (
    tester,
  ) async {
    final host = await open(tester, single: true);

    expect(find.text('Crop the photo'), findsOneWidget);
    expect(find.text('No crop yet.'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Crop'))
          .onPressed,
      isNull,
    );

    await drawBox(tester, const Offset(0.1, 0.1), const Offset(0.5, 0.5));
    await drawBox(tester, const Offset(0.6, 0.2), const Offset(0.9, 0.7));
    expect(find.text('Crop set.'), findsOneWidget);

    await tester.tap(find.text('Crop'));
    await tester.pumpAndSettle();
    final box = host.result!.single;
    expect(box.left, closeTo(0.6, 0.02), reason: 'the second drag replaced');
    expect(box.right, closeTo(0.9, 0.02));
  });
}
