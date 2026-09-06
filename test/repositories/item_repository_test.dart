import 'package:cc_core/cc_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository repo;
  late int collectionId;

  setUp(() async {
    db = makeTestDb();
    repo = ItemRepository(db);
    collectionId = await CollectionRepository(
      db,
    ).createCollection(collectionDraft());
  });

  tearDown(() => db.close());

  test('two-field minimum path: photo + place, everything else null', () async {
    final id = await repo.createItem(
      collectionId,
      const ItemDraft(photoPath: 'items/0001.jpg', place: 'Key West'),
    );

    final story = await repo.watchItemWithStory(id).first;
    final item = story?.item;
    expect(item?.photoPath, 'items/0001.jpg');
    expect(item?.place, 'Key West');
    expect(item?.city, isNull);
    expect(item?.state, isNull);
    expect(item?.country, isNull);
    expect(item?.dateAcquired, isNull);
    expect(item?.tripOrOccasion, isNull);
    expect(item?.whoGaveIt, isNull);
    expect(story?.rating, isNull);
    expect(story?.notes, isNull);
    expect(item?.lat, isNull);
    expect(item?.lng, isNull);
    expect(item?.createdAt, isNotNull);
  });

  test('createItem stores the full memory', () async {
    final id = await repo.createItem(
      collectionId,
      itemDraft(
        place: 'Niagara Falls',
        city: 'Niagara Falls',
        state: 'ON',
        country: 'CA',
        dateAcquired: DateTime(2019, 7, 4),
        tripOrOccasion: 'Honeymoon',
        whoGaveIt: 'Bought it myself',
        rating: 5,
        notes: 'Soaked on the Maid of the Mist.',
        lat: 43.0896,
        lng: -79.0849,
      ),
    );

    final story = await repo.watchItemWithStory(id).first;
    final item = story?.item;
    expect(item?.country, 'CA');
    expect(item?.dateAcquired, DateTime(2019, 7, 4));
    expect(item?.tripOrOccasion, 'Honeymoon');
    expect(item?.whoGaveIt, 'Bought it myself');
    expect(story?.rating, 5);
    expect(story?.notes, 'Soaked on the Maid of the Mist.');
    expect(item?.lat, closeTo(43.0896, 1e-9));
    expect(item?.lng, closeTo(-79.0849, 1e-9));
  });

  test('empty place or photo path is rejected by the schema', () async {
    expect(
      () => repo.createItem(collectionId, itemDraft(place: '')),
      throwsA(anything),
    );
    expect(
      () => repo.createItem(collectionId, itemDraft(photoPath: '')),
      throwsA(anything),
    );
  });

  test('rating outside 1-5 is rejected by the schema', () async {
    expect(
      () => repo.createItem(collectionId, itemDraft(rating: 0)),
      throwsA(anything),
    );
    expect(
      () => repo.createItem(collectionId, itemDraft(rating: 6)),
      throwsA(anything),
    );
  });

  test(
    'byDate sorts newest acquired first, undated fall back to added',
    () async {
      final old = await repo.createItem(
        collectionId,
        itemDraft(place: 'Old', dateAcquired: DateTime(2015, 1, 1)),
      );
      final recent = await repo.createItem(
        collectionId,
        itemDraft(place: 'Recent', dateAcquired: DateTime(2026, 1, 1)),
      );
      // Undated: coalesces to createdAt (now), so it sorts newest of all.
      final undated = await repo.createItem(
        collectionId,
        itemDraft(place: 'Undated'),
      );

      final items = await repo
          .watchItemsForCollection(collectionId, sort: ItemSort.byDate)
          .first;
      expect(items.map((i) => i.id), [undated, recent, old]);
    },
  );

  test('byPlace sorts A-Z, case-insensitively', () async {
    await repo.createItem(collectionId, itemDraft(place: 'zion'));
    await repo.createItem(collectionId, itemDraft(place: 'Acadia'));
    await repo.createItem(collectionId, itemDraft(place: 'Moab'));

    final items = await repo
        .watchItemsForCollection(collectionId, sort: ItemSort.byPlace)
        .first;
    expect(items.map((i) => i.place), ['Acadia', 'Moab', 'zion']);
  });

  test('watchItemsForCollection is scoped to the shelf', () async {
    final otherShelf = await CollectionRepository(
      db,
    ).createCollection(collectionDraft(name: 'Keychains'));
    await repo.createItem(collectionId, itemDraft(place: 'Mine'));
    await repo.createItem(otherShelf, itemDraft(place: 'Theirs'));

    final mine = await repo.watchItemsForCollection(collectionId).first;
    expect(mine.map((i) => i.place), ['Mine']);
  });

  test(
    'count is per install across shelves; countInCollection per shelf',
    () async {
      final otherShelf = await CollectionRepository(
        db,
      ).createCollection(collectionDraft(name: 'Keychains'));
      await repo.createItem(collectionId, itemDraft());
      await repo.createItem(collectionId, itemDraft(photoPath: 'b.jpg'));
      await repo.createItem(otherShelf, itemDraft(photoPath: 'c.jpg'));

      expect(await repo.count(), 3);
      expect(await repo.countInCollection(collectionId), 2);
      expect(await repo.countInCollection(otherShelf), 1);
    },
  );

  test('createItems inserts all or none', () async {
    final ids = await repo.createItems(collectionId, [
      itemDraft(place: 'A', photoPath: 'a.jpg'),
      itemDraft(place: 'B', photoPath: 'b.jpg'),
    ]);
    expect(ids, hasLength(2));
    expect(await repo.count(), 2);

    await expectLater(
      repo.createItems(collectionId, [
        itemDraft(place: 'C', photoPath: 'c.jpg'),
        itemDraft(place: 'D', photoPath: 'd.jpg', rating: 9),
      ]),
      throwsA(anything),
    );
    expect(await repo.count(), 2, reason: 'C rolled back with D');
  });

  test('updateItem rewrites fields including clearing optional ones', () async {
    final id = await repo.createItem(
      collectionId,
      itemDraft(place: 'Boston', rating: 3, notes: 'first pass'),
    );

    await repo.updateItem(
      id,
      itemDraft(place: 'Boston Harbor', rating: null, notes: null),
    );

    final story = await repo.watchItemWithStory(id).first;
    expect(story?.item.place, 'Boston Harbor');
    expect(story?.rating, isNull);
    expect(story?.notes, isNull);
  });

  test('deleteItem removes the row and the stream reports null', () async {
    final id = await repo.createItem(collectionId, itemDraft());

    await repo.deleteItem(id);

    expect(await repo.watchItem(id).first, isNull);
    expect(await repo.count(), 0);
  });

  test('item cannot point at a missing collection', () async {
    expect(() => repo.createItem(9999, itemDraft()), throwsA(anything));
  });

  test('the item tally counts every shelf and every bulk row', () async {
    final tally = LifetimeTally(
      InMemoryKeyValueStore(),
      key: 'items_created_lifetime',
    );
    addTearDown(tally.dispose);
    final tallied = ItemRepository(db, tally: tally);
    final otherShelf = await CollectionRepository(
      db,
    ).createCollection(collectionDraft(name: 'Keychains'));

    final first = await tallied.createItem(collectionId, itemDraft());
    await tallied.createItems(otherShelf, [
      itemDraft(place: 'A', photoPath: 'a.jpg'),
      itemDraft(place: 'B', photoPath: 'b.jpg'),
    ]);
    expect(await tallied.lifetimeCreated(), 3);

    await tallied.deleteItem(first);
    expect(await tallied.count(), 2);
    expect(await tallied.lifetimeCreated(), 3); // the slot stays spent
    expect(await tallied.watchLifetimeCreated().first, 3);
  });
}
