import 'package:cc_core/cc_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/export/share_plus_launcher.dart';
import 'core/photos/photo_providers.dart';
import 'core/photos/photo_store.dart';
import 'data/database/app_database.dart';
import 'data/database/seed.dart';
import 'data/providers.dart';
import 'features/monetization/monetization_providers.dart';
import 'features/scan/scan_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  final photos = await PhotoStore.open();

  // Screenshot data: `flutter run --dart-define=DEMO_SEED=true`. The
  // demo build also runs as Pro so the map fills in and the free-tier
  // counter is out of the shots; never the uploaded AAB.
  const demo = bool.fromEnvironment('DEMO_SEED');
  if (demo) await seedDemoData(db, photos);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        photoStoreProvider.overrideWithValue(photos),
        shareLauncherProvider.overrideWithValue(SharePlusLauncher()),
        tempDirProvider.overrideWithValue(getTemporaryDirectory),
        textRecognitionServiceProvider.overrideWithValue(
          MlKitTextRecognitionService(),
        ),
        if (demo)
          entitlementServiceProvider.overrideWithValue(
            FakeEntitlementService(unlimited: true),
          ),
      ],
      child: const PocketCurioApp(),
    ),
  );
}
