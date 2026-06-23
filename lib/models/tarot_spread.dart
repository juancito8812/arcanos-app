class TarotSpread {
  final String id; final String nombre; final String descripcion;
  final int numCartas; final List<String> posiciones;
  const TarotSpread({required this.id, required this.nombre, required this.descripcion, required this.numCartas, required this.posiciones});
}

class CartaTirada {
  final int posicion; final String nombrePosicion; final ArcanoInfo arcano; final bool estaRevelada;
  const CartaTirada({required this.posicion, required this.nombrePosicion, required this.arcano, this.estaRevelada = true});
}

class ArcanoInfo {
  final int numero; final String nombre; final String nombreRomano;
  final String significado; final String leyEspiritual; final String leccionVida;
  const ArcanoInfo({required this.numero, required this.nombre, required this.nombreRomano, this.significado = '', this.leyEspiritual = '', this.leccionVida = ''});
  String get nombreCompleto => '$nombreRomano - $nombre';
}

class TarotReadingResult {
  final TarotSpread spread; final List<CartaTirada> cartas; final DateTime fecha;
  const TarotReadingResult({required this.spread, required this.cartas, required this.fecha});
}
