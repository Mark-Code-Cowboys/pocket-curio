import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import 'package:pocket_curio/data/database/app_database.dart';

/// Builds a real schema-v1 database file the way shipped 1.0 installs
/// have it, then opens AppDatabase over it and asserts the v2 migration
/// moved every memory into the journal without losing a row.
void main() {
  test('v1 -> v2 migration moves rating/notes into the journal',
      () async {
    final dir = await Directory.systemTemp.createTemp('pc-migration');
    addTearDown(() => dir.delete(recursive: true));
    final path = '${dir.path}/pocketcurio.sqlite';

    final v1 = raw.sqlite3.open(path);
    v1.execute('''
      CREATE TABLE collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, kind TEXT NOT NULL,
        other_label TEXT, cover_photo_path TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        CHECK (kind = 'other' OR other_label IS NULL));
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection_id INTEGER NOT NULL REFERENCES collections (id)
          ON DELETE CASCADE,
        photo_path TEXT NOT NULL, place TEXT NOT NULL,
        city TEXT, state TEXT, country TEXT,
        date_acquired INTEGER, trip_or_occasion TEXT, who_gave_it TEXT,
        rating INTEGER CHECK (rating BETWEEN 1 AND 5), notes TEXT,
        lat REAL, lng REAL,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')));

      INSERT INTO collections (name, kind) VALUES ('Fridge magnets', 'magnet');
      INSERT INTO items (collection_id, photo_path, place, rating, notes)
        VALUES (1, 'photos/a.jpg', 'Key West', 5,
                'Sunburn and key lime pie.');
      INSERT INTO items (collection_id, photo_path, place)
        VALUES (1, 'photos/b.jpg', 'Mackinac Island');
      PRAGMA user_version = 1;
    ''');
    v1.close();

    final db = AppDatabase(NativeDatabase(File(path)));
    addTearDown(db.close);

    final items = await (db.select(db.items)
          ..orderBy([(i) => OrderingTerm.asc(i.id)]))
        .get();
    expect(items, hasLength(2));
    // The photo stays a domain column — untouched by the migration.
    expect(items.first.photoPath, 'photos/a.jpg');
    expect(items.first.journalEntryId, isNotNull);
    expect(items.last.journalEntryId, isNull); // memory-less item

    final entries = await db.select(db.appJournalEntries).get();
    expect(entries, hasLength(1));
    expect(entries.single.notes, 'Sunburn and key lime pie.');
    expect(entries.single.rating, 5);

    // The old columns are gone from the rebuilt table.
    final columns = await db
        .customSelect("SELECT name FROM pragma_table_info('items')")
        .get();
    final names = {for (final c in columns) c.read<String>('name')};
    expect(names, isNot(contains('rating')));
    expect(names, isNot(contains('notes')));
    expect(names, contains('journal_entry_id'));
  });
}
