# PsicoTarot Arcanos Mayores

App Flutter de PsicoTarot basada en los 22 Arcanos Mayores del Tarot. Ofrece análisis numerológicos, líneas de vida, tiradas interactivas, constelaciones familiares y matriz del destino.

## Características

- **Biblioteca de Arcanos** — 22 arcanos con 7 secciones: Ley Espiritual, Lección de Vida, Arquetipo, Desafío, Perspectiva Transgeneracional, Significado en Posición, Afirmación Sanadora. Cada arcano incluye nivel (1-3), color asociado y elemento
- **Línea de Vida** — Calcula 5 arcanos personales (YO, ELLO, MENTE, REALIZACIÓN, SÍNTESIS) usando Rueda Pitagórica, con manejo de números maestros (11/22) según metodología PsicoTarot
- **Tiradas de Tarot** — 5 tipos: 3 Cartas, Tríada Vida Pasada, Viaje Vidas Pasadas, Constelación Familiar, Árbol Genealógico. Animaciones de revelación y lectura con IA
- **Arreglos Numéricos** — 8 análisis: Relación Nuclear, Factor Espejo/Cobel, Arreglo de Maya, Consciencia, Trampas de Maya, Polaridad, Tríos, 4 niveles de 5
- **Matriz del Destino** — Cálculo de matriz numerológica personal
- **Constelaciones Familiares** — 3 principios (Pertenencia, Orden, Equilibrio), secretos familiares, frases sanadoras
- **Regresiones** — Guía interactiva de regresión

## Stack

- **Framework:** Flutter
- **Lenguaje:** Dart
- **Imágenes:** 22 PNG Tarot de Marseille (Jean Dodal 1715) en `assets/cards/`

## Requisitos

- Flutter SDK (3.27+)
- Dart SDK

## Instalación

```bash
git clone https://github.com/juancito8812/arcanos-app.git
cd arcanos-app
flutter pub get
```

## Ejecutar

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

## Verificar análisis

```bash
flutter analyze
```

## Estructura del proyecto

```
lib/
├── main.dart
├── app.dart
├── theme.dart
├── data/
│   ├── arcanos_data.dart      # 22 arcanos con descripciones completas
│   ├── spreads_data.dart      # 5 tipos de tirada
│   └── pythagorean_table.dart # Tabla pitagórica + reducción teosófica
├── models/
│   ├── arcano.dart            # Modelo con 11 campos
│   ├── life_line.dart         # Línea de vida + posición
│   └── tarot_spread.dart      # Tiradas y cartas
├── services/
│   ├── life_line_calculator.dart  # Cálculo (PDF methodology)
│   ├── destiny_matrix_calculator.dart
│   └── ai_service.dart        # Interpretación con IA (NVIDIA NIM)
├── utils/
│   ├── route_transitions.dart
│   └── animated_widgets.dart
└── screens/
    ├── home_screen.dart
    ├── arrangements/       # Arreglos numéricos
    ├── constellations/     # Constelaciones familiares
    ├── library/            # Biblioteca + detalle de arcanos
    ├── life_line/          # Input, resultado, detalle
    ├── regressions/        # Regresiones
    ├── settings/           # Ajustes y API key
    └── tarot/              # Menú de tiradas y lectura
```

## Metodología Línea de Vida

Basado en el manual "Formación de PsicoTarot Personal, Transpersonal y Sistémico Transgeneracional" (Psic. Blanca E. Siso M.):

1. **YO**: Suma pitagórica del nombre completo → reducción teosófica (1-22)
2. **ELLO**: Suma de dígitos de la fecha de nacimiento → reducción teosófica
3. **MENTE**: Si el año suma 11/22 (maestro) → se usa el mes; sino → reducción a dígito único
4. **REALIZACIÓN**: Si se usó el mes → a1 + a2; sino → a1 + a3
5. **SÍNTESIS**: Suma de los 4 anteriores → reducción teosófica

## Estado

✅ `flutter analyze` — Sin errores (1 info preexistente: `use_build_context_synchronously`)

## Repositorio

https://github.com/juancito8812/arcanos-app
