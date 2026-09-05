import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/item_photo.dart';
import '../../data/providers.dart';
import '../../data/repositories/item_repository.dart';
import '../monetization/gate.dart';

/// One crop from the shelf photo, under review.
class ShelfCandidate {
  ShelfCandidate({
    required this.photoPath,
    required this.place,
    required this.readLines,
  });

  /// Relative path in the photo store (already imported).
  final String photoPath;

  /// Place as read, edited in place during review.
  String place;

  /// Every line the camera read on this crop, verbatim.
  final List<String> readLines;

  bool kept = true;
}

/// The review grid: every crop with the place the camera read, editable,
/// and one bulk-confirm. Resolves to how many were added, or null when
/// the user backs out (nothing saved).
///
/// GUARDRAIL (cc_core scan): values shown verbatim; the user edits,
/// nothing here suggests or corrects.
class ShelfReviewScreen extends ConsumerStatefulWidget {
  const ShelfReviewScreen({
    super.key,
    required this.collectionId,
    required this.candidates,
    this.unreadableCount = 0,
  });

  final int collectionId;
  final List<ShelfCandidate> candidates;

  /// Crops whose recognition threw (not merely blank).
  final int unreadableCount;

  @override
  ConsumerState<ShelfReviewScreen> createState() => _ShelfReviewScreenState();
}

class _ShelfReviewScreenState extends ConsumerState<ShelfReviewScreen> {
  late final _controllers = [
    for (final c in widget.candidates) TextEditingController(text: c.place),
  ];
  var _saving = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<ShelfCandidate> get _kept =>
      widget.candidates.where((c) => c.kept).toList();

  bool get _ready =>
      _kept.isNotEmpty && _kept.every((c) => c.place.trim().isNotEmpty);

  Future<void> _confirm() async {
    final kept = _kept;
    if (!await ensureCanAddItems(context, ref, kept.length)) return;
    if (!mounted) return;
    setState(() => _saving = true);
    await ref.read(itemRepositoryProvider).createItems(widget.collectionId, [
      for (final c in kept)
        ItemDraft(photoPath: c.photoPath, place: c.place.trim()),
    ]);
    if (mounted) Navigator.of(context).pop(kept.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kept = _kept.length;
    final total = widget.candidates.length;
    final subtitle = [
      '$total ${total == 1 ? 'souvenir' : 'souvenirs'} read from the photo.',
      if (widget.unreadableCount > 0)
        '${widget.unreadableCount} couldn’t be read — type those in.',
      'Check the spelling; the camera reads exactly what’s printed.',
    ].join(' ');
    return Scaffold(
      appBar: AppBar(title: const Text('Check what was read')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: total,
              itemBuilder: (context, i) => _CandidateTile(
                candidate: widget.candidates[i],
                controller: _controllers[i],
                onChanged: () => setState(() {}),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _ready && !_saving ? _confirm : null,
                child: Text(
                  kept == 0 ? 'Nothing selected' : 'Add $kept to the shelf',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.controller,
    required this.onChanged,
  });

  final ShelfCandidate candidate;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alternatives = candidate.readLines
        .where((l) => l.toLowerCase() != candidate.place.trim().toLowerCase())
        .take(3)
        .toList();
    final missing = candidate.kept && candidate.place.trim().isEmpty;
    return Opacity(
      opacity: candidate.kept ? 1 : 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ItemPhoto(path: candidate.photoPath),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Material(
                      color: theme.colorScheme.surface.withValues(alpha: 0.85),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                      child: Checkbox(
                        value: candidate.kept,
                        onChanged: (v) {
                          candidate.kept = v ?? false;
                          onChanged();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: candidate.kept,
            decoration: InputDecoration(
              labelText: 'Place',
              isDense: true,
              errorText: missing ? 'Needs a place' : null,
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              candidate.place = v;
              onChanged();
            },
          ),
          if (alternatives.isNotEmpty && candidate.kept) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: -8,
              children: [
                for (final line in alternatives)
                  ActionChip(
                    label: Text(line, overflow: TextOverflow.ellipsis),
                    labelStyle: theme.textTheme.labelSmall,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      controller.text = line;
                      candidate.place = line;
                      onChanged();
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
