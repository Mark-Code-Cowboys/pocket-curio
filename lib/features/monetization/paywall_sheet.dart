import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'free_limit.dart';
import 'monetization_providers.dart';

/// Shows the Pro sheet. Resolves true if the user owns Pro when the
/// sheet closes (purchase or restore completed while it was open).
/// [highlight] is the reason it opened ("25 of 25 free items used").
Future<bool> showPaywallSheet(BuildContext context, {String? highlight}) async {
  final result = await showPaywallModal<bool>(
    context,
    builder: (context) => _PaywallSheet(highlight: highlight),
  );
  return result ?? false;
}

class _PaywallSheet extends ConsumerWidget {
  const _PaywallSheet({this.highlight});

  final String? highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifetimePrice = ref.watch(_lifetimePriceProvider).value;
    final monthlyPrice = ref.watch(_monthlyPriceProvider).value;
    final service = ref.read(entitlementServiceProvider);

    // Close with success the moment the entitlement lands.
    ref.listen(isProProvider, (_, next) {
      if (next.value == true && context.mounted) {
        Navigator.of(context).pop(true);
      }
    });

    // Purchase-stream failures land asynchronously; show them here so
    // "nothing happened" always has a visible reason.
    ref.listen(storeErrorsProvider, (_, next) {
      final message = next.value;
      if (message != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return PaywallSheetScaffold(
      icon: Icons.card_travel,
      title: 'Pocket Curio Pro',
      highlight: highlight,
      body:
          'Your first collection and your first $kFreeItemLimit souvenirs '
          'are free, always — nothing you\'ve photographed is ever locked '
          'away. Pro is the whole shelf: every souvenir, every collector '
          'in the house, and the map filling in. No account. Your '
          'photos still never leave this phone.',
      benefits: const [
        PaywallBenefit(
          icon: Icons.all_inclusive,
          title: 'Every souvenir, every shelf',
          detail:
              'Unlimited collections and items — one phone, the '
              'whole household.',
        ),
        PaywallBenefit(
          icon: Icons.public,
          title: 'The map',
          detail: 'Watch the world fill in, one place at a time.',
        ),
        PaywallBenefit(
          icon: Icons.ios_share_outlined,
          title: 'Export and backup',
          detail: 'Your collection, yours to keep — full backup and export.',
        ),
      ],
      primaryLabel: lifetimePrice == null
          ? 'Yours forever'
          : 'Yours forever · $lifetimePrice',
      onPrimary: () => runStoreAction(context, service.buyUnlimited),
      footnote: 'One-time. Makes a good gift.',
      restoreLabel: 'Restore purchase',
      onRestore: () => runStoreAction(context, service.restorePurchases),
      extraActions: [
        TextButton(
          onPressed: () => runStoreAction(context, service.buyPremium),
          child: Text(
            monthlyPrice == null
                ? 'Or month to month'
                : 'Or month to month · $monthlyPrice',
          ),
        ),
      ],
      onLater: () => Navigator.of(context).pop(false),
    );
  }
}

final _lifetimePriceProvider = FutureProvider.autoDispose<String?>(
  (ref) => ref.watch(entitlementServiceProvider).unlimitedPrice(),
);

final _monthlyPriceProvider = FutureProvider.autoDispose<String?>(
  (ref) => ref.watch(entitlementServiceProvider).premiumPrice(),
);
