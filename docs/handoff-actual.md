# Handoff — PsicoTarot App

## Estado Actual
- Versión: 2.2.1+6
- Rama: `master` en `960d641`
- Tags: `v2.2.0`, `v2.2.1`
- Build: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- Análisis: `flutter analyze` — Sin errores
- APK: 46.1MB, release firmado, R8 ofuscado

## Últimos Cambios (no commiteados)
- docs/revision-codigo-2026-06-26.md — Code review full
- docs/revision-constelaciones-2026-06-26.txt — Review específico de constelaciones

## Funcionalidades Completadas
1. Línea de Vida con tabla pitagórica estándar (A=1..Z=8, Ñ=5)
2. 5 paletas de color (Azul, Rosa, Verde, Naranja, Violeta) + acento dorado fijo
3. Selector de paleta en Ajustes con animación
4. Actualización en app desde GitHub Releases (auto-check, banner, diálogo con progreso)
5. Seguridad: release firmado, API key cifrada, network config, R8, backup desactivado
6. Constelaciones familiares con rueda animada de 7 arcanos

## Para Próxima Sesión
Posibles mejoras:
1. Integrar IA en interpretación de constelaciones
2. Hacer interactiva la rueda de constelaciones (arrastrar miembros)
3. Persistencia de constelaciones en BD
4. Agregar tabla de constelaciones a DatabaseService
5. Internacionalización (i18n)
6. Widgets binding observer recarga (preexistente info)

## Comandos Útiles
```bash
flutter analyze
flutter build apk --release
flutter test
git add -A && git commit -m "checkpoint: descripción"
git push origin master
```
