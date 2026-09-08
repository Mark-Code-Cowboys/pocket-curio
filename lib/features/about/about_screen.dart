import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/links.dart';
import '../monetization/monetization_providers.dart';
import '../monetization/paywall_sheet.dart';

/// Help & about: the way out to pocketcurio.app (user guide, help, FAQ,
/// privacy), the Pro status, restore, and the legal bits. Reached from
/// the home app bar; nothing here is gated.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pro = ref.watch(isProProvider).value ?? false;
    final service = ref.read(entitlementServiceProvider);

    Future<void> open(Uri url) async {
      final messenger = ScaffoldMessenger.of(context);
      final ok = await ref.read(linkOpenerProvider)(url);
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Couldn’t open the browser — visit ${url.host}${url.path}',
            ),
          ),
        );
      }
    }

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Help & about')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Icon(Icons.card_travel, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Center(
            child: Text('Pocket Curio', style: theme.textTheme.headlineSmall),
          ),
          Center(
            child: Text(
              'A souvenir is a place + a memory.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          header('Learn the app'),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('User guide'),
            subtitle: const Text(
              'Collections, the composer, the shelf scan, the map.',
            ),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => open(PocketCurioLinks.userGuide),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            subtitle: const Text('Something not working? Start here.'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => open(PocketCurioLinks.help),
          ),
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: const Text('FAQ'),
            subtitle: const Text(
              'Backups, the free tier, what the camera reads.',
            ),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => open(PocketCurioLinks.faq),
          ),
          const Divider(),
          header('Pocket Curio Pro'),
          if (pro)
            const ListTile(
              leading: Icon(Icons.star_rounded),
              title: Text('Pro active'),
              subtitle: Text(
                'Every collection, every souvenir, the map, backup and '
                'export — thank you for supporting Pocket Curio.',
              ),
            )
          else
            ListTile(
              leading: const Icon(Icons.star_outline_rounded),
              title: const Text('Go Pro'),
              subtitle: const Text(
                'Unlimited collections and souvenirs, the map, backup and '
                'export. One purchase, or month to month.',
              ),
              onTap: () => showPaywallSheet(context),
            ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore purchase'),
            subtitle: const Text('New phone, or reinstalled? Get Pro back.'),
            onTap: () => runStoreAction(context, service.restorePurchases),
          ),
          const Divider(),
          header('The fine print'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            subtitle: const Text('Short version: we never see your shelf.'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => open(PocketCurioLinks.privacy),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('pocketcurio.app'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => open(PocketCurioLinks.site),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Open-source licenses'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Pocket Curio',
              applicationLegalese: '© 2026 Code Cowboys LLC',
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2026 Code Cowboys LLC',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
