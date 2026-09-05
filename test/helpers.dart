import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:pocket_curio/core/photos/photo_capture.dart';
import 'package:pocket_curio/core/photos/photo_providers.dart';
import 'package:pocket_curio/core/photos/photo_store.dart';
import 'package:pocket_curio/core/theme/app_theme.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/providers.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';
import 'package:pocket_curio/features/shell/home_shell.dart';

AppDatabase makeTestDb() => AppDatabase(NativeDatabase.memory());

/// A photo store rooted in a fresh temp directory, removed on teardown.
PhotoStore makeTestStore() {
  final dir = Directory.systemTemp.createTempSync('pocket_curio_test_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return PhotoStore(dir);
}

/// 1×1 transparent PNG — a real image so Image.file decodes in tests.
final tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

/// Stands in for the camera: hands back a fresh PNG each time, or null
/// when [cancel] is set (user backed out). Records the sources asked for.
class FakeCapture implements PhotoCapture {
  FakeCapture({this.cancel = false});

  bool cancel;
  final sources = <PhotoSource>[];
  var _n = 0;

  @override
  Future<String?> capture(PhotoSource source) async {
    sources.add(source);
    if (cancel) return null;
    final dir = Directory.systemTemp.createTempSync('pocket_curio_cam_');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });
    final file = File(p.join(dir.path, 'shot_${_n++}.png'));
    file.writeAsBytesSync(tinyPng);
    return file.path;
  }
}

/// The app wired to an in-memory database and temp photo store; [home]
/// defaults to the shell. A given [home] is pushed above a blank root
/// route so screens that pop themselves (composers, deletes) land
/// somewhere instead of emptying the Navigator.
Widget testApp({
  required AppDatabase db,
  PhotoStore? store,
  PhotoCapture? capture,
  Widget? home,
}) => ProviderScope(
  overrides: [
    databaseProvider.overrideWithValue(db),
    photoStoreProvider.overrideWithValue(store ?? makeTestStore()),
    photoCaptureProvider.overrideWithValue(capture ?? FakeCapture()),
  ],
  child: MaterialApp(
    theme: AppTheme.light(),
    home: home == null
        ? const HomeShell()
        : _RouteHost(key: ObjectKey(home), child: home),
  ),
);

class _RouteHost extends StatefulWidget {
  const _RouteHost({super.key, required this.child});

  final Widget child;

  @override
  State<_RouteHost> createState() => _RouteHostState();
}

class _RouteHostState extends State<_RouteHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => widget.child));
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

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
}) => CollectionDraft(
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
}) => ItemDraft(
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
