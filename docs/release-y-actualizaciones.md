# Release y actualizaciones automáticas

## Publicar una versión nueva

```bash
./scripts/release.sh          # patch: 2.4.1 → 2.4.2
./scripts/release.sh minor    # 2.5.0
./scripts/release.sh 2.6.3    # versión exacta
```

El script bumpea `pubspec.yaml`, corre los tests localmente, commitea en la rama
actual y empuja el tag `vX.Y.Z`. El resto lo hace GitHub Actions
(`.github/workflows/release-automatic.yml`):

1. Flutter 3.29.2 + Java 17
2. `flutter pub get` → `analyze --no-fatal-infos` → `flutter test`
3. `flutter build apk --release` con el keystore de distribución
4. **Verifica la firma** contra `ANDROID_CERT_SHA256` y aborta si no coincide
5. Publica la GitHub Release con `app-release.apk` + `app-release.apk.sha256`,
   marcada como **Latest**

También se puede lanzar a mano desde la pestaña Actions (`workflow_dispatch`)
indicando versión o tipo de bump.

## Aviso en la app instalada

`lib/services/update_service.dart` consulta al abrir la app:

```
GET api.github.com/repos/juancito8812/arcanos-app/releases/latest
```

- Compara `tag_name` con `PackageInfo.version`.
- Si es más nueva: diálogo "Nueva versión X" con `Más tarde` / `Actualizar ahora`,
  como máximo una vez cada 24 h, más banner permanente en Inicio y un botón de
  verificación manual en Ajustes.
- Descarga el APK, comprueba el SHA-256 contra `app-release.apk.sha256` y abre el
  instalador del sistema (`_minApkBytes` = 5 MB como freno a descargas truncadas).

## Firma (crítico)

Keystore de distribución = el mismo de los builds locales del homelab:
`~/.android/debug.keystore`, alias `androiddebugkey`. Respaldo:
`~/.hermes/secrets/arcanos/upload-keystore.jks`.

Certificado SHA-256: `7c5a29c2b732d36de9b568c3cd56bc260aef1fe7182b0ddca18e3808b5b8023c`

Si la firma cambia, Android rechaza la instalación encima y los usuarios se
quedan sin poder actualizar. Por eso el CI aborta el release cuando no coincide.

Secretos del repo: `ANDROID_KEYSTORE_BASE64`, `ARCA_STORE_PASSWORD`,
`ARCA_KEY_PASSWORD`, `ARCA_KEY_ALIAS`.

## versionCode

`X.Y.Z` → `versionCode = X*10000 + Y*100 + Z` (2.4.1 → 20401). Monótono, lo
calcula el workflow; no se toca a mano.

## Manual (solo si el CI no está disponible)

```bash
flutter build apk --release
gh release create vX.Y.Z build/app/outputs/flutter-apk/app-release.apk \
  --title "vX.Y.Z" --notes "cambios" --repo juancito8812/arcanos-app --latest
```
