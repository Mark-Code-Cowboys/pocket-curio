import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_curio/app.dart';

void main() {
  testWidgets('app boots to the shell with the positioning line',
      (tester) async {
    await tester.pumpWidget(const PocketCurioApp());

    expect(find.text('Pocket Curio'), findsOneWidget);
    expect(find.text('A souvenir is a place + a memory.'), findsOneWidget);
  });
}
