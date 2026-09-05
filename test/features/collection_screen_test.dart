import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/photos/photo_capture.dart';
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
    collectionId = await CollectionRepository(db).createCollection(
      collectionDraft(name: 'Keychains', kind: CollectionKind.keychain),
    );
  });

  tearDown(() => db.close());

  testWidgets('empty shelf is written for the gift recipient', (tester) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keychains'), findsOneWidget);
    expect(find.text('Photograph your first keychain.'), findsOneWidget);
    expect(find.textContaining('the memory can come later'), findsOneWidget);
    expect(find.text('Add keychain'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('shelf shows place labels and re-sorts by place', (tester) async {
    final items = ItemRepository(db);
    await items.createItem(
      collectionId,
      itemDraft(place: 'Zion', dateAcquired: DateTime(2026, 1, 1)),
    );
    await items.createItem(
      collectionId,
      itemDraft(place: 'Acadia', dateAcquired: DateTime(2020, 1, 1)),
    );

    await tester.pumpWidget(
      testApp(
        db: db,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();

    List<String> order() {
      final zion = tester.getTopLeft(find.text('Zion'));
      final acadia = tester.getTopLeft(find.text('Acadia'));
      return zion.dx < acadia.dx ? ['Zion', 'Acadia'] : ['Acadia', 'Zion'];
    }

    expect(order(), ['Zion', 'Acadia'], reason: 'newest acquired first');

    await tester.tap(find.text('Place'));
    await tester.pumpAndSettle();
    expect(order(), ['Acadia', 'Zion']);
    await disposeApp(tester);
  });

  testWidgets('tapping a tile opens the item detail', (tester) async {
    await ItemRepository(db).createItem(
      collectionId,
      itemDraft(
        place: 'Key West',
        city: 'Key West',
        state: 'FL',
        whoGaveIt: 'Aunt Jo',
        notes: 'Southernmost point, sunburn included.',
        rating: 4,
      ),
    );

    await tester.pumpWidget(
      testApp(
        db: db,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Key West'));
    await tester.pumpAndSettle();

    expect(find.text('Key West, FL, US'), findsOneWidget);
    expect(find.text('Aunt Jo'), findsOneWidget);
    expect(find.text('Southernmost point, sunburn included.'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(4));
    await disposeApp(tester);
  });

  testWidgets('deleting the collection removes it and its photo files', (
    tester,
  ) async {
    final store = makeTestStore();
    final shot = (await FakeCapture().capture(PhotoSource.camera))!;
    final rel = await store.import(shot);
    await ItemRepository(
      db,
    ).createItem(collectionId, itemDraft(photoPath: rel));
    expect(store.resolve(rel).existsSync(), isTrue);

    await tester.pumpWidget(
      testApp(
        db: db,
        store: store,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(await tester.runAsync(() => CollectionRepository(db).count()), 0);
    expect(store.resolve(rel).existsSync(), isFalse);
    await disposeApp(tester);
  });
}
