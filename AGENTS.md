# PsicoTarot App — Contexto para Agentes IA

## Stack
- Flutter 3.27+ / Dart 3.7+
- SQLite (sqflite) para persistencia
- SharedPreferences para historial
- Navigator 1.0 con rutas push
- Tema: AppTheme (purplePrimary, goldAccent, purpleDark)

## Estructura clave

### Modelos
- `lib/models/arcano.dart` — 17 campos: id, numero, nombre, nombreRomano, leyEspiritual, leccionVida, miedoAsociado, descripcionGeneral, arquetipo, elemento, polaridad, valorNuclear, desafio, significadoPosicion, perspectivaTransgeneracional, colorAsociado, nivel, afirmacionSanadora
- `lib/models/arcano_menor.dart` — 7 campos: id, nombre, palo, rango, numero, elemento, significado. rangos: as, 2-10, sota, caballo, reina, rey
- `lib/models/life_line.dart` — LifeLineResult (5 ArcanoPosicion)
- `lib/models/destiny_matrix.dart` — DestinyMatrix (8 DestinyPosition)

### Datos
- `lib/data/arcanos_data.dart` — Lista `allArcanos` (22 items) + `getArcanoByNumero()`
- `lib/data/arcanos_menores_data.dart` — Lista `allArcanosMenores` (56 items, 4 palos x 14)
- `lib/data/pythagorean_table.dart` — `calcularValorNombre()`, `reduccionTeosofica()`, `sumarDigitosFecha()`

### Servicios
- `life_line_calculator.dart` — 5 posiciones (YO, ELLO, MENTE, REALIZACION, SINTESIS). a3 = reduccion de a2 (respetando 11/22). a4 = reduccion(a1 + a3). a5 = reduccion(a1+a2+a3+a4)
- `destiny_matrix_calculator.dart` — 8 posiciones (day, month, year, essence, talent, challenge1, challenge2, purpose). Reduce valores >21 sumando dígitos
- `daily_card_service.dart` — Carta diaria: con perfil usa edad+arcanos, sin perfil es aleatoria
- `database_service.dart` — SQLite con tablas: perfiles, tiradas, regresiones, daily_cards

### Pantallas principales
- `home_screen.dart` — Grid con 6 módulos + Carta del Día
- `navigation.dart` — Bottom nav: Inicio, Matriz, Arcanos, Ajustes
- `library/arcana_library_screen.dart` — Tabs Mayores (22 grid) / Menores (56 grid) + búsqueda
- `library/arcana_detail_screen.dart` — 7 secciones para mayores
- `library/arcano_menor_detail_screen.dart` — Imagen, nombre, palo, elemento, significado
- `life_line/life_line_input_screen.dart` — Nombre + fecha, guarda perfil en BD
- `life_line/life_line_result_screen.dart` — Muestra 5 arcanos con imágenes
- `numerology/destiny_matrix_screen.dart` — 8 posiciones con imágenes
- `settings/settings_screen.dart` — Versión desde package_info_plus, API key, notificación

### Assets
- `assets/cards/arcano_0.png` a `arcano_21.png` — 22 arcanos mayores (Tarot Marseille, Jean Dodal)
- `assets/cards/minor/{Suit}{NN}.jpg` — 56 arcanos menores con suit: Cups, Pents, Swords, Wands y NN: 01-14 (01=As, 11=Sota, 12=Caballo, 13=Reina, 14=Rey)

## Convenciones
- **Idioma:** Español para todo (código, comentarios, UI, commits)
- **Estilo:** Sin comentarios en código, nombres descriptivos en español
- **Imágenes:** Tarot de Marseille (Jean Dodal 1715 para mayores, Lequart/Conver para menores)
- **Git:** Commits en español, rama activa `feature/phase1-bundle`
- **APK:** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- **Análisis:** `flutter analyze` — Sin errores permitidos, 1 info preexistente (`use_build_context_synchronously`)

## Flujo Línea de Vida → Matriz
1. Usuario ingresa nombre+fecha en LifeLineInputScreen
2. Se calcula y guarda en BD (DatabaseService.guardarPerfil)
3. DestinyMatrixScreen lee el primer perfil de BD y calcula matriz
4. DestinyMatrixScreen usa WidgetsBindingObserver para recargar al reanudar
