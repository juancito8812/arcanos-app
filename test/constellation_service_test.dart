import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/models/family_member.dart';
import 'package:arcanos_mayores/services/constellation_service.dart';

FamilyMember _m(String nombre, String relacion,
        {String? fecha, int? arcano}) =>
    FamilyMember(
      nombre: nombre,
      relacion: relacion,
      fechaNacimiento: fecha,
      arcanoNumero: arcano,
    );

void main() {
  group('arcanoParaPosicion', () {
    test('es estable entre llamadas (sin Random sin semilla)', () {
      final m = _m('Maria Lopez', 'Madre', fecha: '1960-03-14');
      final a = ConstellationService.arcanoParaPosicion('MADRE', miembro: m);
      final b = ConstellationService.arcanoParaPosicion('MADRE', miembro: m);
      final c = ConstellationService.arcanoParaPosicion('MADRE', miembro: m);
      expect(a?.numero, b?.numero);
      expect(b?.numero, c?.numero);
    });

    test('usa el arcano guardado del miembro', () {
      final m = _m('Pedro', 'Padre', fecha: '1955-01-01', arcano: 7);
      expect(ConstellationService.arcanoParaPosicion('PADRE', miembro: m)?.numero, 7);
    });

    test('un arcano guardado fuera de rango no rompe', () {
      final m = _m('Pedro', 'Padre', arcano: 22);
      final a = ConstellationService.arcanoParaPosicion('PADRE', miembro: m);
      expect(a, isNotNull);
      expect(a!.numero, inInclusiveRange(0, 21));
    });

    test('sin miembro devuelve un arcano valido por posicion', () {
      for (final p in ConstellationService.posicionesSistemicas) {
        final a = ConstellationService.arcanoParaPosicion(p);
        expect(a, isNotNull, reason: p);
      }
    });
  });

  group('detectarPatronesTransgeneracionales', () {
    test('cuenta repetidos entre miembros y usuario', () {
      final miembros = [
        _m('Padre', 'Padre', arcano: 4),
        _m('Madre', 'Madre', arcano: 4),
        _m('Tia', 'Otro', arcano: 9),
      ];

      final patrones = ConstellationService.detectarPatronesTransgeneracionales(
        miembros,
        arcanosUsuario: [4],
      );

      expect(patrones, isNotEmpty);
      final top = patrones.first;
      expect(top['repeticiones'], 3);
      expect((top['arcano'] as dynamic).numero, 4);
      expect((top['miembros'] as List).first, 'TU');
    });

    test('sin datos no inventa patrones', () {
      final patrones = ConstellationService.detectarPatronesTransgeneracionales(
        [_m('Sin fecha', 'Otro')],
      );
      expect(patrones, isEmpty);
    });
  });
}
