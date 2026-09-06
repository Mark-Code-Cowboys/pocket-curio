import 'dart:io';

import 'package:cc_core/cc_core.dart';
import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';
import '../backup/backup_service.dart';
import '../photos/photo_store.dart';
import '../utils/labels.dart';

/// Writes exports to temp files and hands them to the share sheet.
/// The temp directory is injected so tests stay plugin-free.
class ExportService {
  ExportService(this._db, this._store, this._share, this._tempDir);

  final AppDatabase _db;
  final PhotoStore _store;
  final ShareLauncher _share;
  final Future<Directory> Function() _tempDir;

  /// Every souvenir as a CSV row, joined with its collection. Returns
  /// the written file (mainly for tests).
  Future<File> shareItemsCsv({DateTime? now}) async {
    final collections = await _db.select(_db.collections).get();
    final byId = {for (final c in collections) c.id: c};
    final items =
        await (_db.select(_db.items)..orderBy([
              (t) => OrderingTerm.asc(t.collectionId),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final entries = {
      for (final e in await _db.select(_db.appJournalEntries).get()) e.id: e,
    };

    final csv = buildCsv([
      [
        'collection',
        'kind',
        'place',
        'city',
        'state',
        'country',
        'date_acquired',
        'trip_or_occasion',
        'who_gave_it',
        'rating',
        'notes',
        'photo',
      ],
      for (final i in items)
        [
          byId[i.collectionId]?.name,
          byId[i.collectionId]?.itemNoun,
          i.place,
          i.city,
          i.state,
          i.country,
          i.dateAcquired?.toIso8601String().substring(0, 10),
          i.tripOrOccasion,
          i.whoGaveIt,
          entries[i.journalEntryId]?.rating,
          entries[i.journalEntryId]?.notes,
          i.photoPath,
        ],
    ]);

    return shareStampedFile(
      share: _share,
      tempDir: _tempDir,
      baseName: 'pocketcurio-souvenirs',
      extension: 'csv',
      mimeType: 'text/csv',
      shareText: 'Pocket Curio souvenirs',
      text: csv,
      now: now,
    );
  }

  /// Everything as one zip: export JSON plus every photo file.
  Future<File> shareBackup({
    required int lifetimeCollections,
    required int lifetimeItems,
    DateTime? now,
  }) async {
    final bytes = buildBackupArchive(
      exportData: await buildExportData(
        _db,
        lifetimeCollections: lifetimeCollections,
        lifetimeItems: lifetimeItems,
        now: now,
      ),
      media: await collectPhotoMedia(_db, _store),
    );
    return shareStampedFile(
      share: _share,
      tempDir: _tempDir,
      baseName: 'pocketcurio-backup',
      extension: 'zip',
      mimeType: 'application/zip',
      shareText: 'Pocket Curio backup',
      bytes: bytes,
      now: now,
    );
  }
}
