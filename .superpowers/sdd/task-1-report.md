# Task 1 Report: Refactor AppTheme a generador por paleta

**Status:** ✅ Completo

**Commit:** `a654e5a` — "refactor: AppTheme como generador de paletas"

**Resumen:**
- `lib/theme.dart` reescrito de definiciones estáticas a generador dinámico `themeFor(String palette, ThemeMode mode) → ThemeData`
- Se agregaron 5 paletas: purple, blue, green, red, amber con colores seed, fondos light y dark
- Constantes de color existentes (`purplePrimary`, `goldAccent`, etc.) preservadas
- `lightTheme` y `darkTheme` ahora invocan `themeFor('purple', ...)` manteniendo compatibilidad

**Verificación:** `flutter analyze` — No issues found (0 errores, 0 warnings, 0 info)

**Preocupaciones:** Ninguna. Refactor mecánico sin cambios en interfaz pública.
