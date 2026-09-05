import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Shelf ordering in the collection view.
enum ItemSort {
  /// Date acquired, newest first; items without one fall back to the
  /// date they were added.
  byDate,

  /// Place A-Z.
  byPlace,
}

/// An item being composed, before it has a database id. Photo and place
/// are the two-field minimum path; everything else is optional memory.
class ItemDraft {
  const ItemDraft({
    required this.photoPath,
    required this.place,
    this.city,
    this.state,
    this.country,
    this.dateAcquired,
    this.tripOrOccasion,
    this.whoGaveIt,
    this.rating,
    this.notes,
    this.lat,
    this.lng,
  });

  final String photoPath;
  final String place;
  final String? city;
  final String? state;
  final String? country;
  final DateTime? dateAcquired;
  final String? tripOrOccasion;
  final String? whoGaveIt;
  final int? rating;
  final String? notes;
  final double? lat;
  final double? lng;
}

class ItemRepository {
  ItemRepository(this._db);

  final AppDatabase _db;

  /// Items on one shelf in the chosen order.
  Stream<List<Item>> watchItemsForCollection(
    int collectionId, {
    ItemSort sort = ItemSort.byDate,
  }) {
    final query = _db.select(_db.items)
      ..where((i) => i.collectionId.equals(collectionId))
      ..orderBy(switch (sort) {
        ItemSort.byDate => [
            (i) => OrderingTerm.desc(coalesce([i.dateAcquired, i.createdAt])),
            (i) => OrderingTerm.desc(i.id),
          ],
        ItemSort.byPlace => [
            (i) => OrderingTerm.asc(i.place.lower()),
            (i) => OrderingTerm.desc(i.id),
          ],
      });
    return query.watch();
  }

  Stream<Item?> watchItem(int id) {
    final query = _db.select(_db.items)..where((i) => i.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Items across every collection — feeds `FreeLimit(25, 'items')`.
  /// The cap is per install, not per shelf.
  Future<int> count() async {
    final countExp = _db.items.id.count();
    final query = _db.selectOnly(_db.items)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp)!;
  }

  Future<int> countInCollection(int collectionId) async {
    final countExp = _db.items.id.count();
    final query = _db.selectOnly(_db.items)
      ..addColumns([countExp])
      ..where(_db.items.collectionId.equals(collectionId));
    final row = await query.getSingle();
    return row.read(countExp)!;
  }

  Future<int> createItem(int collectionId, ItemDraft d) {
    return _db.into(_db.items).insert(_companion(collectionId, d));
  }

  /// Bulk insert for the shelf/fridge batch scan (Phase D): all or none.
  Future<List<int>> createItems(int collectionId, List<ItemDraft> drafts) {
    return _db.transaction(() async {
      final ids = <int>[];
      for (final d in drafts) {
        ids.add(await _db.into(_db.items).insert(_companion(collectionId, d)));
      }
      return ids;
    });
  }

  Future<void> updateItem(int id, ItemDraft d) {
    return (_db.update(_db.items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        photoPath: Value(d.photoPath),
        place: Value(d.place),
        city: Value(d.city),
        state: Value(d.state),
        country: Value(d.country),
        dateAcquired: Value(d.dateAcquired),
        tripOrOccasion: Value(d.tripOrOccasion),
        whoGaveIt: Value(d.whoGaveIt),
        rating: Value(d.rating),
        notes: Value(d.notes),
        lat: Value(d.lat),
        lng: Value(d.lng),
      ),
    );
  }

  /// The photo *file* is cleaned up by the composer layer (Phase B),
  /// which owns the file store.
  Future<void> deleteItem(int id) {
    return (_db.delete(_db.items)..where((i) => i.id.equals(id))).go();
  }

  ItemsCompanion _companion(int collectionId, ItemDraft d) =>
      ItemsCompanion.insert(
        collectionId: collectionId,
        photoPath: d.photoPath,
        place: d.place,
        city: Value(d.city),
        state: Value(d.state),
        country: Value(d.country),
        dateAcquired: Value(d.dateAcquired),
        tripOrOccasion: Value(d.tripOrOccasion),
        whoGaveIt: Value(d.whoGaveIt),
        rating: Value(d.rating),
        notes: Value(d.notes),
        lat: Value(d.lat),
        lng: Value(d.lng),
      );
}
