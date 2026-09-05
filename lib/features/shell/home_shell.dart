import 'package:flutter/material.dart';

import '../collections/collection_composer_screen.dart';
import '../home/home_screen.dart';

/// Home plus the one action it offers. The Map tab joins in Phase E.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreen(),
      floatingActionButton: FloatingActionButton.extended(
        // Phase C wraps this in the FreeLimit(1, 'collections') gate.
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const CollectionComposerScreen(),
            fullscreenDialog: true,
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New collection'),
      ),
    );
  }
}
