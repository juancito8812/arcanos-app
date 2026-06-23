class ArcanoPosicion {
  final int posicion; final String nombre; final ArcanoInfo arcano;
  final String edadPeriodo; final String significado;
  const ArcanoPosicion({required this.posicion, required this.nombre, required this.arcano, required this.edadPeriodo, required this.significado});
}

class ArcanoInfo {
  final int numero; final String nombre; final String nombreRomano;
  const ArcanoInfo({required this.numero, required this.nombre, required this.nombreRomano});
  String get nombreCompleto => '$nombreRomano - $nombre';
}

class LifeLineResult {
  final List<ArcanoPosicion> arcanos; final String nombreCompleto; final DateTime fechaNacimiento;
  const LifeLineResult({required this.arcanos, required this.nombreCompleto, required this.fechaNacimiento});
}
