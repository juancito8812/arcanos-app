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
}
