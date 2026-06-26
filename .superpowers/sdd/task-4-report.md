# Task 4 Report: Conectar paleta en MaterialApp

## Cambios realizados

- **Archivo:** `lib/app.dart`
- Se reemplazó `AppTheme.lightTheme` / `AppTheme.darkTheme` por `AppTheme.themeFor(themeProvider.palette, ThemeMode.light)` / `AppTheme.themeFor(themeProvider.palette, ThemeMode.dark)`
- Se mantiene `themeMode: themeProvider.mode` sin cambios

## Verificación

- `flutter analyze` — No issues found
- `git commit` — `90ac5b5` feat: paleta conectada en MaterialApp

## Resultado

Paleta dinámica conectada correctamente en MaterialApp usando `ThemeProvider.palette` y `AppTheme.themeFor()`.
