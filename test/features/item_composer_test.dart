import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/photos/photo_capture.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';
import 'package:pocket_curio/features/collections/collection_screen.dart';
import 'package:pocket_curio/features/items/item_composer_screen.dart';
import 'package:pocket_curio/features/items/item_detail_screen.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late int collectionId;

  setUp(() async {
    db = makeTestDb();
    collectionId = await CollectionRepository(db).createCollection(
      collectionDraft(name: 'Keychains', kind: CollectionKind.keychain),
    );
  });

  tearDown(() => db.close());

  testWidgets('two-field path: camera opens on arrival, place, save', (
    tester,
  ) async {
    final store = makeTestStore();
    final capture = FakeCapture();

    await tester.pumpWidget(
      testApp(
        db: db,
        store: store,
        capture: capture,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    // Camera-first: the picker was invoked without a tap.
    expect(capture.sources, [PhotoSource.camera]);
    expect(find.text('Retake'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .focusNode
          .hasFocus,
      isTrue,
      reason: 'place field takes focus after the shot',
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Place'),
      'Mackinac Island',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the shelf with the new tile.
    expect(find.text('Mackinac Island'), findsOneWidget);
    final items = (await tester.runAsync(
      () => ItemRepository(db).watchItemsForCollection(collectionId).first,
    ))!;
    expect(items.single.place, 'Mackinac Island');
    expect(items.single.photoPath, startsWith('photos/'));
    expect(store.resolve(items.single.photoPath).existsSync(), isTrue);
    expect(items.single.journalEntryId, isNull);
    await disposeApp(tester);
  });

  testWidgets('backing out of the camera leaves the photo buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        capture: FakeCapture(cancel: true),
        home: ItemComposerScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The photo is the record.'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from library'), findsOneWidget);

    // Saving without a photo is refused, kindly.
    await tester.enterText(find.widgetWithText(TextField, 'Place'), 'Boston');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(
      find.text('Take a photo first — that’s the record.'),
      findsOneWidget,
    );
    expect(await tester.runAsync(() => ItemRepository(db).count()), 0);

    await tester.pump(const Duration(seconds: 5));
    await disposeApp(tester);
  });

  testWidgets('abandoning a new item deletes the imported photo', (
    tester,
  ) async {
    final store = makeTestStore();

    await tester.pumpWidget(
      testApp(
        db: db,
        store: store,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    final photosDir = Directory(store.resolve('photos').path);
    expect(photosDir.listSync(), hasLength(1));

    // Fullscreen dialogs close with an X, not a back arrow.
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(photosDir.listSync(), isEmpty);
    expect(await tester.runAsync(() => ItemRepository(db).count()), 0);
    await disposeApp(tester);
  });

  testWidgets('the memory fields save and show on the detail screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Place'),
      'Niagara Falls',
    );
    await tester.tap(find.text('Add the memory'));
    await tester.pumpAndSettle();

    // The memory fields sit below the fold; scroll each into view first.
    Future<void> enterField(String label, String text) async {
      final field = find.widgetWithText(TextField, label);
      await tester.scrollUntilVisible(
        field,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(field, text);
    }

    await enterField('State', 'ON');
    await enterField('Country', 'CA');
    await enterField('Trip or occasion', 'Honeymoon');
    await enterField('Who gave it to you?', 'Mom');
    // Third star.
    await tester.scrollUntilVisible(
      find.byIcon(Icons.star_border).first,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(Icons.star_border).at(2));
    await tester.pump();
    await enterField('The memory', 'Soaked on the boat.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final item =
        (await db.select(db.items).get()).single;
    expect(item.state, 'ON');
    expect(item.country, 'CA');
    expect(item.tripOrOccasion, 'Honeymoon');
    expect(item.whoGaveIt, 'Mom');
    final entry = (await db.select(db.appJournalEntries).get()).single;
    expect(entry.notes, 'Soaked on the boat.');
    expect(entry.rating, 3);
    expect(item.city, isNull);

    // Back on the shelf; the new tile opens the memory.
    await tester.tap(find.text('Niagara Falls'));
    await tester.pumpAndSettle();
    expect(find.text('Niagara Falls'), findsOneWidget);
    expect(find.text('ON, CA'), findsOneWidget);
    expect(find.text('Honeymoon'), findsOneWidget);
    expect(find.text('Mom'), findsOneWidget);
    expect(find.text('Soaked on the boat.'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(3));
    await disposeApp(tester);
  });

  testWidgets('editing keeps the photo and rewrites the place', (tester) async {
    final store = makeTestStore();
    final shot = (await FakeCapture().capture(PhotoSource.camera))!;
    final rel = await store.import(shot);
    final id = await ItemRepository(
      db,
    ).createItem(collectionId, itemDraft(photoPath: rel, place: 'Boston'));

    await tester.pumpWidget(
      testApp(
        db: db,
        store: store,
        home: ItemDetailScreen(itemId: id),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit souvenir'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget, reason: 'photo carried over');
    await tester.enterText(
      find.widgetWithText(TextField, 'Place'),
      'Boston Harbor',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final item = (await tester.runAsync(
      () => ItemRepository(db).watchItem(id).first,
    ))!;
    expect(item.place, 'Boston Harbor');
    expect(item.photoPath, rel);
    expect(store.resolve(rel).existsSync(), isTrue);
    await disposeApp(tester);
  });

  testWidgets('removing an item deletes its photo and clears a cover', (
    tester,
  ) async {
    final store = makeTestStore();
    final shot = (await FakeCapture().capture(PhotoSource.camera))!;
    final rel = await store.import(shot);
    final items = ItemRepository(db);
    final collections = CollectionRepository(db);
    final id = await items.createItem(collectionId, itemDraft(photoPath: rel));
    await collections.setCoverPhoto(collectionId, rel);

    await tester.pumpWidget(
      testApp(
        db: db,
        store: store,
        home: ItemDetailScreen(itemId: id),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(await tester.runAsync(items.count), 0);
    expect(store.resolve(rel).existsSync(), isFalse);
    final collection = (await tester.runAsync(
      () => collections.watchCollection(collectionId).first,
    ))!;
    expect(collection.coverPhotoPath, isNull);
    await disposeApp(tester);
  });
}
