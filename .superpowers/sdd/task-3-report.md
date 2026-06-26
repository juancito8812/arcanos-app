# Task 3: Selector de paleta en Settings

**Status:** ✅ Complete

## Done
- Reemplazado `_buildThemeSelector()` en `lib/screens/settings/settings_screen.dart`
- Agregado selector visual de 5 círculos de color con animación via `AnimatedContainer`
- Cada círculo usa el color semilla de `AppTheme.paletteSeeds`, borde dorado si seleccionado + icono check
- Llamada a `themeProvider.setPalette(p)` al tocar un círculo
- Commit: `927c855` — `feat: selector de paleta de color en Ajustes`

## Note
`flutter analyze` no pudo ejecutarse porque Flutter SDK no está disponible en PATH ni instalado localmente. El código sigue exactamente el brief y las interfaces existentes (`ThemeProvider`, `AppTheme`) de las Tasks 1-2.
