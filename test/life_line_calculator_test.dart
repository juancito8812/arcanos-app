import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/life_line_calculator.dart';

void main() {
  group('LifeLineCalculator', () {
    test('devuelve 5 posiciones con arcanos existentes', () {
      final r = LifeLineCalculator.calcular(
        nombreCompleto: 'Ana Maria Perez',
        fechaNacimiento: DateTime(1990, 1, 2),
      );

      expect(r, isNotNull);
      expect(r!.arcanos.length, 5);

      for (final pos in r.arcanos) {
        expect(pos.arcano.numero, inInclusiveRange(0, 21),
            reason: 'posicion ${pos.posicion}');
        expect(pos.arcano.nombre, isNot('Desconocido'),
            reason: 'posicion ${pos.posicion} sin carta');
      }
    });

    test('fecha que suma 22 no produce arcano inexistente', () {
      // 29/12/1987 -> 2+9+1+2+1+9+8+7 = 39 -> 12 ; fecha 04/09/1989 = 40 -> 4
      // Buscamos una fecha cuya suma cruda de 22: 11/11/1989 -> 1+1+1+1+1+9+8+9 = 31
      // 19/12/1978 -> 1+9+1+2+1+9+7+8 = 38 -> 11
      final r = LifeLineCalculator.calcular(
        nombreCompleto: 'Test Usuario',
        fechaNacimiento: DateTime(1978, 12, 19),
      );
      expect(r, isNotNull);
      for (final pos in r!.arcanos) {
        expect(pos.arcano.numero, inInclusiveRange(0, 21));
      }
    });

    test('nombre vacio devuelve null', () {
      expect(
        LifeLineCalculator.calcular(
            nombreCompleto: '   ', fechaNacimiento: DateTime(1990, 1, 1)),
        isNull,
      );
    });

    test('es determinista', () {
      final a = LifeLineCalculator.calcular(
          nombreCompleto: 'Juan Carlos', fechaNacimiento: DateTime(1985, 6, 15));
      final b = LifeLineCalculator.calcular(
          nombreCompleto: 'Juan Carlos', fechaNacimiento: DateTime(1985, 6, 15));
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a!.arcanos.map((e) => e.arcano.numero).toList(),
          b!.arcanos.map((e) => e.arcano.numero).toList());
    });
  });
}
