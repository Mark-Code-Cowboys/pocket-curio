import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'free_limit.dart';
import 'monetization_providers.dart';
import 'paywall_sheet.dart';

/// The two gated actions in the app. Everything else — editing, reading,
/// deleting, the map, the shelf — is never gated.
enum GatedAction { addCollection, addItem }

/// True when the user may proceed with [action]: under the free cap, or
/// Pro is owned, or they unlocked Pro from the paywall this opened.
/// Unlocking mid-flow continues into the composer.
Future<bool> ensureCanAdd(
  BuildContext context,
  WidgetRef ref,
  GatedAction action,
) async {
  final entitled = await ref.read(entitlementServiceProvider).isUnlimited();
  final (limit, used) = switch (action) {
    GatedAction.addCollection => (
      collectionFreeLimit,
      await ref.read(collectionRepositoryProvider).lifetimeCreated(),
    ),
    GatedAction.addItem => (
      itemFreeLimit,
      await ref.read(itemRepositoryProvider).lifetimeCreated(),
    ),
  };
  try {
    limit.guard(used: used, entitled: entitled);
    return true;
  } on FreeLimitReachedException {
    if (!context.mounted) return false;
    return showPaywallSheet(context, highlight: limit.usage(used).label);
  }
}

/// Batch flavor of [ensureCanAdd] for the shelf scan: may [count] more
/// items be added? Under the cap or Pro → true; otherwise the paywall,
/// and true only if they unlock from it.
Future<bool> ensureCanAddItems(
  BuildContext context,
  WidgetRef ref,
  int count,
) async {
  if (await ref.read(entitlementServiceProvider).isUnlimited()) return true;
  final used = await ref.read(itemRepositoryProvider).lifetimeCreated();
  if (used + count <= kFreeItemLimit) return true;
  if (!context.mounted) return false;
  final usage = itemFreeLimit.usage(used);
  return showPaywallSheet(
    context,
    highlight: '${usage.label} — $count more won’t fit',
  );
}
