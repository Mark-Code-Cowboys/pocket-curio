import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'repositories/collection_repository.dart';
import 'repositories/item_repository.dart';

/// Overridden in main() with the real on-device database, and in tests
/// with an in-memory one.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepository(ref.watch(databaseProvider)),
);

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => ItemRepository(ref.watch(databaseProvider)),
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
