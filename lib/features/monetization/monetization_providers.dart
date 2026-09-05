import 'dart:async';

import 'package:cc_core/cc_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'entitlements.dart';
import 'free_limit.dart';

final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  final service = StoreEntitlementService(
    ref.watch(kvStoreProvider),
    pcStoreProducts,
  );
  // Fire-and-forget lapse check; the cache answers until it lands.
  unawaited(service.refreshEntitlements());
  ref.onDispose(service.dispose);
  return service;
});

/// True when Pro is owned — the lifetime unlock or an active monthly
/// subscription (cc_core's `isUnlimited` covers both). Defaults to
/// false while loading so gating stays conservative.
final isProProvider = StreamProvider<bool>(
  (ref) => ref.watch(entitlementServiceProvider).watchUnlimited(),
);

/// Store failure messages (failed purchases, restore/refresh errors)
/// so an open paywall sheet can show why nothing happened.
final storeErrorsProvider = StreamProvider<String>(
  (ref) => ref.watch(entitlementServiceProvider).storeErrors,
);

/// Collections ever created on this device, live.
final lifetimeCollectionsProvider = StreamProvider<int>(
  (ref) => ref.watch(collectionRepositoryProvider).watchLifetimeCreated(),
);

/// Items ever created on this device across all shelves, live.
final lifetimeItemsProvider = StreamProvider<int>(
  (ref) => ref.watch(itemRepositoryProvider).watchLifetimeCreated(),
);

/// Null while entitlements or the count are still loading, and null
/// whenever the cap doesn't apply (Pro owned) — so counter UI simply
/// disappears for paying users and never flashes at them on startup.
final collectionUsageProvider = Provider<FreeLimitUsage?>((ref) {
  final pro = ref.watch(isProProvider).value;
  final count = ref.watch(lifetimeCollectionsProvider).value;
  if (pro == null || pro || count == null) return null;
  return collectionFreeLimit.usage(count);
});

/// See [collectionUsageProvider].
final itemUsageProvider = Provider<FreeLimitUsage?>((ref) {
  final pro = ref.watch(isProProvider).value;
  final count = ref.watch(lifetimeItemsProvider).value;
  if (pro == null || pro || count == null) return null;
  return itemFreeLimit.usage(count);
});
