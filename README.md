# 🔮 PsicoTarot Arcanos Mayores

App Flutter de PsicoTarot basada en los 22 Arcanos Mayores del Tarot. Ofrece análisis numerológicos, líneas de vida, tiradas de tarot interactivas y constelaciones familiares.

## Características

- **Biblioteca de Arcanos** — Explora los 22 Arcanos Mayores con imágenes, leyes espirituales y lecciones de vida
- **Línea de Vida** — Calcula tus 5 arcanos personales basados en tu fecha de nacimiento
- **Tiradas de Tarot** — Lecturas interactivas con animaciones de cartas
- **Arreglos Numéricos** — 8 análisis: Línea de Vida, Relación Nuclear, Factor Espejo/Cobel, Arreglo de Maya, Consciencia, Trampas de Maya, Polaridad, Tríos
- **Constelaciones Familiares** — Información sobre los 3 principios (Pertenencia, Orden, Equilibrio), secretos familiares y frases sanadoras
- **Regresiones** — Guía interactiva de regresión

## Stack

- **Framework:** Flutter
- **Lenguaje:** Dart
- **Imágenes:** 22 PNG de cartas en `assets/cards/`

## Requisitos

- Flutter SDK (última versión estable)
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
├── data/           # Datos de arcanos, spreads, tablas
├── models/         # Modelos: Arcano, LifeLine, TarotSpread, etc.
├── services/       # Lógica: LifeLineCalculator, DatabaseService
├── utils/          # Animaciones y transiciones reutilizables
│   ├── route_transitions.dart
│   └── animated_widgets.dart
└── screens/
    ├── home_screen.dart
    ├── arrangements/    # Arreglos numéricos
    ├── constellations/  # Constelaciones familiares
    ├── library/         # Biblioteca y detalle de arcanos
    ├── life_line/       # Línea de vida (input + resultado)
    ├── regressions/     # Regresiones
    ├── settings/        # Ajustes
    └── tarot/           # Menú de tiradas y lectura
```

## Estado

✅ `flutter analyze` — No issues found

## Repositorio

https://github.com/juancito8812/arcanos-app
