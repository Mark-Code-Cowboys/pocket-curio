import 'package:cc_core/cc_core.dart';
import 'package:share_plus/share_plus.dart';

/// The real share sheet, wrapping share_plus; tests use cc_core's
/// FakeShareLauncher.
class SharePlusLauncher implements ShareLauncher {
  @override
  Future<void> shareFile(String path, {String? mimeType, String? text}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: mimeType)],
        text: text,
      ),
    );
  }

  @override
  Future<void> shareText(
    String text, {
    List<String> imagePaths = const [],
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: imagePaths.isEmpty
            ? null
            : [for (final p in imagePaths) XFile(p, mimeType: 'image/jpeg')],
      ),
    );
  }
}
