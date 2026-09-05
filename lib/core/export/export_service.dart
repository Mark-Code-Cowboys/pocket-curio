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

  static String _stamp(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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
          i.rating,
          i.notes,
          i.photoPath,
        ],
    ]);

    final stamp = _stamp(now ?? DateTime.now());
    final file = File(
      '${(await _tempDir()).path}/pocketcurio-souvenirs-$stamp.csv',
    );
    file.writeAsStringSync(csv);
    await _share.shareFile(
      file.path,
      mimeType: 'text/csv',
      text: 'Pocket Curio souvenirs ($stamp)',
    );
    return file;
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
    final stamp = _stamp(now ?? DateTime.now());
    final file = File(
      '${(await _tempDir()).path}/pocketcurio-backup-$stamp.zip',
    );
    file.writeAsBytesSync(bytes);
    await _share.shareFile(
      file.path,
      mimeType: 'application/zip',
      text: 'Pocket Curio backup ($stamp)',
    );
    return file;
  }
}
