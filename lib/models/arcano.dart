class Arcano {
  final int id; final int numero; final String nombre; final String nombreRomano;
  final String leyEspiritual; final String leccionVida; final String miedoAsociado;
  final String descripcionGeneral; final String arquetipo; final String elemento;
  final String polaridad; final int valorNuclear;
  final String desafio;
  final String significadoPosicion;
  final String perspectivaTransgeneracional;
  final String colorAsociado;
  final int nivel;
  final String afirmacionSanadora;

  const Arcano({
    required this.id, required this.numero, required this.nombre, required this.nombreRomano,
    required this.leyEspiritual, required this.leccionVida, required this.miedoAsociado,
    this.descripcionGeneral = '', this.arquetipo = '', this.elemento = '', this.polaridad = '',
    required this.valorNuclear, this.desafio = '', this.significadoPosicion = '',
    this.perspectivaTransgeneracional = '', this.colorAsociado = '', this.nivel = 1,
    this.afirmacionSanadora = '',
  });

  int get valorReducido {
    if (numero <= 22) return numero;
    int n = numero;
    while (n > 22 && n != 11 && n != 22) {
      int s = 0;
      while (n > 0) { s += n % 10; n ~/= 10; }
      n = s;
    }
    return n;
  }

  String get nombreCompleto => '$nombreRomano - $nombre';
}
