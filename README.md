# PsicoTarot

App Flutter de PsicoTarot basada en los 78 Arcanos del Tarot de Marseille unificados. Ofrece análisis numerológicos, líneas de vida, tiradas interactivas, constelaciones familiares, matriz del destino, carta diaria y regresiones.

## Características

- **Biblioteca de Arcanos** — 22 Arcanos Mayores con 7 secciones (Ley Espiritual, Lección de Vida, Arquetipo, Desafío, Perspectiva Transgeneracional, Significado en Posición, Afirmación Sanadora) + 56 Arcanos Menores (Copas, Bastos, Espadas, Oros) con significado por carta
- **Línea de Vida** — Calcula 5 arcanos personales (YO, ELLO, MENTE, REALIZACIÓN, SÍNTESIS) usando tabla pitagórica estándar (A=1...Z=8, Ñ=5)
- **Tiradas de Tarot** — 5 tipos: 3 Cartas, Tríada Vida Pasada, Viaje Vidas Pasadas, Constelación Familiar, Árbol Genealógico. Animaciones de revelación y lectura con IA
- **Arreglos Numéricos** — 8 análisis: Relación Nuclear, Factor Espejo/Cobel, Arreglo de Maya, Consciencia, Trampas de Maya, Polaridad, Tríos, 4 niveles de 5
- **Matriz del Destino** — Cálculo de 8 posiciones numerológicas
- **Constelaciones Familiares** — 3 principios (Pertenencia, Orden, Equilibrio), rueda de 7 arcanos con animación, secretos familiares, frases sanadoras
- **Regresiones** — Guía interactiva de regresión
- **Carta del Día** — Banner diario con o sin perfil
- **5 Paletas de Color** — Azul, Rosa, Verde, Naranja, Violeta — con acento dorado fijo (#FFD700)
- **Actualización en App** — Descarga automática de nuevas versiones desde GitHub Releases
- **Seguridad** — API key cifrada con Android Keystore, Network Security Config, R8 ofuscación, release firmado

## Stack

- **Framework:** Flutter (3.27+)
- **Lenguaje:** Dart (3.7+)
- **Persistencia:** SQLite (sqflite), SharedPreferences, flutter_secure_storage
- **Imágenes:** 78 cartas unificadas del Tarot de Marseille en `assets/cards/arcano_{0..77}.jpg`
- **IA:** Proveedor genérico compatible con OpenAI (NVIDIA NIM, OpenAI, Together AI, etc.)

## Requisitos

- Flutter SDK (3.27+)
- Dart SDK
- JDK 17+ (para build Android)

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

APK firmado en: `build/app/outputs/flutter-apk/app-release.apk`

## Verificar análisis

```bash
flutter analyze
```

## Seguridad

- Release firmado con keystore personal (`upload-keystore.jks`)
- API key almacenada en `flutter_secure_storage` (Android Keystore)
- `network_security_config.xml` — deniega HTTP claro, solo CAs del sistema
- `allowBackup=false`
- R8 con minify + shrink resources activado

## Metodología Línea de Vida

Basado en el manual "Formación de PsicoTarot Personal, Transpersonal y Sistémico Transgeneracional" (Psic. Blanca E. Siso M.) con tabla pitagórica estándar:

1. **YO**: Valor del nombre completo por tabla pitagórica → reducción teosófica (1-22, con 22→0 El Loco)
2. **ELLO**: Suma de dígitos de la fecha → reducción teosófica
3. **MENTE**: Reducción de ELLO (respetando 11/22 como maestros)
4. **REALIZACIÓN**: YO + MENTE → reducción
5. **SÍNTESIS**: Suma de los 4 anteriores → reducción teosófica

## Estado

✅ `flutter analyze` — Sin errores (1 info preexistente: `use_build_context_synchronously`)

## Repositorio

https://github.com/juancito8812/arcanos-app

Versión actual: 2.2.1+6
