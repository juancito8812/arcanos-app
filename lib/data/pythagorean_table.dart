const Map<String, int> pythagoreanTable = {
  'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8, 'I': 9,
  'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'O': 6, 'P': 7, 'Q': 8, 'R': 9,
  'S': 1, 'T': 2, 'U': 3, 'V': 4, 'W': 5, 'X': 6, 'Y': 7, 'Z': 8,
};

int calcularValorNombre(String nombre) {
  int total = 0;
  for (int i = 0; i < nombre.length; i++) {
    String letra = nombre[i].toUpperCase();
    if (letra == 'Ñ') {
      total += 5;
    } else if (pythagoreanTable.containsKey(letra)) {
      total += pythagoreanTable[letra]!;
    }
  }
  return total;
}

/// Reduce cualquier numero al rango real de los 22 arcanos mayores (0-21).
///
/// El 22 no existe como carta: `arcano_22.jpg` no esta en assets y
/// [getArcanoByNumero] devuelve null, lo que producia "Desconocido".
/// El 22 se interpreta como El Loco (0), y el 0 tambien es El Loco.
/// El 11 (La Fuerza) se conserva porque es un arcano valido.
int reducirAArcano(int numero) {
  int n = numero.abs();
  if (n <= 21) return n;
  if (n == 22) return 0;
  while (n > 21) {
    int s = 0;
    int t = n;
    while (t > 0) { s += t % 10; t ~/= 10; }
    if (s == n) break;
    n = s;
  }
  return n == 22 ? 0 : n;
}

/// Alias historico usado por la tabla pitagorica.
int reduccionTeosofica(int numero) => reducirAArcano(numero);

int sumarDigitosFecha(int dia, int mes, int anno) {
  int suma = 0;
  int d = dia; while (d > 0) { suma += d % 10; d ~/= 10; }
  int m = mes; while (m > 0) { suma += m % 10; m ~/= 10; }
  int a = anno; while (a > 0) { suma += a % 10; a ~/= 10; }
  return reduccionTeosofica(suma);
}
