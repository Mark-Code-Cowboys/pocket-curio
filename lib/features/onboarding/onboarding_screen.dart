import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../collections/collection_composer_screen.dart';
import '../collections/collection_screen.dart';

/// First run seen? Refreshed after onboarding completes.
final firstRunSeenProvider = FutureProvider<bool>(
  (ref) => FirstRunFlag(ref.watch(kvStoreProvider)).seen(),
);

/// The first thing a new user reads is the framing — a souvenir is a
/// place plus a memory, not inventory — then the fork: people with a
/// fridge already covered start with the shelf scan, everyone else
/// with one photograph or a look around.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _finish(WidgetRef ref) async {
    await FirstRunFlag(ref.read(kvStoreProvider)).markSeen();
    ref.invalidate(firstRunSeenProvider);
  }

  /// Name the shelf first (everything lives on one), then land on it
  /// with the chosen first move already underway. This screen stays
  /// alive under the pushed routes and swaps to the shell at the end.
  Future<void> _startWith(
    BuildContext context,
    WidgetRef ref,
    ShelfStart start,
  ) async {
    final navigator = Navigator.of(context);
    final collectionId = await navigator.push<int>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CollectionComposerScreen(),
      ),
    );
    if (collectionId != null) {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => CollectionScreen(
            collectionId: collectionId,
            initialAction: start,
          ),
        ),
      );
    }
    await _finish(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingScaffold(
      icon: Icons.card_travel,
      positioning: 'A souvenir is a place + a memory.',
      subtitle:
          'Not an inventory. Pocket Curio is the shelf you can carry — '
          'photograph each keychain, magnet, or shot glass, name where '
          'it’s from, and watch the map fill in.',
      actions: [
        FilledButton.icon(
          icon: const Icon(Icons.grid_on_outlined),
          label: const Text('Scan my whole fridge or shelf'),
          onPressed: () => _startWith(context, ref, ShelfStart.scanShelf),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Photograph my first souvenir'),
          onPressed: () => _startWith(context, ref, ShelfStart.addItem),
        ),
        TextButton(
          onPressed: () => _finish(ref),
          child: const Text('Just look around'),
        ),
      ],
    );
  }
}
