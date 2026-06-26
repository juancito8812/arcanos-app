# AI Handoff - arcanos-app

## Estado actual (24 Jun 2026)

**`flutter analyze` — No issues found ✅**

**Versión:** v1.0.1 — Release verificada con APK adjunto (23.5 MB)

## Últimos commits

| Fecha | Commit | Cambio |
|-------|--------|--------|
| Hoy | `b590180` | docs: actualiza AI_HANDOFF.md con animaciones, cartas Marsella y últimos cambios |
| Hoy | `2cf1b77` | feat: agrega animaciones a tarot_reading_screen y constellation_screen |
| Hoy | `06e6453` | feat: reemplaza imagenes de cartas con diseno Marsella v1.0.1 |
| Hoy | `737e709` | chore: elimina shared_preferences de dependencias (no usado) |
| Hoy | `72eb502` | feat: agrega validación de longitud y caracteres en inputs de nombre |
| Hoy | `6cc7b96` | fix: corrige string interpolation + auditoría de seguridad |
| Prev | `829ab3f` | feat: crea skill image-to-ai para convertir imágenes a formatos IA |
| Prev | `23a79b6` | docs: agrega README con instrucciones de instalación de todas las skills |
| Prev | `d07cf5e` | fix: actualiza Gradle a 8.11.1 para compatibilidad con AGP 8.10.0 |

## Última Release — v1.0.1 ✅

- **Tag:** `v1.0.1` → commit `b590180`
- **Release creada:** PsicoTarot v1.0.1 (2026-06-23)
- **APK:** `app-release.apk` — **23.5 MB** (0 descargas)
- **Flujo de actualización:** Settings → Actualizaciones → Buscar actualizaciones → detecta v1.0.1 y permite descargar/instalar

## Animaciones Agregadas 🎬

### `tarot_reading_screen.dart`

| Animación | Descripción |
|-----------|-------------|
| 🔄 Shuffle | Icono rotando 3 vueltas completas + glow pulsante dorado |
| 🎯 Revelado escalonado | Cartas aparecen con fade + scale (Curves.easeOutBack), cada una con delay progresivo |
| 👆 Hover press-scale | Al tocar una carta, escala suavemente a 1.02× |
| 📖 Expand/Colapso | Tap expande la ley espiritual (AnimatedCrossFade) + icono chevron rotate (AnimatedRotation) |
| ✨ Glow pulsante | Durante barajado: círculo con glow + icono giratorio + texto fade in + barra de progreso estilizada |

### `constellation_screen.dart`

| Animación | Descripción |
|-----------|-------------|
| 🌟 Header pulsante | Gradiente con glow que pulsa (3s repeat reverse) |
| 🏷️ Tabs con press-scale | Cada chip se escala al presionar (0.92×), con sombra y borde dinámicos |
| 🎡 Rueda con CustomPainter | Líneas radiales + círculo con glow pulsante, cartas vuelan desde el centro (easeOutBack) |
| 🃏 Hover en cartas | Scale 1.12× + sombra al tocar carta de la rueda |
| 💬 Frases con color | Cada frase con icono y color distintivo + icono quote |
| 🔒 Secretos animados | Cada secreto con entrada escalonada, icono por orden (man, woman, favorite, home) |
### `life_line_result_screen.dart` (NUEVA)
| Animacion | Descripcion |
|-----------|-------------|
| Presion en tarjetas | _PosCard escala a 0.96x al presionar |
### `regression_screen.dart` (NUEVA)
| Animacion | Descripcion |
|-----------|-------------|
| Entrada escalonada | StaggeredFadeIn en tarjetas de tipo |
| Transicion suave | AnimatedContainer en seleccion de tipo |
| Fade en descripcion | AnimatedSwitcher al cambiar de tipo |
| Presion en pasos | Escala al presionar (GestureDetector + AnimatedBuilder) |

### Fix crítico aplicado
- `SingleTickerProviderStateMixin` → `TickerProviderStateMixin` en 3 estados que usan múltiples `AnimationController` (evita crash en runtime)
- `use_build_context_synchronously` arreglado: agregado `if (!mounted) return;` antes de navegacion
- Eliminados metodos `_paloAsset`/`_rangoAsset` no usados (reemplazados por nueva nomenclatura)

