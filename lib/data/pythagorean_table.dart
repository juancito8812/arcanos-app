const Map<String, int> pythagoreanTable = {
  'A': 1, 'B': 2, 'C': 4, 'D': 5, 'E': 3, 'F': 8, 'G': 10,
  'H': 28, 'I': 15, 'J': 15, 'K': 8, 'L': 21, 'M': 19, 'N': 26,
  'O': 8, 'P': 77, 'Q': 27, 'R': 11, 'S': 20, 'T': 6,
  'U': 9, 'V': 9, 'W': 9, 'X': 13, 'Y': 50, 'Z': 70,
};

int calcularValorNombre(String nombre) {
  int total = 0;
  for (int i = 0; i < nombre.length; i++) {
    String letra = nombre[i].toUpperCase();
    if (letra == 'N' || letra == 'Ñ') {
      total += 26;
    } else if (pythagoreanTable.containsKey(letra)) {
      total += pythagoreanTable[letra]!;
    }
  }
  return total;
}

int reduccionTeosofica(int numero) {
  if (numero == 11 || numero == 22) return numero;
  if (numero >= 1 && numero <= 22) return numero;
  int n = numero;
  while (n > 22) {
    int s = 0;
    int t = n;
    while (t > 0) { s += t % 10; t ~/= 10; }
    n = s;
    if (n == 11 || n == 22) break;
  }
  return n;
}

int sumarDigitosFecha(int dia, int mes, int anno) {
  int suma = 0;
  int d = dia; while (d > 0) { suma += d % 10; d ~/= 10; }
  int m = mes; while (m > 0) { suma += m % 10; m ~/= 10; }
  int a = anno; while (a > 0) { suma += a % 10; a ~/= 10; }
  return reduccionTeosofica(suma);
}
