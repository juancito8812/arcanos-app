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
- `constellations/constellation_screen.dart` — 6 tabs: Genograma, Rueda, Frases, Patrones, Interpretación IA, Sesiones
- `constellations/tabs/tab_genograma.dart` — Árbol genealógico con 3 generaciones, CRUD de miembros
- `constellations/tabs/tab_rueda.dart` — Rueda de 7 arcanos animada con numerología
- `constellations/tabs/tab_frases.dart` — 72 frases sanadoras en 3 niveles
- `constellations/tabs/tab_patrones.dart` — Patrones transgeneracionales detectados por IA
- `constellations/tabs/tab_interpretacion.dart` — Interpretación IA de constelación
- `constellations/tabs/tab_sesiones.dart` — Historial de sesiones de constelación

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
## Anchored Summary (2026-06-26)

### Goal
App de PsicoTarot con línea de vida, matriz de destino, constelaciones familiares (v2), carta diaria, biblioteca de 78 arcanos, IA configurable.

### Progress
- v2.2.2 released con fix de APK install (MethodChannel → Kotlin, reemplazó OpenFilex que sobreescribía flags)
- Código limpio tras code review + ponytail: sin errores, sin dead code (`FamilyMember` ahora activo)
- Constellation v2 completo: 6 tabs (genograma, rueda, frases, patrones, interpretación IA, sesiones)
- Healing phrases: 72 frases en 3 niveles
- DatabaseService extendido: `constellation_members` + `constellation_sessions`
- ConstellationService: asignación de arcanos por numerología, detección de patrones transgeneracionales, interpretación IA
- Ponytail cuts aplicados: eliminados copyWith, DB wrappers en service, bottom sheet → inline icons, custom expand → ExpansionTile, _buildEmptyState deduplicado
- `flutter analyze` — No issues found

### Commits clave (SHA más reciente primero)
- `ponytail cuts` — remove copyWith, DB wrappers, bottom sheet, custom expand, deduplicate emptyState
- `07692ef` — fixes: personalizar() bug, nested Scaffold, AI persistence, Guardar button no-op, input validation
- `dd9c474` — constellation v2: Genograma, Frases, Rueda refactor, Patrones, Interpretación IA, Sesiones
- `307b3d6` — v2.2.2 released + APK install fix con MethodChannel
- `d2e654f` — code review: README, AGENTS.md, handoff-actual.md actualizados
- `e63cd52` — revision docs created

### SHA actual: `b470678` (más reciente tras ponytail cuts commit)