## Cartas Rider-Waite-Smith 🃏

Las imagenes de cartas se unificaron bajo la nomenclatura `arcano_XX.jpg` usando el mazo **Rider-Waite-Smith** (dominio publico, Pamela Colman Smith, 1909).

- **22 Arcanos Mayores**: `arcano_00.jpg` - `arcano_21.jpg` (completos)
- **Número** del arcano en esquina superior izquierda e inferior derecha
- **Directorio unico**: todas las cartas en `assets/cards/`, mismo formato `.jpg`
- **Nombre** del arcano centrado en la parte inferior
- **Decoración**: doble borde, rombo central, líneas decorativas, viñetas en esquinas (arcos), patrón sutil
- **Paleta** por arcano: color base distintivo (rojo, azul, dorado, verde, etc.)
- Cada imagen ~31KB, 210×300px

## Validación de Inputs

### Nombre completo (life_line_input + numeric_arrangements)

| Regla | Mensaje |
|-------|---------|
| Vacío | "Ingresa tu nombre completo" |
| < 3 caracteres | "El nombre debe tener al menos 3 caracteres" |
| > 100 caracteres | "El nombre es demasiado largo (max. 100 caracteres)" |
| Caracteres inválidos | "Solo se permiten letras y espacios" |
| Caracteres permitidos | Letras (incluye áéíóúüñ), espacios, `.`, `'`, `-` |

**UX:** Error inline en TextField, auto-focus al campo, se limpia al escribir, textInputAction configurado.

## Auditoría de Seguridad (24 Jun 2026)

| Severidad | Hallazgo | Estado |
|-----------|----------|--------|
| ✅ | Inyección SQL: sqflite parametrizado | OK |
| ✅ | Secrets hardcodeados: ninguno | OK |
| ✅ | HTTPS en todas las conexiones | OK |
| ✅ | Controllers descartados correctamente | OK |
| ✅ | Certificados SSL no deshabilitados | OK |
| ✅ | shared_preferences eliminado | **Resuelto** |
| ✅ | Input de usuario ahora validado | **Resuelto** |
| ℹ️ | SQLite local sin cifrado | Aceptable |
| ℹ️ | Auto-update sin verificación de firma | Bajo riesgo |

## Problemas resueltos

### Archivos duplicados
Eliminados 23 archivos .dart duplicados (versiones corruptas por heredocs fuera de `lib/`).

### Errores de flutter analyze
Iconos inexistentes, fields incorrectos, imports no usados, Scaffold sin cerrar, `SingleTickerProviderStateMixin` con múltiples controllers... Todos corregidos.

### Bugs
- `life_line_result_screen.dart`: String interpolation rota (`'#\$index'` mostraba literal, `'Edad \$...'` no interpolaba)
- `arcana_detail_screen.dart`: Tag con backslash escapado (`\${arcano.numero}`)
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
    ├── splash_screen.dart     # Splash animado (fade + scale + glow)
    ├── home_screen.dart       # Grid con módulos y staggered animations
    ├── arrangements/          # Arreglos numéricos (con validación de nombre)
    ├── constellations/        # Constelaciones (con rueda animada + CustomPainter)
    ├── library/               # Biblioteca + detalle de arcanos
    ├── life_line/             # Línea de vida input + resultado (con validación)
    ├── regressions/           # Regresiones guiadas
    ├── settings/              # Configuración + auto-update
    └── tarot/                 # Menú de tiradas + lectura animada

assets/
├── cards/                     # 22 imágenes estilo Marsella (210×300px)
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
2. ✅ ~~Probar flujo de actualización~~ — Release v1.0.1 creada con APK (23.5 MB)
3. ✅ ~~Eliminar shared_preferences~~ — Resuelto
4. ✅ ~~Validación de inputs~~ — Agregada
5. ✅ ~~Cartas Rider-Waite-Smith~~ — Generadas y reemplazadas
6. ✅ ~~Animaciones en tarot_reading y constellation~~ — Completadas
7. ✅ ~~Agregar animaciones a life_line_result_screen y regression_screen~~

8. 📝 Descargar las 28 cartas menores faltantes de Wikimedia Commons
9. 📝 Compilar APK release firmada para distribucion
`flutter analyze` — 0 issues ✅
