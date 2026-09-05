import 'package:cc_core/cc_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late CollectionRepository repo;

  setUp(() {
    db = makeTestDb();
    repo = CollectionRepository(db);
  });

  tearDown(() => db.close());

  test(
    'createCollection stores fields and count feeds the free limit',
    () async {
      await repo.createCollection(collectionDraft(name: 'Fridge magnets'));
      await repo.createCollection(
        collectionDraft(name: 'Keychains', kind: CollectionKind.keychain),
      );

      expect(await repo.count(), 2);
      final all = await repo.watchCollections().first;
      final magnets = all.singleWhere((c) => c.name == 'Fridge magnets');
      expect(magnets.kind, CollectionKind.magnet);
      expect(magnets.otherLabel, isNull);
      expect(magnets.coverPhotoPath, isNull);
    },
  );

  test('watchCollections orders A-Z, case-insensitively', () async {
    await repo.createCollection(collectionDraft(name: 'shot glasses'));
    await repo.createCollection(collectionDraft(name: 'Keychains'));
    await repo.createCollection(collectionDraft(name: 'Postcards'));

    final names = (await repo.watchCollections().first)
        .map((c) => c.name)
        .toList();
    expect(names, ['Keychains', 'Postcards', 'shot glasses']);
  });

  test('other kind keeps its label; named kinds drop a stray label', () async {
    final otherId = await repo.createCollection(
      collectionDraft(
        name: 'Snow globes',
        kind: CollectionKind.other,
        otherLabel: 'snow globe',
      ),
    );
    final pinId = await repo.createCollection(
      collectionDraft(
        name: 'Pins',
        kind: CollectionKind.pin,
        otherLabel: 'should be dropped',
      ),
    );

    expect(
      (await repo.watchCollection(otherId).first)?.otherLabel,
      'snow globe',
    );
    expect((await repo.watchCollection(pinId).first)?.otherLabel, isNull);
  });

  test('watchSummaries counts items and resolves the cover photo', () async {
    final items = ItemRepository(db);
    final emptyId = await repo.createCollection(
      collectionDraft(name: 'Empty shelf'),
    );
    final fallbackId = await repo.createCollection(
      collectionDraft(name: 'Magnets'),
    );
    final explicitId = await repo.createCollection(
      collectionDraft(name: 'Keychains', coverPhotoPath: 'covers/k.jpg'),
    );

    await items.createItem(fallbackId, itemDraft(photoPath: 'a.jpg'));
    await items.createItem(fallbackId, itemDraft(photoPath: 'b.jpg'));
    await items.createItem(explicitId, itemDraft(photoPath: 'c.jpg'));

    final summaries = await repo.watchSummaries().first;
    expect(summaries.map((s) => s.collection.name), [
      'Empty shelf',
      'Keychains',
      'Magnets',
    ]);

    final empty = summaries.singleWhere((s) => s.collection.id == emptyId);
    expect(empty.itemCount, 0);
    expect(empty.coverPhotoPath, isNull);

    final fallback = summaries.singleWhere(
      (s) => s.collection.id == fallbackId,
    );
    expect(fallback.itemCount, 2);
    expect(fallback.coverPhotoPath, 'b.jpg', reason: 'newest item photo');

    final explicit = summaries.singleWhere(
      (s) => s.collection.id == explicitId,
    );
    expect(explicit.itemCount, 1);
    expect(explicit.coverPhotoPath, 'covers/k.jpg');
  });

  test('setCoverPhoto overrides and clears the cover', () async {
    final id = await repo.createCollection(collectionDraft());
    await ItemRepository(db).createItem(id, itemDraft(photoPath: 'a.jpg'));

    await repo.setCoverPhoto(id, 'covers/x.jpg');
    var summary = (await repo.watchSummaries().first).single;
    expect(summary.coverPhotoPath, 'covers/x.jpg');

    await repo.setCoverPhoto(id, null);
    summary = (await repo.watchSummaries().first).single;
    expect(summary.coverPhotoPath, 'a.jpg');
  });

  test('updateCollection rewrites name and kind', () async {
    final id = await repo.createCollection(collectionDraft());

    await repo.updateCollection(
      id,
      collectionDraft(name: 'Travel magnets', kind: CollectionKind.magnet),
    );

    final stored = await repo.watchCollection(id).first;
    expect(stored?.name, 'Travel magnets');
  });

  test('empty name is rejected by the schema', () async {
    expect(
      () => repo.createCollection(collectionDraft(name: '')),
      throwsA(anything),
    );
  });

  test('deleteCollection cascades its items', () async {
    final id = await repo.createCollection(collectionDraft());
    final items = ItemRepository(db);
    await items.createItem(id, itemDraft());
    await items.createItem(id, itemDraft(photoPath: 'b.jpg'));

    await repo.deleteCollection(id);

    expect(await repo.count(), 0);
    expect(await items.count(), 0);
  });

  test('deleting a collection never refunds a free-tier slot', () async {
    final tally = LifetimeTally(
      InMemoryKeyValueStore(),
      key: 'collections_created_lifetime',
    );
    addTearDown(tally.dispose);
    final tallied = CollectionRepository(db, tally: tally);

    final id = await tallied.createCollection(collectionDraft());
    expect(await tallied.lifetimeCreated(), 1);

    await tallied.deleteCollection(id);
    expect(await tallied.count(), 0);
    expect(await tallied.lifetimeCreated(), 1); // the slot stays spent

    await tallied.createCollection(collectionDraft(name: 'Again'));
    expect(await tallied.lifetimeCreated(), 2);
  });

  test(
    'lifetimeCreated floors at the live count on pre-tally installs',
    () async {
      await repo.createCollection(collectionDraft(name: 'A'));
      await repo.createCollection(collectionDraft(name: 'B'));

      final tally = LifetimeTally(
        InMemoryKeyValueStore(),
        key: 'collections_created_lifetime',
      );
      addTearDown(tally.dispose);
      expect(await CollectionRepository(db, tally: tally).lifetimeCreated(), 2);
    },
  );
}
