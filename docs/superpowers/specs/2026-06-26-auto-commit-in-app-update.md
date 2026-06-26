# Auto-Commit + Actualización desde la APK

## Resumen
Dos funcionalidades: (1) commits automáticos tras cada edición de archivo para facilitar deshacer cambios, y (2) sistema de actualización in-app que descarga la nueva APK desde GitHub Releases y abre el instalador de Android.

---

## Auto-Commit

### Comportamiento
- Después de cada operación `write` o `edit` sobre archivos del proyecto, se ejecuta `git add -A && git commit -m "checkpoint: <descripción breve>"`
- Los commits son locales y descriptivos; no se pushean automáticamente
- No interfiere con commits de features/releases (el desarrollador sigue haciendo commits semánticos cuando corresponde)

### Propósito
- Poder volver a cualquier estado intermedio con `git log` + `git checkout`
- Sin depender de skills externas — es un proceso del agente

---

## In-App Update

### Dependencias existentes (ya en pubspec.yaml)
- `dio: ^5.9.2` — descarga HTTP con progreso
- `open_filex: ^4.7.0` — abre el APK descargado lanzando el instalador de Android
- `package_info_plus: ^9.0.1` — versión actual de la app
- `path_provider: ^2.1.5` — directorio temporal para el APK descargado

### Servicio: `lib/services/update_service.dart`

```
class UpdateService {
  static Future<UpdateInfo?> checkForUpdate() async
  static Future<void> downloadAndInstall({
    required String url,
    required BuildContext context,
    void Function(double progress)? onProgress,
  }) async
}
```

#### checkForUpdate()
1. Obtiene versión actual via `package_info_plus` (ej. 2.1.0+4)
2. GET a `https://api.github.com/repos/juancito8812/arcanos-app/releases/latest`
3. Parsea `tag_name` (ej. "v2.2.0"), extrae versión semántica
4. Compara: si tag > versionActual → retorna `UpdateInfo(tagName, downloadUrl, body)`
5. Si no hay nueva versión → retorna null
6. Si hay error de red/GitHub → retorna null (falla silenciosa)

#### UpdateInfo
```dart
class UpdateInfo {
  final String version;
  final String downloadUrl;  // URL del APK en GitHub Releases
  final String? changelog;   // body del release
}
```

#### downloadAndInstall()
1. Muestra diálogo con progreso (LinearProgressIndicator)
2. Descarga APK con `dio.download()` a `getApplicationDocumentsDirectory() + "/psicotarot-update.apk"`
3. Al completar: `OpenFilex.open(path)` → lanza el intent del instalador de Android
4. Manejo de errores: si falla la descarga, snackbar con mensaje

### Integración UI

#### En HomeScreen
- Al cargar HomeScreen, ejecutar `checkForUpdate()` en segundo plano
- Si hay actualización, mostrar un pequeño badge o banner: "Nueva versión disponible"
- Al tap: abrir el mismo diálogo de actualización

#### En Settings (`lib/screens/settings/settings_screen.dart`)
- Añadir card "Actualización" con:
  - Botón "Buscar actualizaciones"
  - Texto con versión actual (via `package_info_plus`)
  - Al encontrar update: diálogo con changelog + botón descargar

#### Diálogo de actualización
```
Título: "Nueva versión v2.2.0 disponible"
Cuerpo: changelog del release (scroll si es largo)
Botón primario: "Descargar e instalar" → inicia downloadAndInstall()
Botón secundario: "Más tarde" → cierra el diálogo
Durante descarga: diálogo reemplazado por progress bar + "Descargando..."
Al completar: se cierra solo, el instalador de Android se abre automáticamente
```

### Flujo completo
1. Usuario abre app → HomeScreen chequea update en background
2. Si hay: badge/banner visible + diálogo automático si no se mostró en 24h
3. Usuario va a Settings → "Buscar actualizaciones" manual
4. Tap → diálogo con info de la nueva versión
5. Tap "Descargar e instalar" → barra de progreso
6. Descarga completa → `open_filex` lanza instalador de Android
7. Usuario confirma instalación → app se actualiza

### Auto-detección en HomeScreen
- Ejecutar `checkForUpdate()` en un `Future.delayed` de 2s después de montar HomeScreen
- No bloquear la UI
- Si hay update nuevo (nunca mostrado antes), mostrar diálogo automáticamente
- Si el usuario cierra sin instalar, no mostrar again por 24h (SharedPreferences `last_update_reminder`)
- Si hay badge/banner, siempre visible hasta que se instale la nueva versión

### Consideraciones
- Android requiere permiso "Install from unknown sources" — el instalador nativo lo gestiona
- El APK se descarga a `getApplicationDocumentsDirectory()` (no requiere permisos de almacenamiento externo)
- `open_filex` maneja FileProvider para Android 10+ automáticamente
- Fallback: si `open_filex` falla, mostrar snackbar con la URL de descarga manual
- La release en GitHub debe incluir el APK como asset con nombre `app-release.apk`

---

## Versionado
- La primera release con esta feature: 2.2.0+5
- El tag en GitHub debe coincidir con el versionName del pubspec

## Commits esperados
1. `checkpoint: crear UpdateService`
2. `checkpoint: integrar UpdateService en HomeScreen (check automático)`
3. `checkpoint: añadir sección de actualización en Settings`
4. `checkpoint: diálogo de actualización con progreso`
5. `feat: in-app update + bump version 2.2.0+5`
6. `checkpoint: build APK release + tag v2.2.0`
7. `checkpoint: crear GitHub Release v2.2.0 con APK`
