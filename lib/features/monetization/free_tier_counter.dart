import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'monetization_providers.dart';
import 'paywall_sheet.dart';

/// "1 of 1 free collections used" / "12 of 25 free items used" — shows
/// free users exactly where the shelf stands, with a bar per limit.
/// Renders nothing for Pro owners (and while entitlements are still
/// loading, so it never flashes at them).
class FreeTierCounter extends ConsumerWidget {
  const FreeTierCounter({
    super.key,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 0),
  });

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionUsageProvider);
    final items = ref.watch(itemUsageProvider);
    if (collections == null || items == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(12);
    final atLimit = collections.atLimit || items.atLimit;

    return Padding(
      padding: margin,
      child: Material(
        color: atLimit
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => showPaywallSheet(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Icon(
                  atLimit ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _UsageLine(usage: collections),
                      const SizedBox(height: 8),
                      _UsageLine(usage: items),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => showPaywallSheet(context),
                  child: const Text('Go Pro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UsageLine extends StatelessWidget {
  const _UsageLine({required this.usage});

  final FreeLimitUsage usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(usage.label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (usage.used / usage.limit).clamp(0, 1),
            minHeight: 6,
            backgroundColor: theme.colorScheme.surface,
          ),
        ),
        const SizedBox(height: 4),
        Text(usage.detail, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
