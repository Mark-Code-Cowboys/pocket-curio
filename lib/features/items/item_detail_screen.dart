import 'dart:math' as math;

import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/photos/photo_providers.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/item_photo.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/item_repository.dart';
import 'item_composer_screen.dart';

/// One souvenir and its memory.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final int itemId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove “${item.place}”?'),
        content: const Text(
          'The photo and its memory are deleted from '
          'this phone. This can’t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final collections = ref.read(collectionRepositoryProvider);
    final collection = await collections.getCollection(item.collectionId);
    if (collection?.coverPhotoPath == item.photoPath) {
      await collections.setCoverPhoto(item.collectionId, null);
    }
    await ref.read(itemRepositoryProvider).deleteItem(item.id);
    await ref.read(photoStoreProvider).delete(item.photoPath);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _setAsCover(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    await ref
        .read(collectionRepositoryProvider)
        .setCoverPhoto(item.collectionId, item.photoPath);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Now the collection cover.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(itemWithStoryProvider(itemId)).value;
    if (story == null) {
      // Deleted out from under us (or still loading the first frame).
      return const Scaffold(body: SizedBox.shrink());
    }
    final item = story.item;
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final where = placeLine(
      city: item.city,
      state: item.state,
      country: item.country,
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ItemComposerScreen(
                  collectionId: item.collectionId,
                  existing: story,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'cover' => _setAsCover(context, ref, item),
              _ => _confirmDelete(context, ref, item),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'cover',
                child: Text('Use as collection cover'),
              ),
              PopupMenuItem(value: 'delete', child: Text('Remove')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // Square on a phone, but never more than half the screen, so the
          // place and memory are visible without scrolling.
          SizedBox(
            height: math.min(size.width, size.height * 0.5),
            child: ItemPhoto(path: item.photoPath, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.place, style: theme.textTheme.headlineSmall),
                if (where.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    where,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (story.rating != null) ...[
                  const SizedBox(height: 12),
                  RatingStars(rating: story.rating),
                ],
                const SizedBox(height: 20),
                _MemoryLine(
                  icon: Icons.event_outlined,
                  label: 'When',
                  value: item.dateAcquired == null
                      ? null
                      : formatDate(item.dateAcquired!),
                ),
                _MemoryLine(
                  icon: Icons.luggage_outlined,
                  label: 'Trip or occasion',
                  value: item.tripOrOccasion,
                ),
                _MemoryLine(
                  icon: Icons.redeem_outlined,
                  label: 'From',
                  value: item.whoGaveIt,
                ),
                if (story.notes != null && story.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(story.notes!, style: theme.textTheme.bodyLarge),
                ],
                if (_hasNoMemory(story)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'No memory written yet. Tap edit when it comes back '
                    'to you.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasNoMemory(ItemWithStory story) =>
      story.item.dateAcquired == null &&
      (story.item.tripOrOccasion ?? '').isEmpty &&
      (story.item.whoGaveIt ?? '').isEmpty &&
      (story.notes ?? '').isEmpty &&
      story.rating == null;
}

class _MemoryLine extends StatelessWidget {
  const _MemoryLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
