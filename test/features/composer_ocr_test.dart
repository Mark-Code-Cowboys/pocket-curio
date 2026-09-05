import 'package:cc_core/cc_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/data/database/app_database.dart';
import 'package:pocket_curio/data/repositories/collection_repository.dart';
import 'package:pocket_curio/data/repositories/item_repository.dart';
import 'package:pocket_curio/features/collections/collection_screen.dart';

import '../helpers.dart';

/// A recognizer that fails, for the graceful-degradation test.
class _BrokenRecognizer implements TextRecognitionService {
  @override
  Future<List<OcrLine>> recognize(String imagePath) =>
      throw Exception('no model');

  @override
  void dispose() {}
}

void main() {
  late AppDatabase db;
  late int collectionId;

  setUp(() async {
    db = makeTestDb();
    collectionId = await CollectionRepository(db).createCollection(
      collectionDraft(name: 'Keychains', kind: CollectionKind.keychain),
    );
  });

  tearDown(() => db.close());

  OcrLine line(String text, {double top = 0, double height = 20}) =>
      OcrLine(text, left: 0, top: top, height: height);

  testWidgets('the photo prefills Place with what was printed', (tester) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        recognizer: FakeTextRecognitionService(
          fallback: [
            line('KEY WEST', top: 10, height: 40),
            line('Florida', top: 60, height: 16),
          ],
        ),
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'KEY WEST'), findsOneWidget);
    expect(
      find.text('Read from the photo — check the spelling.'),
      findsOneWidget,
    );
    expect(find.text('Also read:'), findsOneWidget);
    expect(find.text('Florida'), findsOneWidget);

    // Tapping a chip swaps the place; the field's own text becomes a chip.
    await tester.tap(find.text('Florida'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Florida'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'KEY WEST'), findsOneWidget);

    // Typing over it drops the "read from the photo" note.
    await tester.enterText(
      find.widgetWithText(TextField, 'Florida'),
      'Key West',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Read from the photo — check the spelling.'),
      findsNothing,
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final item = (await tester.runAsync(
      () => ItemRepository(db).watchItemsForCollection(collectionId).first,
    ))!.single;
    expect(item.place, 'Key West');
    await disposeApp(tester);
  });

  testWidgets('nothing read means nothing prefilled and no chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Place'),
    );
    expect(field.controller!.text, isEmpty);
    expect(find.text('Also read:'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('a broken recognizer degrades to the plain composer', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        db: db,
        recognizer: _BrokenRecognizer(),
        home: CollectionScreen(collectionId: collectionId),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add keychain'));
    await tester.pumpAndSettle();

    expect(find.text('Retake'), findsOneWidget, reason: 'photo still landed');
    expect(find.text('Also read:'), findsNothing);
    await disposeApp(tester);
  });
}
