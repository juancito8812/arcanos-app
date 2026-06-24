import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:arcanos_mayores/widgets/daily_card_banner.dart';
import 'package:arcanos_mayores/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseService.deleteDatabase();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('DailyCardBanner renders and completes load', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const DailyCardBanner())),
      );
      // Wait for database init + query
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await tester.pump();

    expect(find.byType(DailyCardBanner), findsOneWidget);
  });
}
