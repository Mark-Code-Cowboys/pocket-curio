import 'dart:math' as math;

import 'package:cc_core/cc_core.dart' hide PhotoSource;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/photos/photo_capture.dart';
import '../../core/photos/photo_providers.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/item_photo.dart';
import '../../data/providers.dart';
import '../../data/repositories/item_repository.dart';
import '../scan/guided_crop_screen.dart';
import '../scan/place_reader.dart';
import '../scan/scan_providers.dart';

/// Camera-first: the camera opens on arrival, then the place field takes
/// focus. Photo + place is the whole required path; the memory fields
/// sit behind "Add the memory". Pass [existing] to edit.
class ItemComposerScreen extends ConsumerStatefulWidget {
  const ItemComposerScreen({
    super.key,
    required this.collectionId,
    this.existing,
  });

  final int collectionId;
  final ItemWithStory? existing;

  @override
  ConsumerState<ItemComposerScreen> createState() => _ItemComposerScreenState();
}

class _ItemComposerScreenState extends ConsumerState<ItemComposerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeFocus = FocusNode();
  late final _place = TextEditingController(text: widget.existing?.item.place);
  late final _city = TextEditingController(text: widget.existing?.item.city);
  late final _state = TextEditingController(text: widget.existing?.item.state);
  late final _country = TextEditingController(text: widget.existing?.item.country);
  late final _trip = TextEditingController(
    text: widget.existing?.item.tripOrOccasion,
  );
  late final _from = TextEditingController(text: widget.existing?.item.whoGaveIt);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late DateTime? _dateAcquired = widget.existing?.item.dateAcquired;
  late int? _rating = widget.existing?.rating;

  /// Relative path in the photo store. For a new item this file is ours
  /// to delete if the user backs out.
  late String? _photoPath = widget.existing?.item.photoPath;
  late bool _showMemory = widget.existing != null;
  var _capturing = false;
  var _saved = false;

  /// What the camera read off the photo, verbatim, for the chips under
  /// the Place field. Empty until a photo is taken this session.
  var _readLines = const <String>[];
  var _placeFromPhoto = false;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    if (_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _capture(PhotoSource.camera);
      });
    }
  }

  @override
  void dispose() {
    _placeFocus.dispose();
    for (final c in [_place, _city, _state, _country, _trip, _from, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _capture(PhotoSource source) async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final sourcePath = await ref.read(photoCaptureProvider).capture(source);
      if (sourcePath == null || !mounted) return;
      final store = ref.read(photoStoreProvider);
      final previous = _photoPath;
      final imported = await store.import(sourcePath);
      // A retake on a new item, or a replacement on an edit, orphans the
      // earlier file. Edits only drop the old file once saved (see _save).
      if (_isNew && previous != null) await store.delete(previous);
      final reading = await _readPlace(sourcePath);
      if (!mounted) return;
      setState(() {
        _photoPath = imported;
        _readLines = reading.lines;
        // Prefill only an empty field, with exactly what was printed.
        if (_place.text.trim().isEmpty && reading.primary != null) {
          _place.text = reading.primary!;
          _placeFromPhoto = true;
        }
      });
      if (_place.text.trim().isEmpty) _placeFocus.requestFocus();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// Transcribes what's printed on the souvenir. A recognizer failure
  /// just means no prefill — the user types the place as before.
  Future<PlaceReading> _readPlace(String path) async {
    try {
      final lines = await ref
          .read(textRecognitionServiceProvider)
          .recognize(path);
      return readPlace(lines);
    } on Exception {
      return PlaceReading.empty;
    }
  }

  /// Tighten the photo to the souvenir: one box on the guided-crop
  /// screen, the engine cuts it, and the place is read again off the
  /// crop (a tight frame reads better). Same ownership rules as a
  /// retake: a new item's previous file goes now, an edit's original
  /// only once saved.
  Future<void> _crop() async {
    final current = _photoPath;
    if (current == null || _capturing) return;
    final store = ref.read(photoStoreProvider);
    final cropper = ref.read(photoCropperProvider);
    final sourcePath = store.resolve(current).path;
    final size = await cropper.imageSize(sourcePath);
    if (!mounted) return;
    final boxes = await Navigator.of(context).push<List<Rect>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GuidedCropScreen(
          imagePath: sourcePath,
          imageSize: size,
          single: true,
        ),
      ),
    );
    if (boxes == null || boxes.isEmpty || !mounted) return;
    setState(() => _capturing = true);
    try {
      final cropPath = await cropper.crop(sourcePath, boxes.single);
      final imported = await store.import(cropPath);
      if (_isNew) await store.delete(current);
      final reading = await _readPlace(cropPath);
      if (!mounted) return;
      setState(() {
        _photoPath = imported;
        if (reading.lines.isNotEmpty) _readLines = reading.lines;
        if (_place.text.trim().isEmpty && reading.primary != null) {
          _place.text = reading.primary!;
          _placeFromPhoto = true;
        }
      });
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateAcquired ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateAcquired = picked);
  }

  String? _opt(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Take a photo first — that’s the record.'),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final draft = ItemDraft(
      photoPath: _photoPath!,
      place: _place.text.trim(),
      city: _opt(_city),
      state: _opt(_state),
      country: _opt(_country),
      dateAcquired: _dateAcquired,
      tripOrOccasion: _opt(_trip),
      whoGaveIt: _opt(_from),
      rating: _rating,
      notes: _opt(_notes),
      lat: widget.existing?.item.lat,
      lng: widget.existing?.item.lng,
    );
    final repo = ref.read(itemRepositoryProvider);
    final existing = widget.existing;
    if (existing == null) {
      await repo.createItem(widget.collectionId, draft);
    } else {
      await repo.updateItem(existing.item.id, draft);
      if (existing.item.photoPath != draft.photoPath) {
        await ref.read(photoStoreProvider).delete(existing.item.photoPath);
      }
    }
    _saved = true;
    if (mounted) Navigator.of(context).pop();
  }

  /// Backing out of a new item leaves no orphan file behind.
  Future<void> _discardIfAbandoned() async {
    if (_saved || !_isNew) return;
    final path = _photoPath;
    if (path != null) await ref.read(photoStoreProvider).delete(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _discardIfAbandoned();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'New souvenir' : 'Edit souvenir'),
          actions: [TextButton(onPressed: _save, child: const Text('Save'))],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _photoPanel(theme),
              const SizedBox(height: 20),
              TextFormField(
                controller: _place,
                focusNode: _placeFocus,
                decoration: InputDecoration(
                  labelText: 'Place',
                  hintText: 'What’s printed on it, or where it’s from',
                  helperText: _placeFromPhoto
                      ? 'Read from the photo — check the spelling.'
                      : null,
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_placeFromPhoto) setState(() => _placeFromPhoto = false);
                },
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Where is it from?'
                    : null,
              ),
              if (_readLines.isNotEmpty) _readChips(theme),
              const SizedBox(height: 16),
              if (!_showMemory)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showMemory = true),
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: const Text('Add the memory'),
                  ),
                )
              else
                ..._memoryFields(theme),
            ],
          ),
        ),
      ),
    );
  }

  /// Every line the camera read, as chips: tap one to use it as the
  /// place. Verbatim — nothing is suggested that wasn't printed.
  Widget _readChips(ThemeData theme) {
    final current = _place.text.trim().toLowerCase();
    final others = _readLines.where((l) => l.toLowerCase() != current).toList();
    if (others.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: -6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Also read:', style: theme.textTheme.labelSmall),
          for (final line in others)
            ActionChip(
              label: Text(line),
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() {
                _place.text = line;
                _placeFromPhoto = true;
              }),
            ),
        ],
      ),
    );
  }

  Widget _photoPanel(ThemeData theme) {
    final path = _photoPath;
    // 4:3 of the width on a phone, but never more than 40% of the height,
    // so the Place field is on screen the moment the photo lands.
    final size = MediaQuery.sizeOf(context);
    final panelHeight = math.min((size.width - 32) * 3 / 4, size.height * 0.4);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: panelHeight,
            width: double.infinity,
            child: path == null
                ? Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: _capturing
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_camera_outlined,
                                size: 56,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'The photo is the record.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                  )
                : ItemPhoto(path: path),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            FilledButton.tonalIcon(
              onPressed: _capturing ? null : () => _capture(PhotoSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: Text(path == null ? 'Take photo' : 'Retake'),
            ),
            if (path != null)
              TextButton.icon(
                onPressed: _capturing ? null : _crop,
                icon: const Icon(Icons.crop),
                label: const Text('Crop'),
              ),
            TextButton.icon(
              onPressed: _capturing
                  ? null
                  : () => _capture(PhotoSource.library),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose from library'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _memoryFields(ThemeData theme) => [
    Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _city,
            decoration: const InputDecoration(labelText: 'City'),
            textCapitalization: TextCapitalization.words,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _state,
            decoration: const InputDecoration(labelText: 'State'),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _country,
            decoration: const InputDecoration(labelText: 'Country'),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
      ],
    ),
    const SizedBox(height: 12),
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(
        _dateAcquired == null
            ? 'When did you get it?'
            : formatDate(_dateAcquired!),
      ),
      trailing: _dateAcquired == null
          ? null
          : IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear date',
              onPressed: () => setState(() => _dateAcquired = null),
            ),
      onTap: _pickDate,
    ),
    TextFormField(
      controller: _trip,
      decoration: const InputDecoration(
        labelText: 'Trip or occasion',
        hintText: 'Honeymoon, the 2019 road trip…',
      ),
      textCapitalization: TextCapitalization.sentences,
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: _from,
      decoration: const InputDecoration(
        labelText: 'Who gave it to you?',
        hintText: 'Leave blank if you picked it up yourself',
      ),
      textCapitalization: TextCapitalization.words,
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        const Text('How much do you love it?'),
        const SizedBox(width: 12),
        RatingStars(
          rating: _rating,
          onChanged: (r) => setState(() => _rating = r),
        ),
      ],
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _notes,
      decoration: const InputDecoration(
        labelText: 'The memory',
        hintText: 'What happened that day?',
        alignLabelWithHint: true,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 4,
    ),
  ];
}
