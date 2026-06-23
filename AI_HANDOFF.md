# AI Handoff - arcanos-app

## Estado actual (23 Jun 2026)

**`flutter analyze` — No issues found ✅**

## Últimos commits

| Fecha | Commit | Cambio |
|-------|--------|--------|
| Hoy | `829ab3f` | feat: crea skill image-to-ai para convertir imágenes a formatos IA |
| Hoy | `23a79b6` | docs: agrega README con instrucciones de instalación de todas las skills |
| Hoy | `d07cf5e` | fix: actualiza Gradle a 8.11.1 para compatibilidad con AGP 8.10.0 |
| Hoy | `04c0ba7` | feat: agrega icono de app personalizado para splash y launcher |
| Hoy | `97bd4a2` | feat: agrega splash screen animado a la app |
| Prev | `54f10f4` | feat: changelog automático en releases de GitHub |
| Prev | `27110d4` | feat: firma de APK release con keystore para GitHub Actions |

## Nuevas funcionalidades

### 🎬 Splash Screen (`lib/screens/splash_screen.dart`)
- Animación con 3 fases: fade + scale del logo, glow pulsante dorado, texto y spinner
- Transición fade al menú principal tras 2.8s
- Usa `Image.asset('assets/icon_original.png')` con el icono personalizado

### 🎨 Icono de App Personalizado
- Icono 1024×1024 generado con estrella dorada sobre fondo púrpura degradado
- `flutter_launcher_icons` configurado para Android (todas las resoluciones mdpi–xxxhdpi)
- Adaptive icons configurados para Android 8+
- Script temporal `generate_icon.ps1` eliminado

### 🔧 Correcciones de infraestructura
- **Gradle 8.10.2 → 8.11.1**: Requerido por AGP 8.10.0. El workflow de GitHub Actions fallaba con "requires a minimum Gradle version of 8.11.1"
- **`MainNavigation` extraído a `navigation.dart`**: Rompe la importación circular entre `app.dart` y `splash_screen.dart`

### 📚 Skills de Freebuff
- **`skills/image-to-ai/`**: Skill para convertir imágenes a formatos que cualquier IA pueda entender. 3 modos:
  - `base64`: Codifica imagen a Base64 (para GPT-4V, Claude)
  - `tensor`: Convierte a array NumPy/PyTorch (formato (C,H,W) float32)
  - `text`: OCR con Tesseract
- **`skills/README.md`**: Documentación de instalación de todas las skills

## Auditoría de Seguridad (23 Jun 2026)

### Hallazgos

| Severidad | Hallazgo | Estado |
|-----------|----------|--------|
| ✅ | **Inyección SQL**: sqflite usa consultas parametrizadas (`insert()`, `query()`) — sin riesgo | OK |
| ✅ | **Hardcoded secrets**: No hay API keys, tokens ni contraseñas en el código | OK |
| ✅ | **Network**: Todas las conexiones usan HTTPS (GitHub API + descarga APK) | OK |
| ✅ | **Controller disposal**: Todos los `TextEditingController` se descartan en `dispose()` | OK |
| ✅ | **Certificados SSL**: No se deshabilita la verificación de certificados | OK |
| ✅ | **Cleartext HTTP**: `usesCleartextTraffic` no está habilitado — bloqueado por Android 9+ | OK |
| ✅ | **Debug permissions**: Solo INTERNET en debug manifest | OK |
| ✅ | **FileProvider**: Configurado correctamente para instalación de APK | OK |
| ⚠️ | **shared_preferences** en dependencias pero nunca importado en ningún `.dart` | **No usado** |
| ℹ️ | **Base de datos SQLite sin cifrado**: Almacena nombres, fechas y lecturas localmente | Aceptable |
| ℹ️ | **APK auto-update sin verificación de firma**: No se verifica la firma del APK descargado | Bajo riesgo |
| ℹ️ | **Input de usuario sin sanitizar**: Nombres sin validación de caracteres especiales | Bajo riesgo |

### Resumen
La app **no tiene vulnerabilidades críticas**. Todo el almacenamiento es local, no hay comunicación con servidores externos excepto para actualizaciones vía GitHub Releases (HTTPS). Los datos sensibles (nombres, fechas de nacimiento, lecturas de tarot) se almacenan en SQLite local sin cifrado — aceptable dado que la app declara en su política de privacidad que los datos no se comparten.

### Bugs encontrados y corregidos
1. **`life_line_result_screen.dart`**: String interpolation rota — `'#\$index'` mostraba literal `#$index` en lugar del número de posición. Corregido a `'#${index}'`.
2. **Mismo archivo**: `'Edad \\${...}'` no interpolaba la variable. Corregido.

## Estructura del proyecto

```
lib/
├── main.dart                  # Punto de entrada
├── app.dart                   # PsicoTarotApp con SplashScreen como home
├── navigation.dart            # MainNavigation con bottom tabs (extraído)
├── theme.dart                 # Temas claro/oscuro
├── data/                      # arcanos_data, pythagorean_table, spreads_data
├── models/                    # arcano, life_line, tarot_spread, family_member
├── services/                  # database_service, life_line_calculator, update_service
├── utils/                     # route_transitions, animated_widgets
└── screens/
    ├── splash_screen.dart     # Nuevo: splash animado
    ├── home_screen.dart
    ├── arrangements/          # numeric_arrangements_screen
    ├── constellations/        # constellation_screen
    ├── library/               # arcana_library_screen, arcana_detail_screen
    ├── life_line/             # life_line_input_screen, life_line_result_screen
    ├── regressions/           # regression_screen
    ├── settings/              # settings_screen (auto-update)
    └── tarot/                 # tarot_menu_screen, tarot_reading_screen

skills/
├── README.md                 # Instrucciones de instalación
├── auto-sync/                # Skill para sincronización automática
├── changelog-generator/      # Skill para generar changelogs
├── error-handling-patterns/  # Skill para patrones de manejo de errores
├── frontend-design/          # Skill para diseño frontend
├── image-to-ai/              # ¡Nuevo! Convertir imágenes a formatos IA
├── interface-design/         # Skill para diseño de interfaces
├── postgresql-table-design/  # Skill para diseño de tablas PostgreSQL
└── vercel-react-best-practices/  # Skill para Vercel/React
```

## Pendiente / Próximos pasos

1. **Probar APK firmada** — Confirmar que el workflow de GitHub Actions pasa con Gradle 8.11.1
2. **Probar flujo de actualización** — Tag v1.0.1 para verificar auto-update
3. **Eliminar shared_preferences** de dependencias si no se usa
4. **Agregar más animaciones** a tarot_reading_screen y constellation_screen

`flutter analyze` — 0 issues ✅
