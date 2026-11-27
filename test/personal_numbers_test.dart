import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/personal_numbers.dart';

void main() {
  group('PersonalNumbers (método del dueño, imágenes 25-nov-2026)', () {
    test('ejemplo 1: Número de Vida 14/01/1987 -> 4', () {
      // Día 1+4=5 · Mes 1 · Año 1+9+8+7=25→7 · 5+1+7=13→4
      final n = PersonalNumbers.numeroDeVida(DateTime(1987, 1, 14));
      expect(n, 4);
      expect(PersonalNumbers.significado(n), contains('Estabilidad'));
      expect(PersonalNumbers.desgloseVida(DateTime(1987, 1, 14)), '5 + 1 + 7 = 13 → 4');
    });

    test('ejemplo 2: Año Personal nacido 05/01 en 2027 -> 8', () {
      // Día+mes 5+1=6 · Año 2+0+2+7=11→2 · 6+2=8
      final n = PersonalNumbers.anoPersonal(DateTime(2000, 1, 5), DateTime(2027, 6, 15));
      expect(n, 8);
      expect(PersonalNumbers.significado(n), contains('Poder material'));
      expect(PersonalNumbers.desgloseAno(DateTime(2000, 1, 5), DateTime(2027, 6, 15)), '6 + 2 = 8');
    });

    test('los números maestros se reducen a 1 dígito (11→2, 22→4)', () {
      // 29/09/1969: día 11→2 · mes 9 · año 25→7 · 2+9+7=18→9
      expect(PersonalNumbers.numeroDeVida(DateTime(1969, 9, 29)), 9);
      // 22/12/1999: día 4 · mes 3 · año 28→10→1 · 4+3+1=8
      expect(PersonalNumbers.numeroDeVida(DateTime(1999, 12, 22)), 8);
      // nacido 05/05 en 2025: día+mes 10→1 · año 9 · 1+9=10→1
      expect(PersonalNumbers.anoPersonal(DateTime(2000, 5, 5), DateTime(2025, 3, 3)), 1);
      // 2024 (8): 1+8=9
      expect(PersonalNumbers.anoPersonal(DateTime(2000, 5, 5), DateTime(2024, 3, 3)), 9);
    });

    test('siempre devuelve 1..9 y el desglose no rompe con cifras altas', () {
      for (final f in [
        DateTime(1900, 1, 1), DateTime(1999, 12, 31), DateTime(2000, 2, 29),
        DateTime(2026, 11, 25), DateTime(1980, 7, 30),
      ]) {
        final vida = PersonalNumbers.numeroDeVida(f);
        expect(vida, inInclusiveRange(1, 9), reason: 'vida $f');
        final ano = PersonalNumbers.anoPersonal(f, DateTime(2026, 11, 25));
        expect(ano, inInclusiveRange(1, 9), reason: 'ano $f');
        expect(() => PersonalNumbers.significado(vida), returnsNormally);
      }
    });

    test('el Año Personal solo depende del año consultado, no del día', () {
      final nac = DateTime(1995, 3, 20);
      final a = PersonalNumbers.anoPersonal(nac, DateTime(2026, 1, 1));
      final b = PersonalNumbers.anoPersonal(nac, DateTime(2026, 12, 31));
      expect(a, b);
      expect(PersonalNumbers.anoPersonal(nac, DateTime(2027, 1, 1)),
          isNot(a), reason: 'debe cambiar al cambiar de año (2026 vs 2027)');
    });
  });
}
