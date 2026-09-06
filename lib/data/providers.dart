import 'dart:io';

import 'package:cc_core/cc_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'repositories/collection_repository.dart';
import 'repositories/item_repository.dart';

/// Overridden in main() with the real on-device database, and in tests
/// with an in-memory one.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Overridden in tests with [InMemoryKeyValueStore].
final kvStoreProvider = Provider<KeyValueStore>((ref) => SharedPrefsStore());

/// Collections ever created on this device; feeds the free tier so a
/// slot can't be recycled by delete-and-re-add.
final collectionTallyProvider = Provider<LifetimeTally>((ref) {
  final tally = LifetimeTally(
    ref.watch(kvStoreProvider),
    key: 'collections_created_lifetime',
  );
  ref.onDispose(tally.dispose);
  return tally;
});

/// Items ever created on this device, across every shelf.
final itemTallyProvider = Provider<LifetimeTally>((ref) {
  final tally = LifetimeTally(
    ref.watch(kvStoreProvider),
    key: 'items_created_lifetime',
  );
  ref.onDispose(tally.dispose);
  return tally;
});

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepository(
    ref.watch(databaseProvider),
    tally: ref.watch(collectionTallyProvider),
  ),
);

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => ItemRepository(
    ref.watch(databaseProvider),
    tally: ref.watch(itemTallyProvider),
  ),
);

final collectionSummariesProvider = StreamProvider<List<CollectionSummary>>(
  (ref) => ref.watch(collectionRepositoryProvider).watchSummaries(),
);

final collectionProvider = StreamProvider.family<Collection?, int>(
  (ref, id) => ref.watch(collectionRepositoryProvider).watchCollection(id),
);

/// Shelf contents keyed by (collection, sort).
final itemsForCollectionProvider =
    StreamProvider.family<List<Item>, ({int collectionId, ItemSort sort})>(
      (ref, key) => ref
          .watch(itemRepositoryProvider)
          .watchItemsForCollection(key.collectionId, sort: key.sort),
    );

final itemProvider = StreamProvider.family<Item?, int>(
  (ref, id) => ref.watch(itemRepositoryProvider).watchItem(id),
);

/// One item with its memory (journal entry), for detail and edit.
final itemWithStoryProvider = StreamProvider.family<ItemWithStory?, int>(
  (ref, id) => ref.watch(itemRepositoryProvider).watchItemWithStory(id),
);

/// Every item on the phone, for the map.
final allItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchAllItems(),
);

/// Overridden in main() with SharePlusLauncher, and in tests with
/// cc_core's FakeShareLauncher.
final shareLauncherProvider = Provider<ShareLauncher>(
  (ref) => throw UnimplementedError('shareLauncherProvider must be overridden'),
);

/// Overridden in main() with path_provider's temp dir, and in tests
/// with a system temp directory.
final tempDirProvider = Provider<Future<Directory> Function()>(
  (ref) => throw UnimplementedError('tempDirProvider must be overridden'),
);
