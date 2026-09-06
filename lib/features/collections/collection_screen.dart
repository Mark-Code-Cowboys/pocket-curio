import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/photos/photo_providers.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/item_photo.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/item_repository.dart';
import '../items/item_composer_screen.dart';
import '../items/item_detail_screen.dart';
import '../../core/photos/photo_capture.dart';
import '../monetization/gate.dart';
import '../scan/shelf_scan_flow.dart';
import 'collection_composer_screen.dart';

/// What a freshly named shelf should do the moment it appears — the
/// onboarding fork lands here with the first move already chosen.
enum ShelfStart { addItem, scanShelf }

/// The digital display shelf: a photo grid of one collection.
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({
    super.key,
    required this.collectionId,
    this.initialAction,
  });

  final int collectionId;

  /// Runs once after the first frame; null does nothing.
  final ShelfStart? initialAction;

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  var _sort = ItemSort.byDate;

  @override
  void initState() {
    super.initState();
    final start = widget.initialAction;
    if (start != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (start) {
          case ShelfStart.addItem:
            _addItem();
          case ShelfStart.scanShelf:
            _scanShelf();
        }
      });
    }
  }

  Future<void> _confirmDelete(Collection collection) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete “${collection.name}”?'),
        content: const Text(
          'Every photo and memory on this shelf goes with it. '
          'This can’t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final items = ref.read(itemRepositoryProvider);
    final store = ref.read(photoStoreProvider);
    final shelf = await items.itemsForCollection(collection.id);
    // Journal entries don't cascade across the raw FK — collect and
    // delete them BEFORE the collection cascade takes the item rows.
    await items.deleteEntriesForCollection(collection.id);
    await ref
        .read(collectionRepositoryProvider)
        .deleteCollection(collection.id);
    for (final item in shelf) {
      await store.delete(item.photoPath);
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Gated: the 26th souvenir on this phone opens the paywall instead;
  /// unlocking mid-flow continues into the composer.
  Future<void> _addItem() async {
    if (!await ensureCanAdd(context, ref, GatedAction.addItem)) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemComposerScreen(collectionId: widget.collectionId),
        fullscreenDialog: true,
      ),
    );
  }

  /// One photo of the whole shelf or fridge, boxed by hand, read and
  /// added in bulk. The converter for people with 40 magnets already up.
  Future<void> _scanShelf() async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Scan the whole shelf'),
              subtitle: Text(
                'One photo of everything. You box each souvenir, the '
                'camera reads what’s printed, you check it.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo of the shelf'),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose a photo'),
              onTap: () => Navigator.of(context).pop(PhotoSource.library),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final added = await runShelfScan(
      context,
      ref,
      collectionId: widget.collectionId,
      source: source,
    );
    if (added > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $added ${added == 1 ? 'souvenir' : 'souvenirs'} to the shelf.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = ref.watch(collectionProvider(widget.collectionId)).value;
    if (collection == null) {
      // Deleted out from under us (or still loading the first frame).
      return const Scaffold(body: SizedBox.shrink());
    }
    final items = ref
        .watch(
          itemsForCollectionProvider((
            collectionId: widget.collectionId,
            sort: _sort,
          )),
        )
        .value;
    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on_outlined),
            tooltip: 'Scan the whole shelf',
            onPressed: _scanShelf,
          ),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'edit' => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CollectionComposerScreen(existing: collection),
                ),
              ),
              _ => _confirmDelete(collection),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit collection')),
              PopupMenuItem(value: 'delete', child: Text('Delete collection')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.photo_camera),
        label: Text('Add ${collection.itemNoun}'),
      ),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? _empty(context, collection)
          : _shelf(context, items),
    );
  }

  /// Written for the gift recipient opening the app for the first time.
  Widget _empty(BuildContext context, Collection collection) {
    final theme = Theme.of(context);
    final noun = collection.itemNoun;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Photograph your first $noun.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Point the camera at it and type where it’s from. '
              'That’s the whole first step — the memory can come later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _scanShelf,
              icon: const Icon(Icons.grid_on_outlined),
              label: const Text('Already have a shelf full? Scan it'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shelf(BuildContext context, List<Item> items) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<ItemSort>(
                segments: const [
                  ButtonSegment(value: ItemSort.byDate, label: Text('Date')),
                  ButtonSegment(value: ItemSort.byPlace, label: Text('Place')),
                ],
                selected: {_sort},
                onSelectionChanged: (s) => setState(() => _sort = s.single),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _ShelfTile(item: items[i]),
          ),
        ),
      ],
    );
  }
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ItemDetailScreen(itemId: item.id),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ItemPhoto(path: item.photoPath),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                child: Text(
                  item.place,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
