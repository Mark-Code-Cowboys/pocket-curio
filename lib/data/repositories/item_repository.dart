import 'dart:math';

import 'package:cc_core/cc_core.dart';
import 'package:drift/drift.dart';
import 'package:stream_transform/stream_transform.dart';

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

/// An item joined with its memory (rating and notes live in the shared
/// cc_core journal tables; the photo is the item's own — the photo IS
/// the record).
class ItemWithStory {
  const ItemWithStory(this.item, {this.entry});

  final Item item;
  final JournalEntry? entry;

  int? get rating => entry?.rating;
  String? get notes => entry?.notes;
}

class ItemRepository {
  ItemRepository(this._db, {AppJournalRepository? journal, LifetimeTally? tally})
    : _journalOverride = journal, // ignore: prefer_initializing_formals
      _tally = tally; // ignore: prefer_initializing_formals

  final AppDatabase _db;
  final AppJournalRepository? _journalOverride;
  late final AppJournalRepository _journal = _journalOverride ?? _db.journal();

  /// Items ever created here, across every shelf; null in plain repo
  /// tests.
  final LifetimeTally? _tally;

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

  /// One-shot read of a shelf, for cleanup passes (deleting a collection
  /// removes each item's photo file).
  Future<List<Item>> itemsForCollection(int collectionId) {
    final query = _db.select(_db.items)
      ..where((i) => i.collectionId.equals(collectionId));
    return query.get();
  }

  /// Every item on the phone, for the map's aggregates.
  Stream<List<Item>> watchAllItems() {
    final query = _db.select(_db.items)
      ..orderBy([(i) => OrderingTerm.asc(i.id)]);
    return query.watch();
  }

  Stream<Item?> watchItem(int id) {
    final query = _db.select(_db.items)..where((i) => i.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// One item with its memory, live — the detail screen's feed.
  Stream<ItemWithStory?> watchItemWithStory(int id) {
    final entries = _db.select(_db.appJournalEntries).watch();
    return watchItem(id).combineLatest(entries,
        (Item? item, List<JournalEntry> entryRows) {
      if (item == null) return null;
      final byId = {for (final e in entryRows) e.id: e};
      return ItemWithStory(item, entry: byId[item.journalEntryId]);
    });
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

  Future<int> createItem(int collectionId, ItemDraft d) async {
    final id = await _db.transaction(() async {
      final entryId = await _entryFor(d);
      return _db
          .into(_db.items)
          .insert(_companion(collectionId, d, entryId));
    });
    await _tally?.recordCreated(liveCount: await count());
    return id;
  }

  /// Bulk insert for the shelf/fridge batch scan (Phase D): all or none.
  /// Every inserted row spends a free-tier slot.
  Future<List<int>> createItems(
    int collectionId,
    List<ItemDraft> drafts,
  ) async {
    final ids = await _db.transaction(() async {
      final ids = <int>[];
      for (final d in drafts) {
        final entryId = await _entryFor(d);
        ids.add(await _db
            .into(_db.items)
            .insert(_companion(collectionId, d, entryId)));
      }
      return ids;
    });
    if (_tally != null) {
      // One raise for the batch: recordCreated floors at the live count
      // on every call, so calling it per row would double count.
      final live = await count();
      await _tally.raiseTo(max(await _tally.value() + ids.length, live));
    }
    return ids;
  }

  /// Items ever created on this device across all shelves: the tally,
  /// but never below the live row count. Feeds `FreeLimit(25, 'items')`
  /// so deleting an item doesn't hand the slot back.
  Future<int> lifetimeCreated() async {
    final live = await count();
    final tallied = await _tally?.value() ?? 0;
    return max(live, tallied);
  }

  /// Live [lifetimeCreated], ticking on creates and on row changes.
  Stream<int> watchLifetimeCreated() {
    final countExp = _db.items.id.count();
    final live = (_db.selectOnly(
      _db.items,
    )..addColumns([countExp])).watchSingle().map((row) => row.read(countExp)!);
    final tallied = _tally?.watch() ?? Stream.value(0);
    return live.combineLatest(tallied, (int a, int b) => max(a, b));
  }

  Future<void> updateItem(int id, ItemDraft d) {
    return _db.transaction(() async {
      final item = await (_db.select(_db.items)
            ..where((i) => i.id.equals(id)))
          .getSingle();
      var entryId = item.journalEntryId;
      if (entryId == null && (d.rating != null || d.notes != null)) {
        entryId = await _journal
            .createEntry(JournalEntryDraft(notes: d.notes, rating: d.rating));
      } else if (entryId != null) {
        await _journal.updateEntry(entryId, notes: d.notes, rating: d.rating);
      }
      await (_db.update(_db.items)..where((i) => i.id.equals(id))).write(
        ItemsCompanion(
          photoPath: Value(d.photoPath),
          place: Value(d.place),
          city: Value(d.city),
          state: Value(d.state),
          country: Value(d.country),
          dateAcquired: Value(d.dateAcquired),
          tripOrOccasion: Value(d.tripOrOccasion),
          whoGaveIt: Value(d.whoGaveIt),
          lat: Value(d.lat),
          lng: Value(d.lng),
          journalEntryId: Value(entryId),
        ),
      );
    });
  }

  /// The photo *file* is cleaned up by the composer layer, which owns
  /// the file store; the journal entry goes here.
  Future<void> deleteItem(int id) async {
    final item = await (_db.select(_db.items)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
    await (_db.delete(_db.items)..where((i) => i.id.equals(id))).go();
    final entryId = item?.journalEntryId;
    if (entryId != null) await _journal.deleteEntries([entryId]);
  }

  /// Owner-cleanup for collection deletes: removes the journal entries
  /// of every item on the shelf (rows cascade with the collection).
  Future<void> deleteEntriesForCollection(int collectionId) async {
    final entryId = _db.items.journalEntryId;
    final query = _db.selectOnly(_db.items)
      ..addColumns([entryId])
      ..where(_db.items.collectionId.equals(collectionId) &
          entryId.isNotNull());
    final ids = [for (final row in await query.get()) row.read(entryId)!];
    if (ids.isNotEmpty) await _journal.deleteEntries(ids);
  }

  /// Creates the memory entry when the draft carries one.
  Future<int?> _entryFor(ItemDraft d) async {
    if (d.rating == null && d.notes == null) return null;
    return _journal
        .createEntry(JournalEntryDraft(notes: d.notes, rating: d.rating));
  }

  ItemsCompanion _companion(int collectionId, ItemDraft d, int? entryId) =>
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
        lat: Value(d.lat),
        lng: Value(d.lng),
        journalEntryId: Value(entryId),
      );
}
