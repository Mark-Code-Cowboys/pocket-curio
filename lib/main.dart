import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/photos/photo_providers.dart';
import 'core/photos/photo_store.dart';
import 'data/database/app_database.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  final photos = await PhotoStore.open();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        photoStoreProvider.overrideWithValue(photos),
      ],
      child: const PocketCurioApp(),
    ),
  );
}
