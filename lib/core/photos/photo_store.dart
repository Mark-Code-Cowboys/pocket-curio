import 'dart:io';

import 'package:cc_core/cc_core.dart' as cc;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// App-private photo files. Rows store paths *relative* to [root] so the
/// database survives the iOS container moving between app updates.
///
/// The API is Future-based so a cc_core extraction can go truly async,
/// but the work is done with synchronous IO on purpose: a capture is one
/// ≤2048px JPEG (a few ms to copy), and synchronous IO completes inside
/// flutter_test's fake-async zone where dart:io futures never resolve.
///
/// cc_core candidate: every photo-first CC app needs exactly this
/// (docs/cc-core-gaps.md).
class PhotoStore {
  PhotoStore(this.root);

  /// The application documents directory on device.
  static Future<PhotoStore> open() async =>
      PhotoStore(await getApplicationDocumentsDirectory());

  final Directory root;

  static const _folder = 'photos';

  File resolve(String relativePath) => File(p.join(root.path, relativePath));

  /// Copies a captured file into the store and returns its relative path.
  Future<String> import(String sourcePath) async {
    final dir = Directory(p.join(root.path, _folder));
    dir.createSync(recursive: true);
    var ext = p.extension(sourcePath).toLowerCase();
    if (ext.isEmpty) ext = '.jpg';
    final name = '${DateTime.now().microsecondsSinceEpoch}$ext';
    File(sourcePath).copySync(p.join(dir.path, name));
    return p.join(_folder, name);
  }

  /// Writes [bytes] at [relativePath], creating folders as needed —
  /// how a backup's photos come back.
  Future<void> write(String relativePath, List<int> bytes) async {
    final file = resolve(relativePath);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
  }

  Future<void> delete(String relativePath) async {
    final file = resolve(relativePath);
    if (file.existsSync()) file.deleteSync();
  }
}

/// cc_core [cc.PhotoService] face over [PhotoStore], for the shared
/// restore flow's media loop (and any future journal photo use).
/// Capture stays app-side (the guided-crop flow); acquire is unused.
class PhotoStoreService implements cc.PhotoService {
  PhotoStoreService(this.store);

  final PhotoStore store;

  @override
  Future<String?> acquire(cc.PhotoSource source) async => null;

  @override
  Future<String?> acquireTransient(cc.PhotoSource source) async => null;

  @override
  File fileFor(String photoPath) =>
      store.resolve(p.join(PhotoStore._folder, photoPath));

  @override
  Future<void> importBytes(String photoPath, List<int> bytes) =>
      store.write(p.join(PhotoStore._folder, photoPath), bytes);

  @override
  Future<void> discard(String photoPath) =>
      store.delete(p.join(PhotoStore._folder, photoPath));
}
