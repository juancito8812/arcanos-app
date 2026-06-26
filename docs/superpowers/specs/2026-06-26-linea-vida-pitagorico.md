# Línea de Vida — Sistema Pitagórico Estándar

## Cambios

### 1. Tabla pitagórica (`lib/data/pythagorean_table.dart`)

Reemplazar tabla actual (valores no estándar) por la tabla pitagórica clásica:

| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|
| A | B | C | D | E | F | G | H | I |
| J | K | L | M | N | O | P | Q | R |
| S | T | U | V | W | X | Y | Z |

- La letra Ñ (española, no existe en inglés) se mapea a 5 (mismo valor que N)
- `calcularValorNombre()` suma valores letra por letra, igual que antes
- Sin cambios en la interfaz de la función

### 2. Reducción teosófica (`lib/data/pythagorean_table.dart`)

La función `reduccionTeosofica()` reduce a 1-22 respetando 11/22. Pero los arcanos van de 0 a 21. Cuando el resultado es 22, se mapea a 0 (El Loco). Se añade:

```dart
if (n == 22) return 0;
```

después del bucle de reducción.

### 3. Calculadora (`lib/services/life_line_calculator.dart`)

Misma estructura de 5 posiciones:
- A1 = reducción del nombre completo (con nueva tabla)
- A2 = suma de dígitos de la fecha → reducción teosófica
- A3 = A2 reducido a dígito único (respetando 11/22, mismo while de antes)
- A4 = reducción(A1 + A3)
- A5 = reducción(A1 + A2 + A3 + A4)

Sin cambios estructurales. Solo cambian los valores numéricos por la nueva tabla.

### 4. Archivos afectados

- Modificar: `lib/data/pythagorean_table.dart` (tabla + mapeo 22→0)
- Modificar: `lib/services/life_line_calculator.dart` (ningún cambio real, solo usar la tabla corregida)

### 5. Verificación

- `flutter analyze` sin errores
- Los resultados numéricos cambian por la nueva tabla (es esperado)
