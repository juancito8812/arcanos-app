# Handoff — PsicoTarot App

## Estado Actual
- Versión: 2.2.2+7
- Rama: `master` en `d9a4d1d`
- Tags: `v2.2.0`, `v2.2.1`, `v2.2.2`
- Build: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- Análisis: `flutter analyze` — Sin errores
- APK: 46.1MB, release firmado, R8 ofuscado

## Últimos Cambios (commiteados)
- Fix APK install v2.2.2: MethodChannel propio en MainActivity.kt corrige sobrescritura de FLAG_GRANT_READ_URI_PERMISSION por open_filex
- docs/revision-codigo-2026-06-26.md — Code review full
- docs/revision-constelaciones-2026-06-26.txt — Review específico de constelaciones

## Funcionalidades Completadas
1. Línea de Vida con tabla pitagórica estándar (A=1..Z=8, Ñ=5), 22→0 El Loco
2. 5 paletas de color (Azul, Rosa, Verde, Naranja, Violeta) + acento dorado fijo #FFD700
3. Selector de paleta en Ajustes con animación
4. Actualización en app desde GitHub Releases (auto-check, banner, diálogo con progreso)
5. Seguridad: release firmado (upload-keystore.jks), API key cifrada (flutter_secure_storage), network security config, R8 minify, backup desactivado
6. Constelaciones familiares con rueda animada de 7 arcanos
7. Fix APK install: MethodChannel propio corrige sobrescritura de flags en open_filex

## Issues Conocidos
- WidgetsBindingObserver en DestinyMatrixScreen (info preexistente: use_build_context_synchronously)
- FamilyMember model definido pero sin uso (dead code)
- No hay integración de IA con constelaciones
- Constelaciones sin persistencia en BD

## Para Próxima Sesión
Posibles mejoras:
1. Integrar IA en interpretación de constelaciones
2. Hacer interactiva la rueda de constelaciones (arrastrar miembros)
3. Persistencia de constelaciones en BD
4. Agregar tabla de constelaciones a DatabaseService
5. Internacionalización (i18n)

## Comandos Útiles
```bash
flutter analyze
flutter build apk --release
git add -A && git commit -m "checkpoint: descripción"
git push origin master
gh release create vX.X.X "build/app/outputs/flutter-apk/app-release.apk#app-release.apk" --title "vX.X.X" --notes "## vX.X.X%0A%0A### Descripción" --repo juancito8812/arcanos-app
```
