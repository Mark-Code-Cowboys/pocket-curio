import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/utils/labels.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = makeTestDb());
  tearDown(() => db.close());

  testWidgets('empty home invites the first collection', (tester) async {
    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();

    expect(find.text('A souvenir is a place + a memory.'), findsOneWidget);
    expect(find.textContaining('Start a collection'), findsOneWidget);
    expect(find.text('New collection'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('seeded home shows headline, free-tier chips, and tiles', (
    tester,
  ) async {
    final collections = CollectionRepository(db);
    final items = ItemRepository(db);
    final magnets = await collections.createCollection(
      collectionDraft(name: 'Fridge magnets'),
    );
    await collections.createCollection(
      collectionDraft(name: 'Keychains', kind: CollectionKind.keychain),
    );
    await items.createItem(magnets, itemDraft(place: 'Key West'));
    await items.createItem(magnets, itemDraft(place: 'Sedona'));

    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();

    expect(find.text('2 items · 2 collections'), findsOneWidget);
    expect(find.text('2 of 1 free collections used'), findsOneWidget);
    expect(find.text('2 of 25 free items used'), findsOneWidget);
    expect(find.text('Fridge magnets'), findsOneWidget);
    expect(find.text('2 magnets'), findsOneWidget);
    expect(find.text('Keychains'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('tapping a tile opens the shelf', (tester) async {
    await CollectionRepository(
      db,
    ).createCollection(collectionDraft(name: 'Fridge magnets'));

    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fridge magnets'));
    await tester.pumpAndSettle();

    expect(find.text('Photograph your first magnet.'), findsOneWidget);
    expect(find.text('Add magnet'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('New collection composer creates a shelf with a custom kind', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Collection name'),
      'Snow globes',
    );
    await tester.tap(find.text('Something else'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'What is one called?'),
      'snow globe',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Snow globes'), findsOneWidget);
    final stored = (await tester.runAsync(
      () => CollectionRepository(db).watchCollections().first,
    ))!;
    expect(stored.single.kind, CollectionKind.other);
    expect(stored.single.otherLabel, 'snow globe');
    await disposeApp(tester);
  });

  test('countHeadline handles singulars', () {
    expect(countHeadline(items: 1, collections: 1), '1 item · 1 collection');
    expect(countHeadline(items: 0, collections: 2), '0 items · 2 collections');
  });

  test('itemNoun prefers the custom label on an other shelf', () {
    Collection c(CollectionKind kind, String? other) => Collection(
      id: 1,
      name: 'x',
      kind: kind,
      otherLabel: other,
      createdAt: DateTime(2026),
    );
    expect(c(CollectionKind.shotGlass, null).itemNoun, 'shot glass');
    expect(c(CollectionKind.other, 'Snow Globe').itemNoun, 'snow globe');
    expect(c(CollectionKind.other, null).itemNoun, 'souvenir');
    expect(c(CollectionKind.pin, 'ignored').itemNoun, 'pin');
  });
}
