import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../collections/collection_composer_screen.dart';
import '../home/home_screen.dart';
import '../monetization/gate.dart';

/// Home plus the one action it offers. The Map tab joins in Phase E.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  /// Gated: a second collection past the free one opens the paywall
  /// instead; unlocking mid-flow continues into the composer.
  Future<void> _addCollection(BuildContext context, WidgetRef ref) async {
    if (!await ensureCanAdd(context, ref, GatedAction.addCollection)) return;
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CollectionComposerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const HomeScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCollection(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New collection'),
      ),
    );
  }
}
