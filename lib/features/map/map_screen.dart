
import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backup/backup_service.dart';
import '../../core/export/export_service.dart';
import '../../core/photos/photo_providers.dart';
import '../../core/photos/photo_store.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/geo.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../monetization/monetization_providers.dart';
import '../monetization/paywall_sheet.dart';

/// The emotional payoff: where all of it came from. Pro-gated behind a
/// teaser; restoring your own backup is never gated.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pro = ref.watch(isProProvider).value ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('The map')),
      body: pro ? const _MapContent() : const _ProTeaser(),
    );
  }
}

class _ProTeaser extends ConsumerWidget {
  const _ProTeaser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Watch the world fill in.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Every state and country your souvenirs came from, lit up '
              'one place at a time, plus export and backup — part of '
              'Pocket Curio Pro.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => showPaywallSheet(context),
              child: const Text('See Pocket Curio Pro'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            TextButton.icon(
              icon: const Icon(Icons.settings_backup_restore),
              label: const Text('Restore a backup'),
              onPressed: () => restoreBackupFlow(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

/// Everything the map derives from the items, computed once per build.
class MapFacts {
  MapFacts(List<Item> items) {
    for (final i in items) {
      final state = normalizeState(i.state);
      final country = normalizeCountry(i.country, state: i.state);
      if (state != null) states.add(state);
      if (country != null) {
        countryCounts[country] = (countryCounts[country] ?? 0) + 1;
        final continent = continentOf(country);
        if (continent != null) continents.add(continent);
      }
      final when = i.dateAcquired;
      if (when == null) {
        undated++;
      } else {
        perYear[when.year] = (perYear[when.year] ?? 0) + 1;
        if (oldest == null || when.isBefore(oldest!.dateAcquired!)) {
          oldest = i;
        }
      }
    }
  }

  final states = <String>{};
  final countryCounts = <String, int>{};
  final continents = <String>{};
  final perYear = <int, int>{};
  var undated = 0;
  Item? oldest;

  Set<String> get usStates => states.where(isUsState).toSet();
}

class _MapContent extends ConsumerWidget {
  const _MapContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(allItemsProvider).value;
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final facts = MapFacts(items);
    final countries = facts.countryCounts.keys.toList()
      ..sort(
        (a, b) => facts.countryCounts[b]!.compareTo(facts.countryCounts[a]!),
      );

    Widget section(String title, Widget child, {String? note}) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          if (note != null)
            Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        section(
          'So far',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(count: items.length, label: 'souvenirs'),
              _StatChip(count: facts.countryCounts.length, label: 'countries'),
              _StatChip(
                count: facts.states.length,
                label: 'states and provinces',
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Text(
              'Photograph a souvenir and type where it’s from — the map '
              'starts filling in with the first one.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else ...[
          section(
            'The world',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegionTileGrid(
                  tiles: continentTiles,
                  filled: facts.continents,
                ),
                const SizedBox(height: 6),
                Text(
                  facts.continents.isEmpty
                      ? 'Add a country to a souvenir to light a continent.'
                      : continentTiles
                            .where((t) => facts.continents.contains(t.code))
                            .map((t) => continentNames[t.code])
                            .join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          section(
            'The States',
            RegionTileGrid(tiles: usStateTiles, filled: facts.usStates),
            note: facts.usStates.isEmpty
                ? 'Give a souvenir a state and its tile lights up.'
                : null,
          ),
          if (countries.isNotEmpty)
            section(
              'Countries',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in countries)
                    Chip(
                      label: Text(
                        '${countryName(c)} · ${facts.countryCounts[c]}',
                      ),
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          if (facts.perYear.isNotEmpty)
            section(
              'Souvenirs by year',
              YearlyBars(countsByYear: facts.perYear),
              note: facts.undated > 0
                  ? '${facts.undated} without a date aren’t counted here.'
                  : null,
            ),
          if (facts.oldest != null)
            section(
              'The oldest',
              Text(
                '${facts.oldest!.place} — ${formatDate(facts.oldest!.dateAcquired!)}',
                style: theme.textTheme.bodyLarge,
              ),
            ),
        ],
        section(
          'Yours to keep',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Share souvenirs as CSV'),
                onPressed: () => _shareCsv(context, ref),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Back up everything'),
                onPressed: () => _shareBackup(context, ref),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text('Restore a backup'),
                onPressed: () => restoreBackupFlow(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ExportService _exporter(WidgetRef ref) => ExportService(
    ref.read(databaseProvider),
    ref.read(photoStoreProvider),
    ref.read(shareLauncherProvider),
    ref.read(tempDirProvider),
  );

  Future<void> _shareCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _exporter(ref).shareItemsCsv();
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _shareBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _exporter(ref).shareBackup(
        lifetimeCollections: await ref
            .read(collectionRepositoryProvider)
            .lifetimeCreated(),
        lifetimeItems: await ref.read(itemRepositoryProvider).lifetimeCreated(),
      );
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text('$count $label'),
      labelStyle: theme.textTheme.bodyMedium,
    );
  }
}

/// The shared cc_core restore flow with Pocket Curio's own words and
/// restore steps (rows, both tallies, and deleting the files the OLD
/// rows referenced — photos are big; stale ones don't get to squat).
/// Free users can do this — getting your own collection back is never
/// gated.
Future<void> restoreBackupFlow(BuildContext context, WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final store = ref.read(photoStoreProvider);
  await runRestoreFlow(
    context,
    confirmBody:
        'Everything on this phone is replaced with the backup — every '
        'collection, souvenir, and photo. This can\u2019t be undone.',
    photoStore: PhotoStoreService(store),
    restore: (contents) async {
      final previous = await referencedPhotoPaths(db);
      final tallies = await restoreFromExportData(db, contents.exportData);
      for (final path in previous) {
        await store.delete(path);
      }
      await ref.read(collectionTallyProvider).raiseTo(tallies.collections);
      await ref.read(itemTallyProvider).raiseTo(tallies.items);
    },
  );
}
