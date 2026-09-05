import 'package:cc_core/cc_core.dart';

/// Free tier: one collection and this many items, forever. Existing
/// data is never gated — the limits only block *adding*, and they count
/// lifetime creations (see the tallies in data/providers.dart), so
/// deleting doesn't hand a slot back. These constants must only ever
/// move UP.
const kFreeCollectionLimit = 1;
const kFreeItemLimit = 25;

/// One shelf free. The second collection — the other collector in the
/// house — is Pro.
const collectionFreeLimit = FreeLimit(
  kFreeCollectionLimit,
  'collections',
  detailBuilder: _collectionDetail,
);

/// Twenty-five souvenirs free, across every shelf on this phone.
const itemFreeLimit = FreeLimit(
  kFreeItemLimit,
  'items',
  detailBuilder: _itemDetail,
);

String _collectionDetail(int remaining) => switch (remaining) {
  0 => 'One shelf is free. A second collection is Pocket Curio Pro.',
  _ => 'Your first collection is free, always.',
};

String _itemDetail(int remaining) => switch (remaining) {
  0 => 'The free shelf is full — Pro keeps every souvenir after this.',
  1 => 'Room for 1 more — then Pocket Curio Pro.',
  final n => 'Room for $n more — then Pocket Curio Pro.',
};
