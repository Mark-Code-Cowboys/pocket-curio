import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../photos/photo_providers.dart';

/// A stored photo, or a quiet placeholder when there is none (or the
/// file has gone missing).
class ItemPhoto extends ConsumerWidget {
  const ItemPhoto({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.photo_outlined,
  });

  /// Relative path in the photo store; null shows the placeholder.
  final String? path;
  final BoxFit fit;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = this.path;
    if (path == null) return _Placeholder(icon: placeholderIcon);
    final file = ref.watch(photoStoreProvider).resolve(path);
    if (!file.existsSync()) return _Placeholder(icon: placeholderIcon);
    return Image.file(
      file,
      fit: fit,
      errorBuilder: (_, _, _) => _Placeholder(icon: placeholderIcon),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(icon, color: scheme.onSurfaceVariant, size: 32),
    );
  }
}
