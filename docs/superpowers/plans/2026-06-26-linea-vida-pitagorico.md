# Línea de Vida Pitagórica — Implementation Plan

**Goal:** Reemplazar tabla numerológica actual por la pitagórica estándar + corregir mapeo 22→0

**Architecture:** Solo cambia `lib/data/pythagorean_table.dart` — las funciones mantienen su firma. La calculadora no necesita cambios.

---
### Task 1: Tabla pitagórica + mapeo 22→0

**Files:** Modify: `lib/data/pythagorean_table.dart`

- [ ] **Step 1: Reemplazar tabla y función calcularValorNombre**

Reemplazar el Map `pythagoreanTable` con la tabla estándar y simplificar `calcularValorNombre`:

```dart
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
```

- [ ] **Step 2: Agregar mapeo 22→0 en reduccionTeosofica**

```dart
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
  if (n == 22) return 0;
  return n;
}
```

- [ ] **Step 3: flutter analyze**

```bash
& "C:\Users\Juan Sanchez\flutter_sdk\flutter\bin\flutter.bat" analyze
```

- [ ] **Step 4: Commit**

```bash
git add -A; git commit -m "feat: tabla pitagorica estandar + mapeo 22→0 (El Loco)"
```
