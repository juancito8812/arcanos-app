/// Números Personales (numerología clásica), módulo independiente de la
/// Matriz del Destino. Método del dueño (imágenes del 25-nov-2026):
/// 1) Número de Vida: reducir día, mes y año por separado y sumar.
/// 2) Año Personal: (día+mes reducidos) + (año del ciclo reducido).
/// Toda reducción llega a UN DÍGITO: 11->2, 22->4 (números maestros se
/// reducen aquí; el 11/22 solo se conserva en la Matriz, no en este módulo).
class PersonalNumbers {
  /// Raíz digital: 38 -> 3+8=11 -> 1+1=2. 0 no ocurre con fechas reales.
  static int _root(int n) {
    while (n > 9) {
      var s = 0;
      while (n > 0) {
        s += n % 10;
        n ~/= 10;
      }
      n = s;
    }
    return n;
  }

  static int _digitSum(int n) {
    var s = 0;
    while (n > 0) {
      s += n % 10;
      n ~/= 10;
    }
    return s;
  }

  /// Número de Vida (fijo de nacimiento). Ej. del dueño: 14/01/1987 ->
  /// día 1+4=5, mes 1, año 1+9+8+7=25->2+5=7; 5+1+7=13->4.
  static int numeroDeVida(DateTime fecha) {
    return _root(
      _root(_digitSum(fecha.day)) +
          _root(_digitSum(fecha.month)) +
          _root(_digitSum(fecha.year)),
    );
  }

  /// Año Personal para [hoy]. Ej. del dueño: nacido 05/01, año 2027 ->
  /// 5+1=6, 2+0+2+7=11->2; 6+2=8.
  static int anoPersonal(DateTime fechaNacimiento, DateTime hoy) {
    return _root(
      _root(_digitSum(fechaNacimiento.day)) + _root(_digitSum(fechaNacimiento.month)) +
          _root(_digitSum(hoy.year)),
    );
  }

  /// Desglose para mostrar en pantalla, estilo del dueño: "5 + 1 + 7 = 13 → 4".
  static String desgloseVida(DateTime fecha) {
    final d = _root(_digitSum(fecha.day));
    final m = _root(_digitSum(fecha.month));
    final y = _root(_digitSum(fecha.year));
    final total = d + m + y;
    final totalStr = total > 9 ? '$total → ${_root(total)}' : '$total';
    return '$d + $m + $y = $totalStr';
  }

  static String desgloseAno(DateTime fechaNacimiento, DateTime hoy) {
    final dm = _root(_digitSum(fechaNacimiento.day)) + _root(_digitSum(fechaNacimiento.month));
    final y = _root(_digitSum(hoy.year));
    final total = dm + y;
    final totalStr = total > 9 ? '$total → ${_root(total)}' : '$total';
    return '$dm + $y = $totalStr';
  }

  static const _significados = <int, String>{
    1: 'Liderazgo, iniciativa y nuevos comienzos.',
    2: 'Sensibilidad, cooperación y equilibrio.',
    3: 'Expresión, creatividad y comunicación.',
    4: 'Estabilidad, constancia, orden y construir bases sólidas.',
    5: 'Libertad, cambio, aventura y versatilidad.',
    6: 'Amor, familia, responsabilidad y armonía.',
    7: 'Análisis, introspección y sabiduría espiritual.',
    8: 'Poder material, ambición y éxito profesional.',
    9: 'Compasión, servicio y cierre de ciclos.',
  };

  static String significado(int numero) {
    final s = _significados[numero];
    if (s == null) throw ArgumentError('numero fuera de 1-9: $numero');
    return s;
  }
}
