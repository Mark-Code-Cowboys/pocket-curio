import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';
import 'package:pocket_curio/features/collections/collection_screen.dart';

import '../helpers.dart';

/// Restore that actually finds a purchase, for the restore-path test.
class _RestoringFake extends FakeEntitlementService {
  @override
  Future<void> restorePurchases() => buyUnlimited();
}

void main() {
  late AppDatabase db;

  setUp(() => db = makeTestDb());
  tearDown(() => db.close());

  Future<int> seedShelf({int items = 0}) async {
    final id = await CollectionRepository(db).createCollection(
      collectionDraft(name: 'Keychains', kind: CollectionKind.keychain),
    );
    final repo = ItemRepository(db);
    for (var i = 0; i < items; i++) {
      await repo.createItem(
        id,
        itemDraft(place: 'Place $i', photoPath: 'p$i.jpg'),
      );
    }
    return id;
  }

  testWidgets('one free collection: New collection opens the paywall', (
    tester,
  ) async {
    await seedShelf(items: 3);

    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 free collections used'), findsOneWidget);
    expect(find.text('3 of 25 free items used'), findsOneWidget);
    expect(
      find.text('Room for 22 more — then Pocket Curio Pro.'),
      findsOneWidget,
    );

    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsOneWidget);
    // The sheet restates the reason it opened.
    expect(find.text('1 of 1 free collections used'), findsNWidgets(2));
    expect(find.text('One-time. Makes a good gift.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Collection name'), findsNothing);

    await tester.ensureVisible(find.text('Maybe later'));
    await tester.tap(find.text('Maybe later'));
    await tester.pumpAndSettle();
    expect(find.text('Pocket Curio Pro'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Collection name'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('with no collections, New collection goes to the composer', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Collection name'),
      findsOneWidget,
    );
    await disposeApp(tester);
  });

  testWidgets('at 25 items, Add opens the paywall, not the camera', (
    tester,
  ) async {
    final id = await seedShelf(items: 25);
    final capture = FakeCapture();

    await tester.pumpWidget(
      testApp(
        db: db,
        capture: capture,
        home: CollectionScreen(collectionId: id),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsOneWidget);
    expect(find.text('25 of 25 free items used'), findsOneWidget);
    expect(capture.sources, isEmpty, reason: 'camera never opened');
    expect(find.text('New souvenir'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('under 25 items, Add goes straight to the camera', (
    tester,
  ) async {
    final id = await seedShelf(items: 24);
    final capture = FakeCapture();

    await tester.pumpWidget(
      testApp(
        db: db,
        capture: capture,
        home: CollectionScreen(collectionId: id),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsNothing);
    expect(find.text('New souvenir'), findsOneWidget);
    expect(capture.sources, hasLength(1));
    await disposeApp(tester);
  });

  testWidgets('buying lifetime Pro mid-gate continues into the composer', (
    tester,
  ) async {
    await seedShelf();

    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(r'Yours forever · $6.99'));
    await tester.tap(find.text(r'Yours forever · $6.99'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Collection name'),
      findsOneWidget,
    );

    // Leave the composer: the counter is gone for the new Pro owner.
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('free collections used'), findsNothing);
    expect(find.textContaining('free items used'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('monthly is offered as the secondary path', (tester) async {
    await seedShelf();

    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(r'Or month to month · $12.99'));
    await tester.tap(find.text(r'Or month to month · $12.99'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Collection name'),
      findsOneWidget,
    );
    await disposeApp(tester);
  });

  testWidgets('restore purchase unlocks from the sheet', (tester) async {
    await seedShelf();

    await tester.pumpWidget(testApp(db: db, entitlements: _RestoringFake()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Restore purchase'));
    await tester.tap(find.text('Restore purchase'));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio Pro'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Collection name'),
      findsOneWidget,
    );
    await disposeApp(tester);
  });

  testWidgets('Pro owners see no counter and no gate', (tester) async {
    await seedShelf(items: 30);
    await CollectionRepository(
      db,
    ).createCollection(collectionDraft(name: 'Magnets'));

    await tester.pumpWidget(
      testApp(db: db, entitlements: FakeEntitlementService(unlimited: true)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('free collections used'), findsNothing);
    expect(find.textContaining('free items used'), findsNothing);
    expect(find.text('30 items · 2 collections'), findsOneWidget);

    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();
    expect(find.text('Pocket Curio Pro'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Collection name'),
      findsOneWidget,
    );
    await disposeApp(tester);
  });

  testWidgets('tapping the counter opens the paywall directly', (tester) async {
    await seedShelf(items: 2);

    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Go Pro'));
    await tester.pumpAndSettle();
    expect(find.text('Pocket Curio Pro'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('deleting a collection does not refund the free slot', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();

    // Create the free collection through the app so the tally records it.
    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Collection name'),
      'Keychains',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 free collections used'), findsOneWidget);

    // Delete it from the shelf screen.
    await tester.tap(find.text('Keychains'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    // Back home, empty, but the slot stays spent.
    expect(find.text('A souvenir is a place + a memory.'), findsOneWidget);
    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();
    expect(find.text('Pocket Curio Pro'), findsOneWidget);
    await disposeApp(tester);
  });
}
