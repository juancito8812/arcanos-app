import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/destiny_matrix_calculator.dart';

void main() {
  group('DestinyMatrixCalculator', () {
    test('todas las posiciones caen en arcanos 0..21', () {
      final m = DestinyMatrixCalculator.calculate(DateTime(1990, 2, 1));
      expect(m.positions.length, 8);
      for (final p in m.positions) {
        expect(p.numero, inInclusiveRange(0, 21), reason: p.key);
      }
    });

    test('reduce(22) devuelve El Loco (0)', () {
      expect(DestinyMatrixCalculator.reduce(22).numero, 0);
      expect(DestinyMatrixCalculator.reduce(0).numero, 0);
    });

    test('reduce no explota con valores grandes', () {
      for (final v in [22, 44, 99, 1990, 383]) {
        final a = DestinyMatrixCalculator.reduce(v);
        expect(a.numero, inInclusiveRange(0, 21), reason: '$v');
      }
    });
  });
}
