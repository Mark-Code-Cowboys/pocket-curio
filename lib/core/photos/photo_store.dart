import 'dart:io';

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
