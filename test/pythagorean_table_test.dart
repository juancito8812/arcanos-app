import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/data/pythagorean_table.dart';

void main() {
  group('reducirAArcano', () {
    test('deja igual todo valor entre 0 y 21', () {
      for (var i = 0; i <= 21; i++) {
        expect(reducirAArcano(i), i, reason: 'valor $i');
      }
    });

    test('22 es El Loco (0), no un arcano inexistente', () {
      expect(reducirAArcano(22), 0);
    });

    test('conserva el 11 como numero maestro', () {
      expect(reducirAArcano(11), 11);
      expect(reducirAArcano(29), 11);
    });

    test('reduce sumas grandes por suma de digitos', () {
      expect(reducirAArcano(38), 11);
      expect(reducirAArcano(44), 8);
      expect(reducirAArcano(99), 18); // 9+9=18 (La Luna), sigue siendo arcano real
      expect(reducirAArcano(999), 9); // 9+9+9=27 -> 2+7=9
      expect(reducirAArcano(1990), 19);
    });

    test('nunca devuelve fuera de 0..21', () {
      for (var i = -50; i <= 500; i++) {
        final r = reducirAArcano(i);
        expect(r >= 0 && r <= 21, isTrue, reason: 'entrada $i -> $r');
      }
    });

    test('reduccionTeosofica es alias consistente', () {
      expect(reduccionTeosofica(22), 0);
      expect(reduccionTeosofica(7), 7);
      expect(reduccionTeosofica(123), reducirAArcano(123));
    });
  });

  group('calcularValorNombre', () {
    test('suma la tabla pitagorica incluyendo Ñ', () {
      expect(calcularValorNombre('A'), 1);
      expect(calcularValorNombre('Ñ'), 5);
      expect(calcularValorNombre('ANA'), 1 + 5 + 1);
      expect(calcularValorNombre(''), 0);
    });
  });

  group('sumarDigitosFecha', () {
    test('fecha conocida devuelve arcano valido', () {
      final r = sumarDigitosFecha(2, 1, 1990);
      expect(r, greaterThanOrEqualTo(0));
      expect(r, lessThanOrEqualTo(21));
    });
  });
}
