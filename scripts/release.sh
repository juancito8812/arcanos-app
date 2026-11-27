#!/usr/bin/env bash
# Publica una versión nueva de PsicoTarot.
#
#   ./scripts/release.sh              # patch (2.4.1 → 2.4.2)
#   ./scripts/release.sh minor        # minor (2.4.1 → 2.5.0)
#   ./scripts/release.sh major        # major (2.4.1 → 3.0.0)
#   ./scripts/release.sh 2.6.3        # versión exacta
#
# Qué hace: bumpea pubspec.yaml, corre los tests, commitea en la rama actual,
# crea el tag vX.Y.Z y lo empuja. El workflow .github/workflows/release-automatic.yml
# compila, firma, publica la Release (app-release.apk + .sha256) y marca la
# versión como Latest. A los usuarios con la app instalada les sale el aviso
# de actualización al abrirla.
set -euo pipefail

cd "$(dirname "$0")/.."

ARG="${1:-patch}"
CURRENT=$(grep -E '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)

if [[ "$ARG" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  VERSION="$ARG"
else
  IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"
  case "$ARG" in
    major) VERSION="$((MAJOR+1)).0.0" ;;
    minor) VERSION="$MAJOR.$((MINOR+1)).0" ;;
    patch) VERSION="$MAJOR.$MINOR.$((PATCH+1))" ;;
    *) echo "❌ Uso: $0 [patch|minor|major|X.Y.Z]"; exit 1 ;;
  esac
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
BUILD=$((MAJOR*10000 + MINOR*100 + PATCH))

if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "❌ El tag v$VERSION ya existe. Elige otra versión."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Hay cambios sin commitear. Commitea primero."
  git status --short
  exit 1
fi

BRANCH=$(git branch --show-current)
echo "📦 $CURRENT  →  $VERSION (+$BUILD)   rama: $BRANCH"

sed -i -E "s/^version:.*/version: ${VERSION}+${BUILD}/" pubspec.yaml

echo "🧪 Tests…"
export PATH="$HOME/development/flutter-3.29.2/bin:$PATH"
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy -u all_proxy \
  flutter test --reporter compact 2>&1 | tail -3

git add pubspec.yaml
git commit -q -m "chore: bump version a $VERSION+$BUILD"
git tag -a "v$VERSION" -m "v$VERSION"
git push origin "$BRANCH"
git push origin "v$VERSION"

echo "✅ Tag v$VERSION empujado. El CI compila y publica la Release:"
echo "   https://github.com/juancito8812/arcanos-app/actions"
echo "   Los usuarios verán el aviso al abrir la app (API: /releases/latest)."
