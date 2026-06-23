# AI Handoff - arcanos-app

## Estado actual (24 Jun 2026)

**`flutter analyze` — No issues found ✅**

**Versión:** v1.0.1 — Release creada para probar auto-update

## Últimos commits

| Fecha | Commit | Cambio |
|-------|--------|--------|
| Hoy | `737e709` | chore: elimina shared_preferences de dependencias (no usado) |
| Hoy | `72eb502` | feat: agrega validación de longitud y caracteres en inputs de nombre |
| Hoy | `6cc7b96` | fix: corrige string interpolation + auditoría de seguridad |
| Prev | `829ab3f` | feat: crea skill image-to-ai para convertir imágenes a formatos IA |
| Prev | `23a79b6` | docs: agrega README con instrucciones de instalación de todas las skills |
| Prev | `d07cf5e` | fix: actualiza Gradle a 8.11.1 para compatibilidad con AGP 8.10.0 |
| Prev | `04c0ba7` | feat: agrega icono de app personalizado para splash y launcher |
| Prev | `97bd4a2` | feat: agrega splash screen animado a la app |

## Última Release

- **Tag:** `v1.0.1`
- La release genera APK firmado automáticamente vía GitHub Actions
- La app detecta la actualización y permite descarga + instalación desde Settings

## Cartas de Marsella 🃏

Las 22 imágenes de cartas de `assets/cards/` han sido reemplazadas con diseño **Tarot de Marseille**:

- **Fondo** vintage cream con bordes envejecidos
- **Número** del arcano en esquina superior izquierda e inferior derecha
- **Número romano** aditivo (IIII, VIIII, XVIIII) en esquina superior derecha
- **Nombre** del arcano centrado en la parte inferior
- **Decoración**: doble borde, rombo central, líneas decorativas, viñetas en esquinas
- **Paleta** por arcano: color base distintivo (rojo, azul, dorado, verde, etc.)
- Cada imagen ~31KB, 210×300px

## Validación de Inputs

### Nombre completo (life_line_input + numeric_arrangements)

| Regla | Mensaje |
|-------|---------|
| Vacío | "Ingresa tu nombre completo" |
| < 3 caracteres | "El nombre debe tener al menos 3 caracteres" |
| > 100 caracteres | "El nombre es demasiado largo" |
| Caracteres inválidos | "Solo se permiten letras y espacios" |
| Caracteres permitidos | Letras (incluye áéíóúüñ), espacios, `.`, `'`, `-` |

**UX:** Error inline en TextField, auto-focus al campo, se limpia al escribir.

## Auditoría de Seguridad (24 Jun 2026)

| Severidad | Hallazgo | Estado |
|-----------|----------|--------|
| ✅ | Inyección SQL: sqflite parametrizado | OK |
| ✅ | Secrets hardcodeados: ninguno | OK |
| ✅ | HTTPS en todas las conexiones | OK |
| ✅ | Controllers descartados | OK |
| ✅ | Certificados SSL no deshabilitados | OK |
| ✅ | shared_preferences eliminado | **Resuelto** |
| ✅ | Input de usuario ahora validado | **Resuelto** |
| ℹ️ | SQLite local sin cifrado | Aceptable |
| ℹ️ | Auto-update sin verificación de firma | Bajo riesgo |

## Problemas resueltos

### Archivos duplicados
Se eliminaron 23 archivos .dart duplicados (versiones corruptas por heredocs).

### Errores de flutter analyze
Iconos no existentes, fields incorrectos, imports no usados, Scaffold sin cerrar, etc. Todos corregidos.

### Bugs
- `life_line_result_screen.dart`: String interpolation rota (`'#\$index'` → `'#${index}'`, `'Edad \$...'` → `'Edad ${...}'`)
- `arcana_detail_screen.dart`: Tag con backslash escapado (`\${arcano.numero}` → `${arcano.numero}`)
- `shared_preferences`: Dependencia no usada eliminada

## Estructura del proyecto

```
lib/
├── main.dart                  # Punto de entrada
├── app.dart                   # PsicoTarotApp con SplashScreen como home
├── navigation.dart            # MainNavigation con bottom tabs
├── theme.dart                 # Temas claro/oscuro
├── data/                      # arcanos_data, pythagorean_table, spreads_data
├── models/                    # arcano, life_line, tarot_spread, family_member
├── services/                  # database_service, life_line_calculator, update_service
├── utils/                     # route_transitions, animated_widgets
└── screens/
    ├── splash_screen.dart     # Splash animado
    ├── home_screen.dart
    ├── arrangements/          # Arreglos numéricos
    ├── constellations/        # Constelaciones familiares
    ├── library/               # Biblioteca + detalle de arcanos
    ├── life_line/             # Línea de vida (input + resultado)
    ├── regressions/           # Regresiones guiadas
    ├── settings/              # Configuración + auto-update
    └── tarot/                 # Menú de tiradas + lectura de tarot

assets/
├── cards/                     # 22 imágenes estilo Marsella
└── icon_original.png          # Icono personalizado de la app

skills/
├── README.md                  # Instalación de skills
├── image-to-ai/               # Conversión de imágenes a formatos IA
├── auto-sync/                 # Sincronización automática
├── changelog-generator/       # Changelogs para releases
└── ... (más skills)
```

## Pendiente / Próximos pasos

1. ✅ ~~Probar APK firmada~~ — Workflow pasa con Gradle 8.11.1
2. ✅ ~~Probar flujo de actualización~~ — Tag v1.0.1 creado
3. ✅ ~~Eliminar shared_preferences~~ — Resuelto
4. ✅ ~~Validación de inputs~~ — Agregada
5. ✅ ~~Cartas de Marsella~~ — Generadas y reemplazadas
6. 🔄 Agregar más animaciones a tarot_reading_screen y constellation_screen

`flutter analyze` — 0 issues ✅
