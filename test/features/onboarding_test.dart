import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/app.dart';
import 'package:pocket_curio/core/photos/photo_capture.dart';
import 'package:pocket_curio/core/photos/photo_providers.dart';
import 'package:pocket_curio/core/theme/app_theme.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/providers.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/features/monetization/monetization_providers.dart';
import 'package:pocket_curio/features/scan/scan_providers.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = makeTestDb());
  tearDown(() => db.close());

  Widget rootApp(KeyValueStore store, {PhotoCapture? capture}) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      kvStoreProvider.overrideWithValue(store),
      photoStoreProvider.overrideWithValue(makeTestStore()),
      photoCaptureProvider.overrideWithValue(capture ?? FakeCapture()),
      entitlementServiceProvider.overrideWithValue(FakeEntitlementService()),
      textRecognitionServiceProvider.overrideWithValue(
        FakeTextRecognitionService(),
      ),
      photoCropperProvider.overrideWithValue(FakeCropper()),
      shareLauncherProvider.overrideWithValue(FakeShareLauncher()),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: const AppRoot()),
  );

  testWidgets('first run leads with the framing, the promise, and the fork', (
    tester,
  ) async {
    final store = InMemoryKeyValueStore();
    await tester.pumpWidget(rootApp(store));
    await tester.pumpAndSettle();

    expect(find.text('A souvenir is a place + a memory.'), findsOneWidget);
    expect(find.textContaining('Not an inventory.'), findsOneWidget);
    expect(find.text(kPrivacyBoilerplate), findsOneWidget);
    expect(find.text('Scan my whole fridge or shelf'), findsOneWidget);
    expect(find.text('Photograph my first souvenir'), findsOneWidget);

    await tester.tap(find.text('Just look around'));
    await tester.pumpAndSettle();

    // Swapped to the shell, and the flag persisted.
    expect(find.text('Pocket Curio'), findsOneWidget);
    expect(find.text('Shelves'), findsOneWidget);
    expect(await FirstRunFlag(store).seen(), isTrue);
    await disposeApp(tester);
  });

  testWidgets('returning users go straight to the shell', (tester) async {
    final store = InMemoryKeyValueStore();
    await FirstRunFlag(store).markSeen();

    await tester.pumpWidget(rootApp(store));
    await tester.pumpAndSettle();

    expect(find.text('Just look around'), findsNothing);
    expect(find.text('Pocket Curio'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets(
    'the photograph fork names the shelf, opens the camera, lands on it',
    (tester) async {
      final capture = FakeCapture();
      await tester.pumpWidget(
        rootApp(InMemoryKeyValueStore(), capture: capture),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Photograph my first souvenir'));
      await tester.pumpAndSettle();
      expect(find.text('New collection'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Collection name'),
        'Fridge magnets',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // The camera opened without another tap, on the new shelf.
      expect(capture.sources, [PhotoSource.camera]);
      expect(find.text('New souvenir'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Place'),
        'Mackinac Island',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // On the shelf with the tile; backing out reaches the shell.
      expect(find.text('Fridge magnets'), findsOneWidget);
      expect(find.text('Mackinac Island'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Shelves'), findsOneWidget);
      expect(find.text('Just look around'), findsNothing);
      await disposeApp(tester);
    },
  );

  testWidgets('the scan fork names the shelf and opens the shelf-scan sheet', (
    tester,
  ) async {
    await tester.pumpWidget(rootApp(InMemoryKeyValueStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scan my whole fridge or shelf'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Collection name'),
      'Mom’s fridge',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Scan the whole shelf'), findsWidgets);
    expect(find.text('Take a photo of the shelf'), findsOneWidget);
    expect((await tester.runAsync(() => CollectionRepository(db).count())), 1);
    await disposeApp(tester);
  });

  testWidgets('backing out of the shelf name returns to onboarding', (
    tester,
  ) async {
    final store = InMemoryKeyValueStore();
    await tester.pumpWidget(rootApp(store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Photograph my first souvenir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    // Nothing was created, but they're through: the shell, not a loop.
    expect(find.text('Shelves'), findsOneWidget);
    expect(await FirstRunFlag(store).seen(), isTrue);
    await disposeApp(tester);
  });
}
