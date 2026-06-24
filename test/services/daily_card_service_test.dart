import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/models/daily_card.dart';

void main() {
  group('DailyCard', () {
    test('isToday returns true for today', () {
      final now = DateTime.now();
      final card = DailyCard(
        date: now,
        arcanoNumero: 0,
        arcanoNombre: 'El Loco',
        arcanoNombreRomano: '0',
        hasProfile: false,
      );
      expect(card.isToday, isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final card = DailyCard(
        date: yesterday,
        arcanoNumero: 0,
        arcanoNombre: 'El Loco',
        arcanoNombreRomano: '0',
        hasProfile: false,
      );
      expect(card.isToday, isFalse);
    });

    test('toMap and fromMap round-trip', () {
      final original = DailyCard(
        date: DateTime(2026, 6, 23),
        arcanoNumero: 1,
        arcanoNombre: 'El Mago',
        arcanoNombreRomano: 'I',
        aiInterpretation: 'Test',
        hasProfile: true,
      );
      final map = original.toMap();
      final restored = DailyCard.fromMap(map);
      expect(restored.arcanoNumero, original.arcanoNumero);
      expect(restored.arcanoNombre, original.arcanoNombre);
      expect(restored.aiInterpretation, original.aiInterpretation);
      expect(restored.hasProfile, original.hasProfile);
    });
  });
}
