import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Everything the app links out to lives on pocketcurio.app. The site
/// mirrors the Table Encore layout (help, FAQ, user guide, privacy), so
/// the paths are the same shape across the CC apps.
abstract final class PocketCurioLinks {
  static final site = Uri.parse('https://pocketcurio.app/');
  static final help = Uri.parse('https://pocketcurio.app/help/');
  static final faq = Uri.parse('https://pocketcurio.app/faq/');
  static final userGuide = Uri.parse('https://pocketcurio.app/user-guide/');
  static final privacy = Uri.parse('https://pocketcurio.app/privacy/');

  /// Apple's standard EULA — what the App Store listing declares, and
  /// what guideline 3.1.2 wants linked from the paywall and description.
  static final terms = Uri.parse(
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
  );
}

/// Opens [url] outside the app; false when nothing could handle it.
typedef LinkOpener = Future<bool> Function(Uri url);

Future<bool> _openExternally(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

/// Tests swap in a recorder; the app hands links to the system browser.
final linkOpenerProvider = Provider<LinkOpener>((_) => _openExternally);
