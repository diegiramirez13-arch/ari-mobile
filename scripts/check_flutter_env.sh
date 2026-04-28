#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "🔎 ARI | Diagnóstico rápido de Flutter"

add_to_path_if_exists() {
  local candidate="$1"
  if [[ -x "$candidate/flutter" ]]; then
    case ":$PATH:" in
      *":$candidate:"*) ;;
      *) export PATH="$candidate:$PATH" ;;
    esac
    return 0
  fi
  return 1
}

FOUND=0

# 1) Si ya está en PATH, perfecto.
if command -v flutter >/dev/null 2>&1; then
  FOUND=1
fi

# 2) Rutas comunes Linux/macOS
if [[ $FOUND -eq 0 ]]; then
  for p in \
    "$HOME/flutter/bin" \
    "$HOME/development/flutter/bin" \
    "$HOME/dev/flutter/bin" \
    "$ROOT_DIR/flutter/bin" \
    "/opt/flutter/bin" \
    "/usr/local/flutter/bin"
  do
    if add_to_path_if_exists "$p"; then
      FOUND=1
      break
    fi
  done
fi

if [[ $FOUND -eq 0 ]]; then
  echo "❌ No se encontró Flutter en PATH ni en rutas comunes."
  echo "👉 Si lo instalaste hace 10 días, no hace falta descargarlo de nuevo:"
  echo "   1) ubicá la carpeta (ej: /home/tu_usuario/flutter o C:\\src\\flutter)"
  echo "   2) agregá <ruta>/bin al PATH"
  echo "   3) re-ejecutá este script"
  exit 1
fi

echo "✅ Flutter encontrado: $(command -v flutter)"
flutter --version

printf '\n🩺 flutter doctor -v\n'
flutter doctor -v || true

printf '\n📦 flutter pub get\n'
flutter pub get

if command -v flutterfire >/dev/null 2>&1; then
  printf '\n🔥 flutterfire configure --project=ari-mobile-bf746\n'
  flutterfire configure --project=ari-mobile-bf746
else
  printf '\n⚠️ flutterfire no está en PATH.\n'
  echo "   Instalalo con: dart pub global activate flutterfire_cli"
  echo "   y asegurá PATH: export PATH=\"$PATH:$HOME/.pub-cache/bin\""
fi

if [[ ! -f .env ]]; then
  if [[ -f .env.example ]]; then
    cp .env.example .env
    printf '\n📝 Se creó .env desde .env.example\n'
    echo "   Editalo y poné OPENAI_API_KEY real para habilitar modo Pro."
  else
    printf '\n⚠️ No existe .env ni .env.example\n'
  fi
else
  printf '\n✅ .env ya existe\n'
fi

printf '\n🚀 Para correr ARI:\n'
echo "flutter run"
