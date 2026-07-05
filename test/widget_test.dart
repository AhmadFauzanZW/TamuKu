import 'package:flutter_test/flutter_test.dart';
import 'package:tamuku/app.dart';

void main() {
  testWidgets('TamuKu app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TamuKuApp());
    expect(find.text('TamuKu'), findsOneWidget);
  });
}
