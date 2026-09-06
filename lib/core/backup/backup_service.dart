import 'package:cc_core/cc_core.dart';
import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';
import '../photos/photo_store.dart';

/// The free-tier figures a backup carries so a restore never resets the
/// free tier (both tallies are `raiseTo`'d, never lowered).
class RestoredTallies {
  const RestoredTallies({required this.collections, required this.items});

  final int collections;
  final int items;
}

/// Every collection and item as a JSON-encodable map (format 1). Pure
/// data — photos are referenced by their store path; the archive
/// carries their bytes separately (see [collectPhotoMedia]).
Future<Map<String, Object?>> buildExportData(
  AppDatabase db, {
  required int lifetimeCollections,
  required int lifetimeItems,
  DateTime? now,
}) async {
  final collections = await (db.select(
    db.collections,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  final items = await (db.select(
    db.items,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  return {
    'app': 'PocketCurio',
    'format': 2,
    'exportedAt': (now ?? DateTime.now()).toIso8601String(),
    'lifetimeCollections': lifetimeCollections,
    'lifetimeItems': lifetimeItems,
    'collections': [
      for (final c in collections)
        {
          'id': c.id,
          'name': c.name,
          'kind': c.kind.name,
          'otherLabel': c.otherLabel,
          'coverPhotoPath': c.coverPhotoPath,
          'createdAt': c.createdAt.toIso8601String(),
        },
    ],
    'items': [
      for (final i in items)
        {
          'id': i.id,
          'collectionId': i.collectionId,
          'photoPath': i.photoPath,
          'place': i.place,
          'city': i.city,
          'state': i.state,
          'country': i.country,
          'dateAcquired': i.dateAcquired?.toIso8601String(),
          'tripOrOccasion': i.tripOrOccasion,
          'whoGaveIt': i.whoGaveIt,
          'journalEntryId': i.journalEntryId,
          'lat': i.lat,
          'lng': i.lng,
          'createdAt': i.createdAt.toIso8601String(),
        },
    ],
    ...await db.journal().dumpJournalTables(),
  };
}

/// Every photo path the database references: item photos and explicit
/// collection covers.
Future<Set<String>> referencedPhotoPaths(AppDatabase db) async {
  final items = await db.select(db.items).get();
  final collections = await db.select(db.collections).get();
  return {
    for (final i in items) i.photoPath,
    for (final c in collections)
      if (c.coverPhotoPath != null) c.coverPhotoPath!,
  };
}

/// Photo files for the archive's media folder, keyed by base name (the
/// store names files uniquely, so the base name is enough and the
/// archive reader's no-slashes rule is satisfied). Missing files are
/// skipped — the JSON keeps the reference either way.
Future<Map<String, List<int>>> collectPhotoMedia(
  AppDatabase db,
  PhotoStore store,
) async {
  final media = <String, List<int>>{};
  for (final path in await referencedPhotoPaths(db)) {
    final file = store.resolve(path);
    if (file.existsSync()) {
      media[file.uri.pathSegments.last] = file.readAsBytesSync();
    }
  }
  return media;
}

/// Replaces every collection and item with the contents of an export
/// (format 1, as produced by [buildExportData]) in one transaction:
/// either the whole backup lands or nothing changes. Ids are preserved
/// so cover references stay stable. Photo files are handled separately
/// by [restorePhotoMedia].
Future<RestoredTallies> restoreFromExportData(
  AppDatabase db,
  Map<String, Object?> data,
) async {
  if (data['app'] != 'PocketCurio' ||
      (data['format'] != 1 && data['format'] != 2)) {
    throw const InvalidBackupException('Not a Pocket Curio backup');
  }
  final upgraded = data['format'] == 1 ? _upgradeFormat1(data) : data;
  final collections = upgraded['collections'];
  final items = upgraded['items'];
  if (collections is! List || items is! List) {
    throw const InvalidBackupException('Malformed export tables');
  }

  await db.transaction(() async {
    // Items cascade away with their collections.
    await db.delete(db.collections).go();
    await db.delete(db.appJournalEntries).go();
    await db.journal().restoreJournalTables(upgraded);

    for (final row in collections.cast<Map<String, dynamic>>()) {
      await db
          .into(db.collections)
          .insert(
            CollectionsCompanion(
              id: Value(row['id'] as int),
              name: Value(row['name'] as String),
              kind: Value(CollectionKind.values.byName(row['kind'] as String)),
              otherLabel: Value(row['otherLabel'] as String?),
              coverPhotoPath: Value(row['coverPhotoPath'] as String?),
              createdAt: Value(DateTime.parse(row['createdAt'] as String)),
            ),
          );
    }
    for (final row in items.cast<Map<String, dynamic>>()) {
      await db
          .into(db.items)
          .insert(
            ItemsCompanion(
              id: Value(row['id'] as int),
              collectionId: Value(row['collectionId'] as int),
              photoPath: Value(row['photoPath'] as String),
              place: Value(row['place'] as String),
              city: Value(row['city'] as String?),
              state: Value(row['state'] as String?),
              country: Value(row['country'] as String?),
              dateAcquired: Value(switch (row['dateAcquired'] as String?) {
                null => null,
                final s => DateTime.parse(s),
              }),
              tripOrOccasion: Value(row['tripOrOccasion'] as String?),
              whoGaveIt: Value(row['whoGaveIt'] as String?),
              journalEntryId: Value(row['journalEntryId'] as int?),
              lat: Value((row['lat'] as num?)?.toDouble()),
              lng: Value((row['lng'] as num?)?.toDouble()),
              createdAt: Value(DateTime.parse(row['createdAt'] as String)),
            ),
          );
    }
  });
  return RestoredTallies(
    collections:
        (upgraded['lifetimeCollections'] as num?)?.toInt() ??
            collections.length,
    items: (upgraded['lifetimeItems'] as num?)?.toInt() ?? items.length,
  );
}

/// Maps a pre-journal (format 1) export into the format-2 shape:
/// items' notes/rating become journal entries.
Map<String, Object?> _upgradeFormat1(Map<String, Object?> data) {
  final items =
      (data['items'] as List? ?? const []).cast<Map<String, dynamic>>();
  final entries = <Map<String, Object?>>[];
  final newItems = <Map<String, Object?>>[];
  var nextEntry = 1;
  for (final i in items) {
    int? entryId;
    if (i['notes'] != null || i['rating'] != null) {
      entryId = nextEntry++;
      entries.add({
        'id': entryId,
        'notes': i['notes'],
        'rating': i['rating'],
        'createdAt': null,
      });
    }
    newItems.add(
      {...i, 'journalEntryId': entryId}
        ..remove('notes')
        ..remove('rating'),
    );
  }
  return {
    ...data,
    'format': 2,
    'items': newItems,
    'journalEntries': entries,
    'journalPhotos': const <Object?>[],
    'journalTags': const <Object?>[],
  };
}

/// Swaps the photo store's contents for the archive's: the files the
/// old rows referenced ([previousPaths], captured before the database
/// restore) are removed, then every media entry is written under
/// `photos/<name>` — which is exactly what the restored rows reference.
Future<void> restorePhotoMedia(
  PhotoStore store,
  Map<String, List<int>> media, {
  required Iterable<String> previousPaths,
}) async {
  for (final path in previousPaths) {
    await store.delete(path);
  }
  for (final entry in media.entries) {
    await store.write('photos/${entry.key}', entry.value);
  }
}
