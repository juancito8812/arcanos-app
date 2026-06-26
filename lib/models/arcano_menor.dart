class ArcanoMenor {
  final int id;
  final String nombre;
  final String palo;
  final String rango;
  final int numero;
  final String elemento;
  final String significado;

  const ArcanoMenor({
    required this.id,
    required this.nombre,
    required this.palo,
    required this.rango,
    required this.numero,
    required this.elemento,
    required this.significado,
  });

  String get rangoRomano {
    switch (rango) {
      case 'as': return 'I';
      case '2': return 'II';
      case '3': return 'III';
      case '4': return 'IV';
      case '5': return 'V';
      case '6': return 'VI';
      case '7': return 'VII';
      case '8': return 'VIII';
      case '9': return 'VIIII';
      case '10': return 'X';
      case 'sota': return 'S';
      case 'caballo': return 'C';
      case 'reina': return 'Q';
      case 'rey': return 'K';
      default: return '';
    }
  }

  int get imagenNumero {
    final base = switch (palo.toLowerCase()) {
      'copas' => 22,
      'oros' => 36,
      'espadas' => 50,
      'bastos' => 64,
      _ => 22,
    };
    final offset = switch (rango) {
      'as' => 1,
      '2' => 2, '3' => 3, '4' => 4, '5' => 5,
      '6' => 6, '7' => 7, '8' => 8, '9' => 9, '10' => 10,
      'sota' => 12, 'caballo' => 11, 'reina' => 13, 'rey' => 14,
      _ => 1,
    };
    return base + offset - 1;
  }
}
