import '../models/life_line.dart';
import '../data/pythagorean_table.dart';
import '../data/arcanos_data.dart';

class LifeLineCalculator {
  static LifeLineResult? calcular({required String nombreCompleto, required DateTime fechaNacimiento}) {
    if (nombreCompleto.trim().isEmpty) return null;

    // Arcano 1 - YO: Suma del nombre
    int totalNombre = 0;
    for (String palabra in nombreCompleto.trim().split(RegExp(r'\s+'))) {
      totalNombre += calcularValorNombre(palabra);
    }
    int a1 = reduccionTeosofica(totalNombre);

    // Arcano 2 - ELLO: Suma de digitos de la fecha
    int a2 = sumarDigitosFecha(fechaNacimiento.day, fechaNacimiento.month, fechaNacimiento.year);

    // Arcano 3 - MENTE: Reducir el total de la fecha a un solo digito (1-9)
    int a3 = a2;
    // Siempre reducir a digito unico (1-9), respetando 11,22
    while (a3 > 9 && a3 != 11 && a3 != 22) {
      int s = 0;
      int t = a3;
      while (t > 0) { s += t % 10; t ~/= 10; }
      a3 = s;
    }

    // Arcano 4 - REALIZACION: a1 + a3
    int a4 = reduccionTeosofica(a1 + a3);

    // Arcano 5 - SINTESIS: Suma de todos
    int a5 = reduccionTeosofica(a1 + a2 + a3 + a4);

    // Construir resultado
    final arcanos = [
      _makePos(1, a1, 'YO - Personalidad', '0 a 10 anos', 'Representa tu personalidad consciente. Define tu esencia y caracter innato.'),
      _makePos(2, a2, 'ELLO - Entorno', '10 a 20 anos', 'Como te ven los demas, tu entorno familiar y social.'),
      _makePos(3, a3, 'MENTE - Pensamiento', '20 a 30 anos', 'Como piensas y juzgas. La interaccion entre tu yo interior y tu entorno.'),
      _makePos(4, a4, 'REALIZACION - Accion', '30 a 40 anos', 'Como haces o realizas las cosas. El resultado de tus acciones.'),
      _makePos(5, a5, 'SINTESIS - Destino', '40 a 50 anos', 'Fusion de las 4 energias para evolucionar. Sentido de vida.'),
    ];

    return LifeLineResult(arcanos: arcanos, nombreCompleto: nombreCompleto, fechaNacimiento: fechaNacimiento);
  }

  static ArcanoPosicion _makePos(int pos, int num, String nom, String edad, String sig) {
    final info = getArcanoByNumero(num);
    return ArcanoPosicion(
      posicion: pos, nombre: nom,
      arcano: ArcanoInfo(numero: num, nombre: info?.nombre ?? 'Desconocido', nombreRomano: info?.nombreRomano ?? num.toString()),
      edadPeriodo: edad, significado: sig,
    );
  }
}
