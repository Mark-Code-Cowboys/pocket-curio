import 'dart:ui' as ui;

import 'package:cc_core/cc_core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/painting.dart';

import '../../core/photos/photo_store.dart';
import 'app_database.dart';

/// Renders a stand-in souvenir photo: [label] on a [color] ground.
/// Injected so the seed is testable without the engine's rasterizer.
typedef DemoPhotoPainter =
    Future<Uint8List> Function(String label, Color color);

/// Demo shelves for screenshots and store listing shots:
/// `flutter run --dart-define=DEMO_SEED=true`
///
/// Two collections (a magnet collector and a keychain collector sharing
/// one phone), 30 souvenirs across 12 US states and 4 countries, with
/// the kind of memories the app exists for. Every item gets a rendered
/// placeholder photo in the store, because the photo IS the record.
/// No-op unless the phone is empty, so a real shelf is never polluted.
Future<void> seedDemoData(
  AppDatabase db,
  PhotoStore store, {
  DemoPhotoPainter paint = paintDemoPhoto,
}) async {
  final journal = db.journal();
  final existing = await db.select(db.collections).get();
  if (existing.isNotEmpty) return;

  var tint = 0;
  Future<String> photo(String label) async {
    final color = _palette[tint++ % _palette.length];
    final bytes = await paint(label, color);
    final path = 'photos/demo_${tint.toString().padLeft(2, '0')}.png';
    await store.write(path, bytes);
    return path;
  }

  Future<int> collection(String name, CollectionKind kind) => db
      .into(db.collections)
      .insert(CollectionsCompanion.insert(name: name, kind: kind));

  Future<void> item(
    int collectionId,
    String place, {
    String? city,
    String? state,
    String? country,
    DateTime? when,
    String? trip,
    String? from,
    int? rating,
    String? memory,
  }) async {
    int? entryId;
    if (rating != null || memory != null) {
      entryId = await journal
          .createEntry(JournalEntryDraft(notes: memory, rating: rating));
    }
    await db
        .into(db.items)
        .insert(
          ItemsCompanion.insert(
            collectionId: collectionId,
            photoPath: await photo(place),
            place: place,
            city: Value(city),
            state: Value(state),
            country: Value(country ?? (state != null ? 'US' : null)),
            dateAcquired: Value(when),
            tripOrOccasion: Value(trip),
            whoGaveIt: Value(from),
            journalEntryId: Value(entryId),
          ),
        );
  }

  // --- Mom's fridge magnets (18) ---
  final magnets = await collection('Mom’s fridge', CollectionKind.magnet);
  await item(
    magnets,
    'Mackinac Island',
    state: 'MI',
    when: DateTime(1998, 7, 12),
    trip: 'The first family trip',
    rating: 5,
    memory:
        'Fudge on the ferry. Dad swore he’d never eat it again. '
        'He bought two more boxes.',
  );
  await item(
    magnets,
    'Sleeping Bear Dunes',
    state: 'MI',
    when: DateTime(2003, 8, 2),
    trip: 'Dune climb',
    rating: 4,
    memory: 'Ran down. Crawled up. Sand in the car until October.',
  );
  await item(
    magnets,
    'Key West',
    city: 'Key West',
    state: 'FL',
    when: DateTime(2007, 3, 19),
    trip: 'Spring break with Aunt Jo',
    from: 'Aunt Jo',
    rating: 5,
    memory: 'Southernmost point, sunburn included.',
  );
  await item(
    magnets,
    'Niagara Falls',
    state: 'NY',
    when: DateTime(2009, 6, 6),
    trip: 'Anniversary',
    rating: 4,
    memory: 'Soaked on the Maid of the Mist. Worth it.',
  );
  await item(
    magnets,
    'Gatlinburg',
    state: 'TN',
    when: DateTime(2011, 10, 8),
    trip: 'Leaf-peeping',
    memory: 'Pancakes three mornings running.',
  );
  await item(
    magnets,
    'Nashville',
    state: 'TN',
    when: DateTime(2011, 10, 10),
    from: 'Uncle Ray',
    memory: 'Ray sang. Nobody asked him to.',
  );
  await item(
    magnets,
    'Grand Canyon',
    state: 'AZ',
    when: DateTime(2013, 4, 22),
    trip: 'The big road trip',
    rating: 5,
    memory: 'Stood at the rim for an hour and nobody said a word.',
  );
  await item(
    magnets,
    'Sedona',
    state: 'AZ',
    when: DateTime(2013, 4, 24),
    trip: 'The big road trip',
    memory: 'Red rocks, red faces.',
  );
  await item(
    magnets,
    'Las Vegas',
    state: 'NV',
    when: DateTime(2013, 4, 26),
    trip: 'The big road trip',
    rating: 2,
    memory: 'Lost forty dollars and a hat.',
  );
  await item(
    magnets,
    'Yellowstone',
    state: 'WY',
    when: DateTime(2016, 7, 3),
    trip: 'Fortieth anniversary',
    rating: 5,
    memory:
        'Old Faithful went off right on time. Dad checked his watch '
        'like he’d arranged it.',
  );
  await item(
    magnets,
    'Mount Rushmore',
    state: 'SD',
    when: DateTime(2016, 7, 6),
    trip: 'Fortieth anniversary',
    memory: 'Smaller than you think. Gift shop bigger than you think.',
  );
  await item(
    magnets,
    'Chicago',
    state: 'IL',
    when: DateTime(2018, 12, 15),
    trip: 'Christmas market',
    memory: 'Deep dish, deep cold.',
  );
  await item(
    magnets,
    'New Orleans',
    state: 'LA',
    when: DateTime(2019, 2, 28),
    trip: 'Girls’ weekend',
    from: 'Linda',
    rating: 5,
    memory: 'Beignets at 2 a.m. Linda still owes me a cab fare.',
  );
  await item(
    magnets,
    'Savannah',
    state: 'GA',
    when: DateTime(2019, 3, 2),
    trip: 'Girls’ weekend',
    memory: 'Spanish moss and sweet tea.',
  );
  await item(
    magnets,
    'Niagara Falls',
    city: 'Niagara Falls',
    state: 'ON',
    country: 'Canada',
    when: DateTime(2009, 6, 7),
    trip: 'Anniversary',
    memory: 'The Canadian side. Better view, worse parking.',
  );
  await item(
    magnets,
    'Cancún',
    country: 'Mexico',
    when: DateTime(2015, 1, 20),
    trip: 'Escaping January',
    rating: 4,
    memory: 'First time out of the country. Kept the wristband for a year.',
  );
  await item(
    magnets,
    'Dublin',
    country: 'Ireland',
    when: DateTime(2022, 9, 9),
    trip: 'The Ireland trip we talked about for twenty years',
    rating: 5,
    memory: 'Rained every day. Best trip of our lives.',
  );
  await item(
    magnets,
    'Cliffs of Moher',
    country: 'Ireland',
    when: DateTime(2022, 9, 12),
    trip: 'The Ireland trip',
    memory: 'Wind nearly took the magnet off the rack in the shop.',
  );

  // --- Dad's keychains (12) ---
  final keychains = await collection(
    'Dad’s keychains',
    CollectionKind.keychain,
  );
  await item(
    keychains,
    'Detroit',
    state: 'MI',
    when: DateTime(1984, 10, 14),
    rating: 5,
    memory: 'Tigers won it all. The keychain outlived two cars.',
  );
  await item(
    keychains,
    'Cooperstown',
    state: 'NY',
    when: DateTime(1996, 8, 3),
    trip: 'Hall of Fame weekend',
    from: 'Mom',
    rating: 5,
    memory: 'Mom bought it while I was still in the plaque gallery.',
  );
  await item(
    keychains,
    'Wrigley Field',
    city: 'Chicago',
    state: 'IL',
    when: DateTime(2001, 6, 30),
    memory: 'Bleachers. Sunburn. Cubs lost.',
  );
  await item(
    keychains,
    'Fenway Park',
    city: 'Boston',
    state: 'MA',
    when: DateTime(2004, 9, 11),
    trip: 'Ballpark tour',
    rating: 4,
    memory: 'Sat on the Monster. Could see the whole city.',
  );
  await item(
    keychains,
    'Yankee Stadium',
    city: 'New York',
    state: 'NY',
    when: DateTime(2004, 9, 13),
    trip: 'Ballpark tour',
    memory: 'Hot dogs in the bleachers. Dad booed politely.',
  );
  await item(
    keychains,
    'Cape Cod',
    state: 'MA',
    when: DateTime(2004, 9, 15),
    trip: 'Ballpark tour, the detour',
    memory: 'Lobster roll, no regrets.',
  );
  await item(
    keychains,
    'Route 66',
    state: 'AZ',
    when: DateTime(2013, 4, 20),
    trip: 'The big road trip',
    memory:
        'Bought at a gas station that was '
        'also a museum that was also a diner.',
  );
  await item(
    keychains,
    'Hoover Dam',
    state: 'NV',
    when: DateTime(2013, 4, 25),
    trip: 'The big road trip',
    memory: 'Stood in two states at once.',
  );
  await item(
    keychains,
    'Navy Pier',
    city: 'Chicago',
    state: 'IL',
    when: DateTime(2017, 5, 5),
    trip: 'Visiting Jenny',
    from: 'Jenny',
    rating: 4,
    memory: 'Jenny’s first apartment. Fourth floor, no elevator.',
  );
  await item(
    keychains,
    'Traverse City',
    state: 'MI',
    when: DateTime(2020, 8, 18),
    memory: 'Bought it at the airport on the way home. Counts.',
  );
  await item(
    keychains,
    'Toronto',
    state: 'ON',
    country: 'Canada',
    when: DateTime(2009, 6, 8),
    trip: 'Anniversary',
    memory: 'Blue Jays game. Roof open. Perfect night.',
  );
  await item(
    keychains,
    'Blarney Castle',
    country: 'Ireland',
    when: DateTime(2022, 9, 11),
    trip: 'The Ireland trip',
    rating: 3,
    memory: 'Kissed the stone. Still not eloquent.',
  );
}

const _palette = [
  Color(0xFF7A4E7E), // curio violet
  Color(0xFFB07AA1),
  Color(0xFF5C7A99),
  Color(0xFF8A9A5B),
  Color(0xFFC98B5B),
  Color(0xFF9E5B5B),
  Color(0xFF5B8A8A),
  Color(0xFF8C6D46),
];

/// A 600×600 PNG: the place name set large over a colored ground, the
/// way a printed souvenir reads.
Future<Uint8List> paintDemoPhoto(String label, Color color) async {
  const size = 600.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, size, size),
    Paint()..color = color,
  );
  final plate = RRect.fromRectAndRadius(
    const Rect.fromLTWH(60, 200, 480, 200),
    const Radius.circular(24),
  );
  canvas.drawRRect(plate, Paint()..color = const Color(0xFFF6F1E7));
  final text = TextPainter(
    text: TextSpan(
      text: label.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: label.length > 9 ? 44 : 60,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    maxLines: 2,
  )..layout(maxWidth: 440);
  text.paint(
    canvas,
    Offset((size - text.width) / 2, plate.center.dy - text.height / 2),
  );
  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
