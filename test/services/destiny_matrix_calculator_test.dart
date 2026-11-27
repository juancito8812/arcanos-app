import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/destiny_matrix_calculator.dart';

void main() {
  group('DestinyMatrixCalculator', () {
    test('calculates matrix for known date', () {
      // June 23, 2026
      final matrix = DestinyMatrixCalculator.calculate(DateTime(2026, 6, 23));

      expect(matrix.positions.length, greaterThanOrEqualTo(6));
      expect(matrix.birthDate.year, 2026);
    });

    test('reduce returns valid arcano (1-21)', () {
      final arc = DestinyMatrixCalculator.reduce(10);
      expect(arc.numero, 10);
    });

    test('reduce mapea 22 a El Loco (0)', () {
      // 22 no es una carta: allArcanos solo llega a 21 y el 0 es El Loco.
      final arc = DestinyMatrixCalculator.reduce(22);
      expect(arc.numero, 0);
      expect(arc.nombre, 'El Loco');
    });

    test('reduce handles multi-step reduction (999 -> 9)', () {
      final arc = DestinyMatrixCalculator.reduce(999);
      expect(arc.numero, 9);
    });

    test('byKey returns correct position', () {
      final matrix = DestinyMatrixCalculator.calculate(DateTime(1990, 5, 15));
      final day = matrix.byKey('day');
      expect(day, isNotNull);
      expect(day!.key, 'day');
    });
  });
}
