# PsicoTarot

App Flutter de PsicoTarot basada en los 78 Arcanos del Tarot de Marseille. Ofrece análisis numerológicos, líneas de vida, tiradas interactivas, constelaciones familiares y matriz del destino.

## Características

- **Biblioteca de Arcanos** — 22 Arcanos Mayores con 7 secciones (Ley Espiritual, Lección de Vida, Arquetipo, Desafío, Perspectiva Transgeneracional, Significado en Posición, Afirmación Sanadora) + 56 Arcanos Menores (Copas, Bastos, Espadas, Oros) con significado por carta
- **Línea de Vida** — Calcula 5 arcanos personales (YO, ELLO, MENTE, REALIZACIÓN, SÍNTESIS) usando Rueda Pitagórica
- **Tiradas de Tarot** — 5 tipos: 3 Cartas, Tríada Vida Pasada, Viaje Vidas Pasadas, Constelación Familiar, Árbol Genealógico. Animaciones de revelación y lectura con IA
- **Arreglos Numéricos** — 8 análisis: Relación Nuclear, Factor Espejo/Cobel, Arreglo de Maya, Consciencia, Trampas de Maya, Polaridad, Tríos, 4 niveles de 5
- **Matriz del Destino** — Cálculo de 8 posiciones numerológicas
- **Constelaciones Familiares** — 3 principios (Pertenencia, Orden, Equilibrio), secretos familiares, frases sanadoras
- **Regresiones** — Guía interactiva de regresión

## Stack

- **Framework:** Flutter
- **Lenguaje:** Dart
- **Imágenes:** 22 Arcanos Mayores (PNG, Jean Dodal 1715) + 56 Arcanos Menores (JPG, Tarot de Marseille dominio público) en `assets/cards/`

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
├── navigation.dart
├── data/
│   ├── arcanos_data.dart          # 22 arcanos mayores (descr. completas)
│   ├── arcanos_menores_data.dart  # 56 arcanos menores (4 palos)
│   ├── spreads_data.dart          # 5 tipos de tirada
│   └── pythagorean_table.dart     # Tabla pitagórica + reducción teosófica
├── models/
│   ├── arcano.dart                # Modelo (17 campos)
│   ├── arcano_menor.dart          # Modelo menor (palo, rango, elemento)
│   ├── life_line.dart             # Línea de vida + posición
│   ├── destiny_matrix.dart        # Matriz del Destino
│   └── tarot_spread.dart          # Tiradas y cartas
├── services/
│   ├── life_line_calculator.dart      # Cálculo Línea de Vida
│   ├── destiny_matrix_calculator.dart # Cálculo Matriz del Destino
│   ├── daily_card_service.dart        # Carta del Día
│   ├── database_service.dart          # SQLite (perfiles, tiradas, etc.)
│   ├── ai_service.dart                # Interpretación con IA (NVIDIA NIM)
│   └── notification_service.dart      # Notificaciones diarias
├── widgets/
│   └── daily_card_banner.dart         # Banner Carta del Día
├── utils/
│   ├── route_transitions.dart
│   └── animated_widgets.dart
└── screens/
    ├── home_screen.dart
    ├── numerology/         # Matriz del Destino
    ├── arrangements/       # Arreglos numéricos
    ├── constellations/     # Constelaciones familiares
    ├── library/            # Biblioteca (Mayores + Menores) + detalle
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
