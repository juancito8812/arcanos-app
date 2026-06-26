# PsicoTarot App — Contexto para Agentes IA

## Stack
- Flutter 3.27+ / Dart 3.7+
- SQLite (sqflite) para persistencia
- flutter_secure_storage para API key
- SharedPreferences para historial y tema
- Navigator 1.0 con rutas push
- Tema: AppTheme (5 paletas, acento dorado #FFD700 fijo)
- IA: Proveedor genérico OpenAI-compatible (NVIDIA NIM, OpenAI, Together AI, etc.)

## Estructura clave

### Modelos
- `lib/models/arcano.dart` — 17 campos: id, numero, nombre, nombreRomano, leyEspiritual, leccionVida, miedoAsociado, descripcionGeneral, arquetipo, elemento, polaridad, valorNuclear, desafio, significadoPosicion, perspectivaTransgeneracional, colorAsociado, nivel, afirmacionSanadora
- `lib/models/arcano_menor.dart` — 7 campos: id, nombre, palo, rango, numero, elemento, significado. rangos: as, 2-10, sota, caballo, reina, rey
- `lib/models/life_line.dart` — LifeLineResult (5 ArcanoPosicion)
- `lib/models/destiny_matrix.dart` — DestinyMatrix (8 DestinyPosition)
- `lib/models/family_member.dart` — Definido pero sin uso actual (dead code)

### Datos
- `lib/data/arcanos_data.dart` — Lista `allArcanos` (22 items) + `getArcanoByNumero()`
- `lib/data/arcanos_menores_data.dart` — Lista `allArcanosMenores` (56 items, 4 palos x 14)
- `lib/data/pythagorean_table.dart` — Tabla pitagórica estándar A=1..Z=8, Ñ=5. `reduccionTeosofica()` con 22→0

### Servicios
- `life_line_calculator.dart` — 5 posiciones (YO, ELLO, MENTE, REALIZACION, SINTESIS)
- `destiny_matrix_calculator.dart` — 8 posiciones (day, month, year, essence, talent, challenge1, challenge2, purpose)
- `daily_card_service.dart` — Carta diaria: con perfil usa edad+arcanos, sin perfil es aleatoria
- `database_service.dart` — SQLite con tablas: perfiles, tiradas, regresiones, daily_cards
- `update_service.dart` — Check GitHub Releases + download + install con OpenFilex
- `ai_service.dart` — API key desde flutter_secure_storage, base URL y modelo desde SP
- `theme_provider.dart` — ChangeNotifier con paleta, modo, persistencia en SP

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
- `constellations/constellation_screen.dart` — 5 tabs + rueda de 7 arcanos animada

### Assets
- `assets/cards/arcano_0.jpg` a `arcano_77.jpg` — 78 cartas unificadas del Tarot de Marseille (mixvlad/TarotCards)

## Convenciones
- **Idioma:** Español para todo (código, comentarios, UI, commits)
- **Estilo:** Sin comentarios en código, nombres descriptivos en español
- **Imágenes:** 78 cartas Marseille unificadas en JPG
- **Git:** Commits en español, rama activa `master`, auto-commit tras cada edición
- **APK:** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- **Análisis:** `flutter analyze` — Sin errores permitidos, 1 info preexistente (`use_build_context_synchronously`)
- **Auto-commit:** Tras cada edición de archivo: `git add -A && git commit -m "checkpoint: <descripción>"`

## Flujo Línea de Vida → Matriz
1. Usuario ingresa nombre+fecha en LifeLineInputScreen
2. Se calcula y guarda en BD (DatabaseService.guardarPerfil)
3. DestinyMatrixScreen lee el primer perfil de BD y calcula matriz
4. DestinyMatrixScreen usa WidgetsBindingObserver para recargar al reanudar

## Handoff
Ver `docs/handoff-actual.md` para estado completo.
