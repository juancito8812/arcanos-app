# Handoff — PsicoTarot App

## Estado Actual
- Versión: `2.3.0+8` (pubspec.yaml)
- Rama: `master`, sincronizada con `origin/master`
- HEAD: `ff599ae` — checkpoint: bump version 2.3.0
- Última release: `v2.3.0` (GitHub Releases, APK firmado 48.7 MB)
- Tags: `v1.0.1`, `v1.1.0-test`, `v1.1.1-test`, `v2.0.0`, `v2.1.0`, `v2.2.0`, `v2.2.1`, `v2.2.2`, `v2.3.0`
- Build: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- Análisis: `flutter analyze` — estricto por defecto (infos y warnings son fatales); debe quedar en cero issues

## Últimos Cambios (commiteados)
- `ff599ae` — bump version 2.3.0
- `07692ef` — fixes code review: personalizar(), nested Scaffold, validación de inputs, IA persistida, Guardar→Recargar
- `dd9c474` — constelaciones v2: genograma, rueda sistémica, frases por capas, patrones transgeneracionales, IA, persistencia en BD

## Funcionalidades Completadas
1. Línea de Vida con tabla pitagórica estándar (A=1..Z=8, Ñ=5), 22→0 El Loco
2. 5 paletas de color (Azul, Rosa, Verde, Naranja, Violeta) + acento dorado fijo #FFD700
3. Selector de paleta en Ajustes con animación
4. Actualización en app desde GitHub Releases (auto-check, banner, diálogo con progreso)
5. Seguridad: release firmado (upload-keystore.jks), API key cifrada (flutter_secure_storage), network security config, R8 minify, backup desactivado
6. Constelaciones familiares v2: 6 tabs (Qué es?, 3 Leyes, Genograma, Rueda, Frases, Patrones) con IA y persistencia en BD
7. Fix APK install: MethodChannel propio corrige sobrescritura de flags en open_filex

## Base de Datos (6 tablas en DatabaseService)
`perfiles`, `tiradas`, `regresiones`, `daily_cards`, `constellation_members`, `constellation_sessions`

## Issues Conocidos
- CI (`build-apk.yml`) en rojo: falla en el paso `flutter analyze`
- El workflow solo compila APK `--debug` y sube artifact: **no firma ni crea releases** (las releases se crean a mano con `gh release create`)
- `lib/screens/constellations/tabs/tab_interpretacion.dart` y `tab_sesiones.dart` NO existen (los reemplazó `tab_patrones.dart`)
- Sin tests unitarios, sin soporte iOS, sin i18n

## Para Próxima Sesión
1. Arreglar el CI (`flutter analyze`) y decidir si pinear la versión de Flutter en el workflow
2. Internacionalización (i18n)
3. Tests unitarios
4. Hacer interactiva la rueda de constelaciones (arrastrar miembros)

## Comandos Útiles
```bash
flutter analyze
flutter build apk --release
git add -A && git commit -m "checkpoint: descripción"
git push origin master
gh release create vX.X.X "build/app/outputs/flutter-apk/app-release.apk#app-release.apk" --title "vX.X.X" --notes "## vX.X.X%0A%0A### Descripción" --repo juancito8812/arcanos-app
```
