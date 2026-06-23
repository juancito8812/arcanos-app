import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/app.dart';

void main() {
  testWidgets('App should build and show title', (WidgetTester tester) async {
    await tester.pumpWidget(const PsicoTarotApp());
    expect(find.text('PsicoTarot'), findsOneWidget);
  });
}
