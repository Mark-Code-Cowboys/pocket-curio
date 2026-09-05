import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/labels.dart';
import '../../core/widgets/item_photo.dart';
import '../../data/providers.dart';
import '../../data/repositories/collection_repository.dart';
import '../collections/collection_screen.dart';
import '../monetization/free_tier_counter.dart';

/// The collections grid: each shelf as a tile with its cover photo and
/// item count. Multiple shelves per install serves a household.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(collectionSummariesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pocket Curio')),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty ? _empty(context) : _grid(context, list),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_travel, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'A souvenir is a place + a memory.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a collection — keychains, magnets, whatever you '
              'bring home — then photograph the first one.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(BuildContext context, List<CollectionSummary> list) {
    final theme = Theme.of(context);
    final totalItems = list.fold(0, (sum, s) => sum + s.itemCount);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverList.list(
            children: [
              Text(
                countHeadline(items: totalItems, collections: list.length),
                style: theme.textTheme.headlineSmall,
              ),
              // Invisible for Pro owners; taps open the paywall.
              const FreeTierCounter(margin: EdgeInsets.only(top: 8)),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) => _CollectionTile(summary: list[i]),
          ),
        ),
      ],
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.summary});

  final CollectionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collection = summary.collection;
    final count = summary.itemCount;
    final noun = collection.itemNoun;
    final countLine = switch (count) {
      0 => 'Nothing here yet',
      1 => '1 $noun',
      _ => '$count ${_plural(noun)}',
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CollectionScreen(collectionId: collection.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ItemPhoto(
                path: summary.coverPhotoPath,
                placeholderIcon: Icons.add_a_photo_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    countLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Good enough for the kinds we ship ("shot glasses", "patches",
/// "snow globes"); a custom label that already ends in s stays as is.
String _plural(String noun) {
  if (noun.endsWith('s')) return noun;
  if (noun.endsWith('ch') || noun.endsWith('sh') || noun.endsWith('x')) {
    return '${noun}es';
  }
  return '${noun}s';
}
