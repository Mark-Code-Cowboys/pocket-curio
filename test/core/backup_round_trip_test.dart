import 'package:cc_core/cc_core.dart' hide PhotoSource;
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/backup/backup_service.dart';
import 'package:pocket_curio/core/photos/photo_capture.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';

import '../helpers.dart';

void main() {
  test('backup archive round-trips rows, photos, and both tallies', () async {
    final source = makeTestDb();
    addTearDown(source.close);
    final sourceStore = makeTestStore();
    final collections = CollectionRepository(source);
    final items = ItemRepository(source);

    // Two real photo files in the source store, one referenced as cover.
    final shot = (await FakeCapture().capture(PhotoSource.camera))!;
    final photoA = await sourceStore.import(shot);
    final photoB = await sourceStore.import(shot);
    final magnets = await collections.createCollection(
      collectionDraft(name: 'Fridge magnets', coverPhotoPath: photoA),
    );
    final globes = await collections.createCollection(
      collectionDraft(
        name: 'Snow globes',
        kind: CollectionKind.other,
        otherLabel: 'snow globe',
      ),
    );
    await items.createItem(
      magnets,
      itemDraft(
        photoPath: photoA,
        place: 'Key West',
        city: 'Key West',
        state: 'FL',
        dateAcquired: DateTime(2019, 3, 2),
        tripOrOccasion: 'Spring break',
        whoGaveIt: 'Aunt Jo',
        rating: 5,
        notes: 'Sunburn.',
        lat: 24.55,
        lng: -81.78,
      ),
    );
    await items.createItem(
      globes,
      itemDraft(photoPath: photoB, place: 'Zermatt', country: 'Switzerland'),
    );

    // Lifetime figures larger than row counts (things were deleted).
    final exportData = await buildExportData(
      source,
      lifetimeCollections: 3,
      lifetimeItems: 9,
      now: DateTime(2026, 9, 5),
    );
    final media = await collectPhotoMedia(source, sourceStore);
    expect(media.keys.toSet(), {
      photoA.split('/').last,
      photoB.split('/').last,
    });
    final bytes = buildBackupArchive(exportData: exportData, media: media);

    // Restore onto a "new phone": fresh db, fresh store with a stray file.
    final target = makeTestDb();
    addTearDown(target.close);
    final targetStore = makeTestStore();
    final stray = await targetStore.import(shot);
    await ItemRepository(target).createItem(
      await CollectionRepository(target).createCollection(collectionDraft()),
      itemDraft(photoPath: stray, place: 'Old'),
    );
    final cTally = LifetimeTally(
      InMemoryKeyValueStore(),
      key: 'collections_created_lifetime',
    );
    final iTally = LifetimeTally(
      InMemoryKeyValueStore(),
      key: 'items_created_lifetime',
    );
    addTearDown(cTally.dispose);
    addTearDown(iTally.dispose);

    final contents = readBackupArchive(bytes);
    final previous = await referencedPhotoPaths(target);
    final tallies = await restoreFromExportData(target, contents.exportData);
    await restorePhotoMedia(
      targetStore,
      contents.media,
      previousPaths: previous,
    );
    await cTally.raiseTo(tallies.collections);
    await iTally.raiseTo(tallies.items);

    expect(await cTally.value(), 3);
    expect(await iTally.value(), 9);
    final restored = await buildExportData(
      target,
      lifetimeCollections: 3,
      lifetimeItems: 9,
      now: DateTime(2026, 9, 5),
    );
    expect(restored, contents.exportData);

    // Photos landed where the rows point; the stray is gone.
    expect(targetStore.resolve(photoA).existsSync(), isTrue);
    expect(targetStore.resolve(photoB).existsSync(), isTrue);
    expect(targetStore.resolve(stray).existsSync(), isFalse);

    // Spot checks through the repositories.
    final summaries = await CollectionRepository(target).watchSummaries().first;
    expect(summaries.map((s) => s.collection.name), [
      'Fridge magnets',
      'Snow globes',
    ]);
    expect(summaries.first.coverPhotoPath, photoA);
    final keyWest = (await ItemRepository(
      target,
    ).watchAllItems().first).singleWhere((i) => i.place == 'Key West');
    final keyWestEntry = (await target.select(target.appJournalEntries).get())
        .singleWhere((e) => e.id == keyWest.journalEntryId);
    expect(keyWestEntry.rating, 5);
    expect(keyWest.dateAcquired, DateTime(2019, 3, 2));
    expect(keyWest.lat, closeTo(24.55, 1e-9));
  });

  test('restore rejects foreign or malformed exports', () async {
    final db = makeTestDb();
    addTearDown(db.close);
    expect(
      () => restoreFromExportData(db, {'app': 'CourseLedger', 'format': 1}),
      throwsA(isA<InvalidBackupException>()),
    );
    expect(
      () => restoreFromExportData(db, {
        'app': 'PocketCurio',
        'format': 1,
        'collections': 'nope',
        'items': [],
      }),
      throwsA(isA<InvalidBackupException>()),
    );
  });

  test('collectPhotoMedia skips rows whose file is gone', () async {
    final db = makeTestDb();
    addTearDown(db.close);
    final store = makeTestStore();
    final real = await store.import(
      (await FakeCapture().capture(PhotoSource.camera))!,
    );
    final id = await CollectionRepository(
      db,
    ).createCollection(collectionDraft());
    final items = ItemRepository(db);
    await items.createItem(id, itemDraft(photoPath: real));
    await items.createItem(id, itemDraft(photoPath: 'photos/gone.png'));

    final media = await collectPhotoMedia(db, store);
    expect(media.keys, [real.split('/').last]);
  });

  test(
      'a format-1 backup (pre-journal) restores: notes and rating '
      'become entries', () async {
    final db = makeTestDb();
    addTearDown(db.close);
    final tallies = await restoreFromExportData(db, {
      'app': 'PocketCurio',
      'format': 1,
      'lifetimeCollections': 1,
      'lifetimeItems': 2,
      'collections': [
        {
          'id': 1,
          'name': 'Fridge magnets',
          'kind': 'magnet',
          'otherLabel': null,
          'coverPhotoPath': null,
          'createdAt': '2020-01-01T00:00:00.000',
        },
      ],
      'items': [
        {
          'id': 1,
          'collectionId': 1,
          'photoPath': 'photos/a.jpg',
          'place': 'Key West',
          'city': null,
          'state': 'FL',
          'country': 'US',
          'dateAcquired': null,
          'tripOrOccasion': null,
          'whoGaveIt': null,
          'rating': 5,
          'notes': 'Sunburn.',
          'lat': null,
          'lng': null,
          'createdAt': '2020-02-01T00:00:00.000',
        },
        {
          'id': 2,
          'collectionId': 1,
          'photoPath': 'photos/b.jpg',
          'place': 'Mackinac Island',
          'city': null,
          'state': 'MI',
          'country': 'US',
          'dateAcquired': null,
          'tripOrOccasion': null,
          'whoGaveIt': null,
          'rating': null,
          'notes': null,
          'lat': null,
          'lng': null,
          'createdAt': '2020-03-01T00:00:00.000',
        },
      ],
    });
    expect(tallies.items, 2);

    final items = await db.select(db.items).get();
    expect(items, hasLength(2));
    final keyWest = items.singleWhere((i) => i.place == 'Key West');
    final entry = (await db.select(db.appJournalEntries).get()).single;
    expect(keyWest.journalEntryId, entry.id);
    expect(entry.rating, 5);
    expect(entry.notes, 'Sunburn.');
    expect(
        items
            .singleWhere((i) => i.place == 'Mackinac Island')
            .journalEntryId,
        isNull);
  });
}
