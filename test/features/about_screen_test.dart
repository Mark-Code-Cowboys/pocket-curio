import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/links.dart';
import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/features/about/about_screen.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late List<Uri> opened;

  setUp(() {
    db = makeTestDb();
    opened = [];
  });
  tearDown(() => db.close());

  Widget app({EntitlementService? entitlements, bool canOpen = true}) =>
      testApp(
        db: db,
        entitlements: entitlements,
        home: const AboutScreen(),
        linkOpener: (url) async {
          opened.add(url);
          return canOpen;
        },
      );

  testWidgets('help, FAQ, user guide, and privacy open pocketcurio.app', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('User guide'));
    await tester.tap(find.text('Help'));
    await tester.tap(find.text('FAQ'));
    await tester.scrollUntilVisible(find.text('Privacy policy'), 200);
    await tester.tap(find.text('Privacy policy'));
    await tester.scrollUntilVisible(find.text('pocketcurio.app'), 200);
    await tester.tap(find.text('pocketcurio.app'));
    await tester.pumpAndSettle();

    expect(opened, [
      PocketCurioLinks.userGuide,
      PocketCurioLinks.help,
      PocketCurioLinks.faq,
      PocketCurioLinks.privacy,
      PocketCurioLinks.site,
    ]);
    for (final url in opened) {
      expect(url.host, 'pocketcurio.app');
      expect(url.scheme, 'https');
    }
    await disposeApp(tester);
  });

  testWidgets('a link that cannot open says where to go instead', (
    tester,
  ) async {
    await tester.pumpWidget(app(canOpen: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();

    expect(find.textContaining('pocketcurio.app/help'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('free users see Go Pro; Pro owners see Pro active', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Go Pro'), findsOneWidget);
    expect(find.text('Pro active'), findsNothing);
    await disposeApp(tester);

    await tester.pumpWidget(
      app(entitlements: FakeEntitlementService(unlimited: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pro active'), findsOneWidget);
    expect(find.text('Go Pro'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('the home app bar opens Help & about', (tester) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        linkOpener: (url) async {
          opened.add(url);
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Help & about'));
    await tester.pumpAndSettle();

    expect(find.text('Help & about'), findsOneWidget);
    expect(find.text('User guide'), findsOneWidget);
    await disposeApp(tester);
  });
}
