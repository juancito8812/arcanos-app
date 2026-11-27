import 'package:arcanos_mayores/data/arcanos_data.dart';
import 'package:arcanos_mayores/data/pythagorean_table.dart';
import 'package:arcanos_mayores/models/arcano.dart';
import 'package:arcanos_mayores/models/destiny_matrix.dart';

class DestinyMatrixCalculator {
  /// El 22 y el 0 son El Loco (arcano 0), igual que en la tabla pitagorica.
  /// Antes el 22 caia en La Fuerza (21) y la misma persona salia con dos
  /// arcanos distintos segun la pantalla.
  static Arcano reduce(int value) => allArcanos[reducirAArcano(value)];

  static DestinyMatrix calculate(DateTime birthDate) {
    final day = birthDate.day;
    final month = birthDate.month;
    final year = birthDate.year;

    final yearSum = year.toString().split('').map((d) => int.parse(d)).reduce((a, b) => a + b);

    final Arcano dayArc = reduce(day);
    final Arcano monthArc = reduce(month);
    final Arcano yearArc = reduce(yearSum);

    final Arcano essence = reduce(dayArc.numero + monthArc.numero + yearArc.numero);

    final Arcano talent = reduce(dayArc.numero + monthArc.numero);
    final dayMonthDiff = (day - month).abs();
    final Arcano challenge1 = dayMonthDiff <= 21
        ? reduce(dayMonthDiff)
        : reduce(day + month);
    final Arcano challenge2 = reduce(monthArc.numero + yearArc.numero);
    final dayYearDiff = (day - yearSum).abs();
    final Arcano challengeDiff = dayYearDiff <= 21
        ? reduce(dayYearDiff)
        : reduce(day + yearSum);

    final Arcano purpose = reduce(essence.numero + challengeDiff.numero);

    List<DestinyPosition> positions = [
      DestinyPosition(numero: dayArc.numero, nombre: dayArc.nombre, nombreRomano: dayArc.nombreRomano, key: 'day'),
      DestinyPosition(numero: monthArc.numero, nombre: monthArc.nombre, nombreRomano: monthArc.nombreRomano, key: 'month'),
      DestinyPosition(numero: yearArc.numero, nombre: yearArc.nombre, nombreRomano: yearArc.nombreRomano, key: 'year'),
      DestinyPosition(numero: essence.numero, nombre: essence.nombre, nombreRomano: essence.nombreRomano, key: 'essence'),
      DestinyPosition(numero: talent.numero, nombre: talent.nombre, nombreRomano: talent.nombreRomano, key: 'talent'),
      DestinyPosition(numero: challenge1.numero, nombre: challenge1.nombre, nombreRomano: challenge1.nombreRomano, key: 'challenge1'),
      DestinyPosition(numero: challenge2.numero, nombre: challenge2.nombre, nombreRomano: challenge2.nombreRomano, key: 'challenge2'),
      DestinyPosition(numero: purpose.numero, nombre: purpose.nombre, nombreRomano: purpose.nombreRomano, key: 'purpose'),
    ];

    return DestinyMatrix(birthDate: birthDate, positions: positions);
  }
}
