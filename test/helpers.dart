import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/theme/app_theme.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/providers.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';
import 'package:pocket_curio/features/shell/home_shell.dart';

AppDatabase makeTestDb() => AppDatabase(NativeDatabase.memory());

/// The app wired to an in-memory database; [home] defaults to the shell.
Widget testApp({required AppDatabase db, Widget? home}) => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: home ?? const HomeShell(),
      ),
    );

/// Call at the end of every widget test that renders the app.
///
/// Disposing the ProviderScope cancels drift stream queries, which
/// schedule zero-duration cleanup timers; unmounting here and pumping
/// once lets them fire inside the test's fake-async zone instead of
/// tripping the pending-timer guard during final teardown.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

CollectionDraft collectionDraft({
  String name = 'Fridge magnets',
  CollectionKind kind = CollectionKind.magnet,
  String? otherLabel,
  String? coverPhotoPath,
}) =>
    CollectionDraft(
      name: name,
      kind: kind,
      otherLabel: otherLabel,
      coverPhotoPath: coverPhotoPath,
    );

ItemDraft itemDraft({
  String photoPath = 'items/0001.jpg',
  String place = 'Mackinac Island',
  String? city,
  String? state = 'MI',
  String? country = 'US',
  DateTime? dateAcquired,
  String? tripOrOccasion,
  String? whoGaveIt,
  int? rating,
  String? notes,
  double? lat,
  double? lng,
}) =>
    ItemDraft(
      photoPath: photoPath,
      place: place,
      city: city,
      state: state,
      country: country,
      dateAcquired: dateAcquired,
      tripOrOccasion: tripOrOccasion,
      whoGaveIt: whoGaveIt,
      rating: rating,
      notes: notes,
      lat: lat,
      lng: lng,
    );
