// Drift's `check(column...)` idiom trips this lint on rating columns.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

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

/// One souvenir. The photo IS the record; place is what's printed on it
/// or what it represents. Everything else is optional memory.
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
  IntColumn get rating =>
      integer().nullable().check(rating.isBetweenValues(1, 5))();
  // The memory. App-local until cc_core journal/ lands (docs/cc-core-gaps.md).
  TextColumn get notes => text().nullable()();
  // Opt-in only; never captured without an explicit user action.
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Collections, Items])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database. All data stays local; nothing leaves
  /// the phone.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'pocketcurio'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
