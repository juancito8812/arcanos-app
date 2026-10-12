# PsicoTarot App — Contexto para Agentes IA

## Stack
- Flutter 3.27+ / Dart 3.7+ (verificado con Flutter 3.47.7 stable)
- Android: Gradle 8.14.3, AGP 8.11.1, Kotlin 2.2.20, Java 17, minSdk 23, compileSdk/targetSdk 36, NDK 27.0.12077973
- SQLite (sqflite) para persistencia
- flutter_secure_storage para API key
- SharedPreferences para historial y tema
- Navigator 1.0 con rutas push
- Tema: AppTheme (5 paletas, acento dorado #FFD700 fijo)
- IA: Proveedor genérico OpenAI-compatible (NVIDIA NIM, OpenAI, Together AI, etc.)

## Estructura clave

### Modelos
- `lib/models/arcano.dart` — 18 campos: id, numero, nombre, nombreRomano, leyEspiritual, leccionVida, miedoAsociado, descripcionGeneral, arquetipo, elemento, polaridad, valorNuclear, desafio, significadoPosicion, perspectivaTransgeneracional, colorAsociado, nivel, afirmacionSanadora
- `lib/models/arcano_menor.dart` — 7 campos: id, nombre, palo, rango, numero, elemento, significado. rangos: as, 2-10, sota, caballo, reina, rey
- `lib/models/life_line.dart` — LifeLineResult (5 ArcanoPosicion)
- `lib/models/destiny_matrix.dart` — DestinyMatrix (8 DestinyPosition)
- `lib/models/family_member.dart` — 11 campos: id, nombre, relacion, generacion, eventos, fechaNacimiento, fechaEvento, arcanosAsignados, patternsDetectados, sessionId, fecha
- `lib/models/constellation_session.dart` — ConstellationSession con id, fecha, notas, interpretacionIA

### Datos
- `lib/data/arcanos_data.dart` — Lista `allArcanos` (22 items) + `getArcanoByNumero()`
- `lib/data/arcanos_menores_data.dart` — Lista `allArcanosMenores` (56 items, 4 palos x 14)
- `lib/data/pythagorean_table.dart` — Tabla pitagórica estándar A=1..Z=8, Ñ=5. `reduccionTeosofica()` con 22→0
- `lib/data/healing_phrases_data.dart` — 72 frases sanadoras en 3 niveles (familiar, personal, avanzado)

### Servicios
- `life_line_calculator.dart` — 5 posiciones (YO, ELLO, MENTE, REALIZACION, SINTESIS)
- `destiny_matrix_calculator.dart` — 8 posiciones (day, month, year, essence, talent, challenge1, challenge2, purpose)
- `daily_card_service.dart` — Carta diaria: con perfil usa edad+arcanos, sin perfil es aleatoria
- `database_service.dart` — SQLite con tablas: perfiles, tiradas, regresiones, daily_cards, constellation_members, constellation_sessions
- `update_service.dart` — Check GitHub Releases + download + install con MethodChannel (Kotlin)
- `ai_service.dart` — API key desde flutter_secure_storage, base URL y modelo desde SP
- `theme_provider.dart` — ChangeNotifier con paleta, modo, persistencia en SP
- `constellation_service.dart` — Asignación de arcanos por numerología, detección de patrones transgeneracionales, interpretación IA

### Pantallas principales
- `home_screen.dart` — Grid con 6 módulos + Carta del Día + banner de actualización
- `navigation.dart` — Bottom nav: Inicio, Matriz, Arcanos, Ajustes
- `library/arcana_library_screen.dart` — Tabs Mayores (22 grid) / Menores (56 grid) + búsqueda
- `library/arcana_detail_screen.dart` — 7 secciones para mayores
- `library/arcano_menor_detail_screen.dart` — Imagen, nombre, palo, elemento, significado
- `life_line/life_line_input_screen.dart` — Nombre + fecha, guarda perfil en BD
- `life_line/life_line_result_screen.dart` — Muestra 5 arcanos con imágenes
- `numerology/destiny_matrix_screen.dart` — 8 posiciones con imágenes
- `settings/settings_screen.dart` — Versión, selector de paleta, API key (URL + modelo + key), actualización
- `constellations/constellation_screen.dart` — 6 tabs: Qué es?, 3 Leyes, Genograma, Rueda, Frases, Patrones
- `constellations/tabs/tab_genograma.dart` — Árbol genealógico con 3 generaciones, CRUD de miembros
- `constellations/tabs/tab_rueda.dart` — Rueda de 7 arcanos animada con numerología y persistencia de sesión
- `constellations/tabs/tab_frases.dart` — 72 frases sanadoras en 3 niveles
- `constellations/tabs/tab_patrones.dart` — Patrones transgeneracionales detectados por IA

### Assets
- `assets/cards/arcano_0.jpg` a `arcano_77.jpg` — 78 cartas unificadas del Tarot de Marseille (mixvlad/TarotCards)

## Convenciones
- **Idioma:** Español para todo (código, comentarios, UI, commits)
- **Estilo:** Sin comentarios en código, nombres descriptivos en español
- **Imágenes:** 78 cartas Marseille unificadas en JPG
- **Git:** Commits en español, rama activa `master`, auto-commit tras cada edición
- **APK:** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- **Análisis:** `flutter analyze` — por defecto trata **infos y warnings como fatales** (`fatal-infos`/`fatal-warnings` = true). Debe quedar en cero issues, porque el CI (`build-apk.yml`) corre `flutter analyze` y falla con cualquiera.
- **Auto-commit:** Tras cada edición de archivo: `git add -A && git commit -m "checkpoint: <descripción>"`

## Flujo Línea de Vida → Matriz
1. Usuario ingresa nombre+fecha en LifeLineInputScreen
2. Se calcula y guarda en BD (DatabaseService.guardarPerfil)
3. DestinyMatrixScreen lee el primer perfil de BD y calcula matriz
4. DestinyMatrixScreen usa WidgetsBindingObserver para recargar al reanudar

## Deploy
```bash
# 1. Bump version en pubspec.yaml
# 2. Build
flutter build apk --release
# 3. Commit + push
git add -A && git commit -m "checkpoint: bump version X.X.X"
git push origin master
# 4. Release
gh release create vX.X.X "build/app/outputs/flutter-apk/app-release.apk#app-release.apk" --title "vX.X.X" --notes "## vX.X.X%0A%0A### Descripción" --repo juancito8812/arcanos-app
```

## Handoff
Ver `docs/handoff-actual.md` para estado completo.

---
## Anchored Summary (2026-10-12)

### Goal
App de PsicoTarot con línea de vida, matriz de destino, constelaciones familiares (v2), carta diaria, biblioteca de 78 arcanos, IA configurable.

### Estado
- Versión: `2.3.0+8` (pubspec.yaml)
- Rama: `master`, sincronizada con `origin/master`
- HEAD: `ff599ae` — checkpoint: bump version 2.3.0
- Última release: `v2.3.0` (GitHub Releases, APK firmado 48.7 MB)
- Tags: `v1.0.1`, `v1.1.0-test`, `v1.1.1-test`, `v2.0.0`, `v2.1.0`, `v2.2.0`, `v2.2.1`, `v2.2.2`, `v2.3.0`

### Progress
- Constellation v2 completo: 6 tabs (Qué es?, 3 Leyes, Genograma, Rueda, Frases, Patrones)
- Healing phrases: 72 frases en 3 niveles
- DatabaseService: 6 tablas (perfiles, tiradas, regresiones, daily_cards, constellation_members, constellation_sessions)
- ConstellationService: asignación de arcanos por numerología, detección de patrones transgeneracionales, interpretación IA
- `FamilyMember` activo (toMap/fromMap; usado por ConstellationService y TabGenograma)

### Commits clave (SHA más reciente primero)
- `ff599ae` — bump version 2.3.0
- `07692ef` — fixes: personalizar() bug, nested Scaffold, AI persistence, Guardar button no-op, input validation
- `dd9c474` — constelaciones v2: genograma, rueda sistémica, frases por capas, patrones, IA, persistencia BD
- `307b3d6` — TabRueda: rueda constelacional animada
- `d2e654f` — TabFrases: secciones expandibles + selector de miembro

### Conocido
- El CI (`build-apk.yml`) solo compila APK `--debug` y sube artifact: **no firma ni crea releases** (las releases se crean a mano con `gh release create`)
- El CI usa `channel: stable` sin pin: cada subida de Flutter stable puede exigir modernizar Gradle/AGP/minSdk
- `flutter build` avisa que el plugin `jni` pide NDK 28.2.13676358 (hoy 27.0.12077973; el build pasa igual)
- El SHA `b470678` que citaba el resumen anterior NO existe en el repositorio
