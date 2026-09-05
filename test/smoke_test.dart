import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('app boots to an empty home with the positioning line', (
    tester,
  ) async {
    final db = makeTestDb();
    addTearDown(db.close);

    await tester.pumpWidget(testApp(db: db));
    await tester.pumpAndSettle();

    expect(find.text('Pocket Curio'), findsOneWidget);
    expect(find.text('A souvenir is a place + a memory.'), findsOneWidget);
    expect(find.text('New collection'), findsOneWidget);
    await disposeApp(tester);
  });
}
