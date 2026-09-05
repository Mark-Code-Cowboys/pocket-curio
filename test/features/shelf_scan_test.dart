import 'dart:io';

import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';
import 'package:pocket_curio/features/collections/collection_screen.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late int collectionId;

  setUp(() async {
    db = makeTestDb();
    collectionId = await CollectionRepository(
      db,
    ).createCollection(collectionDraft(name: 'Fridge magnets'));
  });

  tearDown(() => db.close());

  OcrLine line(String text, {double top = 0, double height = 20}) =>
      OcrLine(text, left: 0, top: top, height: height);

  final canvas = find.byKey(const Key('guided-crop-canvas'));

  Future<void> drawBox(WidgetTester tester, Offset from, Offset to) async {
    final rect = tester.getRect(canvas);
    Offset at(Offset n) =>
        rect.topLeft + Offset(n.dx * rect.width, n.dy * rect.height);
    await tester.dragFrom(at(from), at(to) - at(from));
    await tester.pumpAndSettle();
  }

  /// Opens the shelf, starts the scan from the empty state, and draws
  /// [boxes] on the crop screen.
  Future<void> scanWithBoxes(WidgetTester tester, int boxes) async {
    await tester.tap(find.text('Already have a shelf full? Scan it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a photo of the shelf'));
    await tester.pumpAndSettle();
    expect(find.text('Box each souvenir'), findsOneWidget);
    for (var i = 0; i < boxes; i++) {
      final x = 0.05 + i * 0.3;
      await drawBox(tester, Offset(x, 0.1), Offset(x + 0.25, 0.6));
    }
    await tester.tap(find.text('Next · $boxes'));
    await tester.pumpAndSettle();
  }

  testWidgets('shelf scan: box, read, review, edit one, drop one, add', (
    tester,
  ) async {
    final store = makeTestStore();
    final cropper = FakeCropper();
    final recognizer = FakeTextRecognitionService(
      linesByPath: {
        cropper.pathFor(0): [
          line('KEY WEST', top: 10, height: 40),
          line('Florida', top: 60),
        ],
        cropper.pathFor(1): [line('SEDONA', top: 10, height: 40)],
        cropper.pathFor(2): const [],
      },
    );

    await tester.pumpWidget(
      testApp(
        db: db,
        store: store,
        cropper: cropper,
        recognizer: recognizer,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await scanWithBoxes(tester, 3);

    // Review grid shows the transcriptions verbatim; the blank one asks.
    expect(find.text('Check what was read'), findsOneWidget);
    expect(
      find.text(
        '3 souvenirs read from the photo. Check the spelling; '
        'the camera reads exactly what’s printed.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'KEY WEST'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'SEDONA'), findsOneWidget);
    expect(find.text('Florida'), findsOneWidget, reason: 'alternative chip');
    expect(find.text('Needs a place'), findsOneWidget);
    FilledButton button() =>
        tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button().onPressed, isNull, reason: 'blank place blocks confirm');

    // Drop the blank one; use the chip on the first; confirm.
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pumpAndSettle();
    expect(find.text('Add 2 to the shelf'), findsOneWidget);
    await tester.tap(find.text('Florida'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Florida'), findsOneWidget);
    await tester.tap(find.text('Add 2 to the shelf'));
    await tester.pumpAndSettle();

    // Back on the shelf with two tiles and the snackbar.
    expect(find.text('Added 2 souvenirs to the shelf.'), findsOneWidget);
    final items = (await tester.runAsync(
      () => ItemRepository(db).watchItemsForCollection(collectionId).first,
    ))!;
    expect(items.map((i) => i.place).toSet(), {'Florida', 'SEDONA'});
    for (final item in items) {
      expect(store.resolve(item.photoPath).existsSync(), isTrue);
    }
    // The dropped crop's stored file is gone; only two remain.
    final photosDir = Directory(store.resolve('photos').path);
    expect(photosDir.listSync(), hasLength(2));
    expect(cropper.rects, hasLength(3));
    expect(recognizer.recognizedPaths, hasLength(3));

    await tester.pump(const Duration(seconds: 5));
    await disposeApp(tester);
  });

  testWidgets('backing out of review saves nothing and leaves no files', (
    tester,
  ) async {
    final store = makeTestStore();

    await tester.pumpWidget(
      testApp(
        db: db,
        store: store,
        recognizer: FakeTextRecognitionService(
          fallback: [line('SOMEWHERE', height: 30)],
        ),
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await scanWithBoxes(tester, 2);
    expect(find.widgetWithText(TextField, 'SOMEWHERE'), findsNWidgets(2));

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(await tester.runAsync(() => ItemRepository(db).count()), 0);
    expect(Directory(store.resolve('photos').path).listSync(), isEmpty);
    await disposeApp(tester);
  });

  testWidgets('a batch that would pass the free cap opens the paywall', (
    tester,
  ) async {
    final items = ItemRepository(db);
    for (var i = 0; i < 24; i++) {
      await items.createItem(
        collectionId,
        itemDraft(place: 'P$i', photoPath: 'p$i.jpg'),
      );
    }

    await tester.pumpWidget(
      testApp(
        db: db,
        recognizer: FakeTextRecognitionService(
          fallback: [line('SOMEWHERE', height: 30)],
        ),
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    // Not the empty state now; use the app bar action.
    await tester.tap(find.byTooltip('Scan the whole shelf'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a photo of the shelf'));
    await tester.pumpAndSettle();
    await drawBox(tester, const Offset(0.05, 0.1), const Offset(0.3, 0.6));
    await drawBox(tester, const Offset(0.35, 0.1), const Offset(0.6, 0.6));
    await tester.tap(find.text('Next · 2'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add 2 to the shelf'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsOneWidget);
    expect(
      find.text('24 of 25 free items used — 2 more won’t fit'),
      findsOneWidget,
    );
    expect(await tester.runAsync(items.count), 24);

    // Buying continues the add.
    await tester.ensureVisible(find.text(r'Yours forever · $6.99'));
    await tester.tap(find.text(r'Yours forever · $6.99'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(items.count), 26);
    await tester.pump(const Duration(seconds: 5));
    await disposeApp(tester);
  });

  testWidgets('cancelling the shelf photo goes nowhere', (tester) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        capture: FakeCapture(cancel: true),
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Scan the whole shelf'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();

    expect(find.text('Box each souvenir'), findsNothing);
    expect(find.text('Fridge magnets'), findsOneWidget);
    await disposeApp(tester);
  });
}
