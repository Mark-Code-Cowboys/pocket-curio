import 'package:cc_core/cc_core.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// This database's concrete journal repository type (cc_core's
/// JournalRepository is generic over the generated table classes).
typedef AppJournalRepository = JournalRepository<$AppJournalEntriesTable,
    $AppJournalPhotosTable, $AppJournalTagsTable>;

// Thin local registrations of cc_core's journal tables (drift can't
// analyze table classes across package boundaries in the default build
// mode, and @UseRowClass doesn't inherit). Names pinned to the shared
// schema so backups stay fleet-compatible.
@UseRowClass(JournalEntry)
class AppJournalEntries extends JournalEntries {
  @override
  String get tableName => 'journal_entries';
}

@UseRowClass(JournalPhoto)
class AppJournalPhotos extends JournalPhotos {
  @override
  String get tableName => 'journal_photos';
}

@UseRowClass(JournalTag)
class AppJournalTags extends JournalTags {
  @override
  String get tableName => 'journal_tags';
}

/// What a collection holds. `other` carries its own label on the row.
enum CollectionKind {
  keychain,
  magnet,
  shotGlass,
  patch,
  ornament,
  pin,
  spoon,
  sticker,
  postcard,
  other,
}

/// A display shelf: one kind of souvenir, one collector. Several per
/// install serves a household (the keychain collector and the magnet
/// collector share a phone).
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get kind => textEnum<CollectionKind>()();
  // Only meaningful when kind == other ("snow globes").
  TextColumn get otherLabel => text().nullable()();
  // Explicit cover; when null the Home grid shows the newest item photo.
  TextColumn get coverPhotoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    "CHECK (kind = 'other' OR other_label IS NULL)",
  ];
}

/// One souvenir. The photo IS the record — a structural domain column,
/// not a journal attachment (the TableEncore dish-photo precedent; see
/// docs/journal-adoption-read.md). The MEMORY — rating and notes —
/// lives in the shared cc_core journal tables via journalEntryId.
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId =>
      integer().references(Collections, #id, onDelete: KeyAction.cascade)();
  TextColumn get photoPath => text().withLength(min: 1)();
  TextColumn get place => text().withLength(min: 1, max: 160)();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get country => text().nullable()();
  DateTimeColumn get dateAcquired => dateTime().nullable()();
  TextColumn get tripOrOccasion => text().nullable()();
  TextColumn get whoGaveIt => text().nullable()();
  // Opt-in only; never captured without an explicit user action.
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // Raw-SQL FK for the same cross-package reason as the journal tables.
  IntColumn get journalEntryId => integer().nullable()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (journal_entry_id) REFERENCES journal_entries (id) '
        'ON DELETE SET NULL',
  ];
}

@DriftDatabase(tables: [
  Collections,
  Items,
  AppJournalEntries,
  AppJournalPhotos,
  AppJournalTags,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database. All data stays local; nothing leaves
  /// the phone.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'pocketcurio'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await _migrateToJournal(m);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// The journal repository over this database's generated tables.
  AppJournalRepository journal({PhotoFileStore? photoStore}) =>
      JournalRepository(
        this,
        entries: appJournalEntries,
        photos: appJournalPhotos,
        tags: appJournalTags,
        photoStore: photoStore,
      );

  /// v1 -> v2: items' rating/notes move into the shared journal
  /// tables (the item photo stays a domain column — the photo IS the
  /// record). Raw SQL because the old columns no longer exist in the
  /// Dart schema.
  Future<void> _migrateToJournal(Migrator m) async {
    await m.createTable(appJournalEntries);
    await m.createTable(appJournalPhotos);
    await m.createTable(appJournalTags);
    await m.addColumn(items, items.journalEntryId);

    final storied = await customSelect(
      'SELECT id, notes, rating FROM items '
      'WHERE notes IS NOT NULL OR rating IS NOT NULL',
    ).get();
    for (final row in storied) {
      final entryId = await customInsert(
        'INSERT INTO journal_entries (notes, rating) VALUES (?, ?)',
        variables: [
          Variable(row.read<String?>('notes')),
          Variable(row.read<int?>('rating')),
        ],
        updates: {appJournalEntries},
      );
      await customStatement(
        'UPDATE items SET journal_entry_id = ? WHERE id = ?',
        [entryId, row.read<int>('id')],
      );
    }
    // Rebuild items to the v2 shape (drops the notes/rating columns).
    await m.alterTable(TableMigration(items));
  }
}
