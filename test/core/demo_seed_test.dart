import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/utils/geo.dart';
import 'package:pocket_curio/data/database/seed.dart';

import '../helpers.dart';

void main() {
  final painted = <String>[];
  Future<Uint8List> fakePaint(String label, color) async {
    painted.add(label);
    return Uint8List.fromList(tinyPng);
  }

  setUp(painted.clear);

  test(
    'DEMO_SEED plants 2 collections, 30 items, 12 states, 4 countries',
    () async {
      final db = makeTestDb();
      addTearDown(db.close);
      final store = makeTestStore();

      await seedDemoData(db, store, paint: fakePaint);

      final collections = await db.select(db.collections).get();
      final items = await db.select(db.items).get();
      expect(collections, hasLength(2));
      expect(items, hasLength(30));

      final states = items
          .map((i) => normalizeState(i.state))
          .where(isUsState)
          .toSet();
      expect(states, hasLength(12));
      final countries = items
          .map((i) => normalizeCountry(i.country, state: i.state))
          .whereType<String>()
          .toSet();
      expect(countries, {'US', 'CA', 'MX', 'IE'});

      // Memories are the point — most items carry one, and every item is
      // dated so the map's by-year bars have something to show.
      expect(
        (await db.select(db.appJournalEntries).get())
            .where((e) => e.notes != null)
            .length,
        greaterThanOrEqualTo(25),
      );
      expect(items.every((i) => i.dateAcquired != null), isTrue);
      expect(
        (await db.select(db.appJournalEntries).get())
            .where((e) => e.rating != null)
            .length,
        greaterThanOrEqualTo(10),
      );

      // Every item's photo is a real file in the store.
      expect(painted, hasLength(30));
      for (final i in items) {
        expect(
          store.resolve(i.photoPath).existsSync(),
          isTrue,
          reason: i.place,
        );
      }
      expect(items.map((i) => i.photoPath).toSet(), hasLength(30));
    },
  );

  test('seeding is a no-op on a phone with data', () async {
    final db = makeTestDb();
    addTearDown(db.close);
    final store = makeTestStore();

    await seedDemoData(db, store, paint: fakePaint);
    await seedDemoData(db, store, paint: fakePaint); // must not duplicate

    expect(await db.select(db.items).get(), hasLength(30));
    expect(painted, hasLength(30));
  });

  testWidgets('paintDemoPhoto renders a real PNG', (tester) async {
    await tester.runAsync(() async {
      final bytes = await paintDemoPhoto('Key West', const Color(0xFF7A4E7E));
      // PNG signature.
      expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      expect(bytes.length, greaterThan(1000));
    });
  });
}
