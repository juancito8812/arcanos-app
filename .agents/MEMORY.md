# Memoria del Proyecto: PsicoTarot (arcanos-app)

## Información General

- **Propósito:** App Flutter de PsicoTarot basada en los 78 Arcanos del Tarot de Marseille unificados. Ofrece análisis numerológicos, líneas de vida, tiradas interactivas, constelaciones familiares, matriz del destino, carta diaria y regresiones.
- **Stack:** Flutter 3.27+, Dart 3.7+, SQLite (sqflite), SharedPreferences, flutter_secure_storage
- **Deploy:** APK firmado; las releases se crean a mano con `gh release create` (el CI no las crea)
- **Última sesión:** 2026-10-12
- **Versión de memoria:** 2.0

## Arquitectura

- `lib/` — Código Dart de la app (screens, services, models)
- `assets/cards/` — 78 cartas unificadas del Tarot de Marseille (`arcano_{0..77}.jpg`)
- `android/` — Configuración Android (keystore, network security)
- `test/` — Tests unitarios
- `.github/workflows/build-apk.yml` — CI: `flutter pub get` → `flutter analyze` → `flutter build apk --debug` → sube artifact

## Características Principales

- **Biblioteca de Arcanos** — 22 Mayores + 56 Menores con significado completo
- **Línea de Vida** — 5 arcanos personales (YO, ELLO, MENTE, REALIZACIÓN, SÍNTESIS)
- **Tiradas** — 5 tipos: 3 Cartas, Tríada Vida Pasada, Viaje Vidas Pasadas, Constelación Familiar, Árbol Genealógico
- **Arreglos Numéricos** — 8 análisis numerológicos
- **Matriz del Destino** — 8 posiciones numerológicas
- **Constelaciones Familiares** — 3 principios, rueda de 7 arcanos, genograma, patrones transgeneracionales, frases sanadoras
- **5 Paletas de Color** — Azul, Rosa, Verde, Naranja, Violeta

## Seguridad

- Release firmado con keystore personal (`upload-keystore.jks`)
- API key en `flutter_secure_storage` (Android Keystore)
- `network_security_config.xml` — solo CAs del sistema
- `allowBackup=false`
- R8 con minify + shrink resources

## Estado Actual

- **Branch:** `master` (sincronizada con `origin/master`)
- **HEAD:** `ff599ae` — checkpoint: bump version 2.3.0
- **Versión:** 2.3.0+8
- **Última release:** `v2.3.0` (APK firmado 48.7 MB)
- **Repositorio:** https://github.com/juancito8812/arcanos-app

## Próximos Pasos

- [ ] Arreglar el CI (`flutter analyze` falla el build)
- [ ] Firma APK para Google Play
- [ ] Agregar más tipos de tiradas
- [ ] Internacionalización (i18n)
