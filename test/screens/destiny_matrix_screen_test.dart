import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:arcanos_mayores/screens/numerology/destiny_matrix_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('DestinyMatrixScreen renders without profile', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(home: const DestinyMatrixScreen()),
      );
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(find.byType(DestinyMatrixScreen), findsOneWidget);
  });
}
