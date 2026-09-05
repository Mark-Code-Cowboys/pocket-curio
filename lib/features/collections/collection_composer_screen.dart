import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/labels.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/collection_repository.dart';

/// Start or rename a shelf. Pass [existing] to edit. Pops with the
/// collection id on save, null when dismissed.
class CollectionComposerScreen extends ConsumerStatefulWidget {
  const CollectionComposerScreen({super.key, this.existing});

  final Collection? existing;

  @override
  ConsumerState<CollectionComposerScreen> createState() =>
      _CollectionComposerScreenState();
}

class _CollectionComposerScreenState
    extends ConsumerState<CollectionComposerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _otherLabel = TextEditingController(
    text: widget.existing?.otherLabel,
  );
  late CollectionKind _kind = widget.existing?.kind ?? CollectionKind.magnet;

  @override
  void dispose() {
    _name.dispose();
    _otherLabel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final other = _otherLabel.text.trim();
    final draft = CollectionDraft(
      name: _name.text.trim(),
      kind: _kind,
      otherLabel: other.isEmpty ? null : other,
      coverPhotoPath: widget.existing?.coverPhotoPath,
    );
    final repo = ref.read(collectionRepositoryProvider);
    final existing = widget.existing;
    final int id;
    if (existing == null) {
      id = await repo.createCollection(draft);
    } else {
      id = existing.id;
      await repo.updateCollection(existing.id, draft);
    }
    // Resolves to the collection id so a caller can land on the shelf.
    if (mounted) Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNew = widget.existing == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New collection' : 'Edit collection'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: isNew,
              decoration: const InputDecoration(
                labelText: 'Collection name',
                hintText: 'Fridge magnets, Dad’s keychains…',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Name the collection'
                  : null,
            ),
            const SizedBox(height: 20),
            Text('What do you collect?', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in CollectionKind.values)
                  ChoiceChip(
                    label: Text(k.label),
                    selected: _kind == k,
                    onSelected: (_) => setState(() => _kind = k),
                  ),
              ],
            ),
            if (_kind == CollectionKind.other) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _otherLabel,
                decoration: const InputDecoration(
                  labelText: 'What is one called?',
                  hintText: 'snow globe',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Give it a name so we can say “your first snow globe”'
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
