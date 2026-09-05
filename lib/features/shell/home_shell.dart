import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../collections/collection_composer_screen.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../monetization/gate.dart';

/// Home and the Map, one action each way.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _index = 0;

  static const _screens = [HomeScreen(), MapScreen()];

  /// Gated: a second collection past the free one opens the paywall
  /// instead; unlocking mid-flow continues into the composer.
  Future<void> _addCollection() async {
    if (!await ensureCanAdd(context, ref, GatedAction.addCollection)) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CollectionComposerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: _addCollection,
              icon: const Icon(Icons.add),
              label: const Text('New collection'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Shelves',
          ),
          NavigationDestination(icon: Icon(Icons.public), label: 'Map'),
        ],
      ),
    );
  }
}
