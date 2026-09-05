import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// One tile in the Home grid: the collection, how many items it holds,
/// and the photo to show on the tile (explicit cover, else the newest
/// item's photo, else nothing — the empty-state tile).
class CollectionSummary {
  const CollectionSummary(
    this.collection, {
    required this.itemCount,
    this.coverPhotoPath,
  });

  final Collection collection;
  final int itemCount;
  final String? coverPhotoPath;
}

/// A collection being composed, before it has a database id.
class CollectionDraft {
  const CollectionDraft({
    required this.name,
    required this.kind,
    this.otherLabel,
    this.coverPhotoPath,
  });

  final String name;
  final CollectionKind kind;
  final String? otherLabel;
  final String? coverPhotoPath;
}

class CollectionRepository {
  CollectionRepository(this._db);

  final AppDatabase _db;

  /// All collections A-Z.
  Stream<List<Collection>> watchCollections() {
    final query = _db.select(_db.collections)
      ..orderBy([(c) => OrderingTerm.asc(c.name.lower())]);
    return query.watch();
  }

  /// Every collection with its item count and resolved cover photo, A-Z.
  Stream<List<CollectionSummary>> watchSummaries() {
    final itemCount = _db.items.id.count();
    final query =
        _db.select(_db.collections).join([
            leftOuterJoin(
              _db.items,
              _db.items.collectionId.equalsExp(_db.collections.id),
              useColumns: false,
            ),
          ])
          ..addColumns([itemCount])
          ..groupBy([_db.collections.id])
          ..orderBy([OrderingTerm.asc(_db.collections.name.lower())]);

    // Newest item photo per collection, for tiles without an explicit
    // cover. A second query keeps the join above a plain count.
    final newestPhotos = _db.select(_db.items)
      ..orderBy([
        (i) => OrderingTerm.desc(i.createdAt),
        (i) => OrderingTerm.desc(i.id),
      ]);

    return query.watch().asyncMap((rows) async {
      final latest = <int, String>{};
      for (final item in await newestPhotos.get()) {
        latest.putIfAbsent(item.collectionId, () => item.photoPath);
      }
      return rows.map((row) {
        final collection = row.readTable(_db.collections);
        return CollectionSummary(
          collection,
          itemCount: row.read(itemCount)!,
          coverPhotoPath: collection.coverPhotoPath ?? latest[collection.id],
        );
      }).toList();
    });
  }

  /// One-shot read, for actions that need the current row once.
  Future<Collection?> getCollection(int id) {
    final query = _db.select(_db.collections)..where((c) => c.id.equals(id));
    return query.getSingleOrNull();
  }

  Stream<Collection?> watchCollection(int id) {
    final query = _db.select(_db.collections)..where((c) => c.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Number of collections — feeds `FreeLimit(1, 'collections')`.
  Future<int> count() async {
    final countExp = _db.collections.id.count();
    final query = _db.selectOnly(_db.collections)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp)!;
  }

  Future<int> createCollection(CollectionDraft d) {
    return _db.into(_db.collections).insert(_companion(d));
  }

  Future<void> updateCollection(int id, CollectionDraft d) {
    return (_db.update(
      _db.collections,
    )..where((c) => c.id.equals(id))).write(_companion(d));
  }

  Future<void> setCoverPhoto(int id, String? path) {
    return (_db.update(_db.collections)..where((c) => c.id.equals(id))).write(
      CollectionsCompanion(coverPhotoPath: Value(path)),
    );
  }

  /// Items cascade. Photo *files* are cleaned up by the composer layer
  /// (Phase B), which owns the file store.
  Future<void> deleteCollection(int id) {
    return (_db.delete(_db.collections)..where((c) => c.id.equals(id))).go();
  }

  CollectionsCompanion _companion(CollectionDraft d) =>
      CollectionsCompanion.insert(
        name: d.name,
        kind: d.kind,
        otherLabel: Value(d.kind == CollectionKind.other ? d.otherLabel : null),
        coverPhotoPath: Value(d.coverPhotoPath),
      );
}
