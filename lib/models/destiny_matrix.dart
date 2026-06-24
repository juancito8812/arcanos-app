class DestinyPosition {
  final int numero;
  final String nombre;
  final String nombreRomano;
  final String key;

  const DestinyPosition({
    required this.numero,
    required this.nombre,
    required this.nombreRomano,
    required this.key,
  });
}

class DestinyMatrix {
  final DateTime birthDate;
  final List<DestinyPosition> positions;

  const DestinyMatrix({
    required this.birthDate,
    required this.positions,
  });

  DestinyPosition? byKey(String key) {
    try {
      return positions.firstWhere((p) => p.key == key);
    } catch (_) {
      return null;
    }
  }
}
