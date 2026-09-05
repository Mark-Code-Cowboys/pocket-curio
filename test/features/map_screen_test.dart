import 'dart:io';
import 'dart:ui';

import 'package:cc_core/cc_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/export/export_service.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';
import 'package:pocket_curio/features/map/map_screen.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = makeTestDb());
  tearDown(() => db.close());

  Future<void> seed() async {
    final magnets = await CollectionRepository(
      db,
    ).createCollection(collectionDraft(name: 'Fridge magnets'));
    final items = ItemRepository(db);
    await items.createItem(
      magnets,
      itemDraft(
        place: 'Key West',
        state: 'Florida',
        country: null,
        dateAcquired: DateTime(2019, 3, 2),
        photoPath: 'a.png',
      ),
    );
    await items.createItem(
      magnets,
      itemDraft(
        place: 'Mackinac',
        state: 'MI',
        country: 'usa',
        dateAcquired: DateTime(2021, 7, 4),
        photoPath: 'b.png',
      ),
    );
    await items.createItem(
      magnets,
      itemDraft(
        place: 'Zermatt',
        state: null,
        country: 'Switzerland',
        photoPath: 'c.png',
      ),
    );
    await items.createItem(
      magnets,
      itemDraft(
        place: 'Banff',
        state: 'Alberta',
        country: 'Canada',
        dateAcquired: DateTime(2019, 8, 1),
        photoPath: 'd.png',
      ),
    );
  }

  testWidgets('free users see the teaser with restore, not the map', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(db: db, home: const MapScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Watch the world fill in.'), findsOneWidget);
    expect(find.text('See Pocket Curio Pro'), findsOneWidget);
    expect(find.text('Restore a backup'), findsOneWidget);
    expect(find.text('The States'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('Pro map: counters, continents, states, countries, years', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await seed();

    await tester.pumpWidget(
      testApp(
        db: db,
        entitlements: FakeEntitlementService(unlimited: true),
        home: const MapScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('4 souvenirs'), findsOneWidget);
    expect(find.text('3 countries'), findsOneWidget);
    expect(find.text('3 states'), findsOneWidget); // FL, MI, ALBERTA
    expect(find.text('North America · Europe'), findsOneWidget);
    expect(find.text('The States'), findsOneWidget);
    expect(find.text('United States · 2'), findsOneWidget);
    expect(find.text('Canada · 1'), findsOneWidget);
    expect(find.text('Switzerland · 1'), findsOneWidget);
    expect(find.text('Souvenirs by year'), findsOneWidget);
    expect(find.text('1 without a date aren’t counted here.'), findsOneWidget);
    expect(find.text('The oldest'), findsOneWidget);
    expect(find.text('Key West — Mar 2, 2019'), findsOneWidget);
    await disposeApp(tester);
  });

  test('MapFacts fills only real US states and known continents', () async {
    await seed();
    final facts = MapFacts(await ItemRepository(db).watchAllItems().first);
    expect(facts.usStates, {'FL', 'MI'});
    expect(facts.states, {'FL', 'MI', 'ALBERTA'});
    expect(facts.continents, {'NA', 'EU'});
    expect(facts.perYear, {2019: 2, 2021: 1});
    expect(facts.undated, 1);
    expect(facts.oldest?.place, 'Key West');
  });

  testWidgets('empty Pro map invites the first souvenir', (tester) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        entitlements: FakeEntitlementService(unlimited: true),
        home: const MapScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 souvenirs'), findsOneWidget);
    expect(
      find.textContaining('starts filling in with the first one'),
      findsOneWidget,
    );
    expect(find.text('The States'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('CSV and backup buttons hand files to the share sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await seed();
    final share = FakeShareLauncher();

    await tester.pumpWidget(
      testApp(
        db: db,
        share: share,
        entitlements: FakeEntitlementService(unlimited: true),
        home: const MapScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Share souvenirs as CSV'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back up everything'));
    await tester.pumpAndSettle();

    expect(share.sharedFiles, hasLength(2));
    expect(share.sharedFiles[0], endsWith('.csv'));
    expect(share.sharedFiles[1], endsWith('.zip'));
    final csv = File(share.sharedFiles[0]).readAsStringSync();
    expect(csv, startsWith('collection,kind,place,city,state,country,'));
    expect(
      csv,
      contains('Fridge magnets,magnet,Key West,,Florida,,2019-03-02'),
    );
    final contents = readBackupArchive(
      File(share.sharedFiles[1]).readAsBytesSync(),
    );
    expect(contents.exportData['app'], 'PocketCurio');
    expect((contents.exportData['items'] as List), hasLength(4));
    await disposeApp(tester);
  });

  test('ExportService writes a stamped CSV with one row per item', () async {
    await seed();
    final share = FakeShareLauncher();
    final dir = Directory.systemTemp.createTempSync('pocket_curio_export_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final service = ExportService(db, makeTestStore(), share, () async => dir);

    final file = await service.shareItemsCsv(now: DateTime(2026, 9, 5));
    expect(file.path, endsWith('pocketcurio-souvenirs-2026-09-05.csv'));
    final lines = file.readAsStringSync().trim().split('\r\n');
    expect(lines, hasLength(5));
    expect(share.sharedFiles, [file.path]);
  });
}
