#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="ari-mobile-bf746"

if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ Flutter no está instalado o no está en PATH."
  echo "   Instalá Flutter y volvé a ejecutar este script."
  exit 1
fi

if ! command -v flutterfire >/dev/null 2>&1; then
  echo "⚠️ FlutterFire CLI no está en PATH. Intentando instalar..."
  if command -v dart >/dev/null 2>&1; then
    dart pub global activate flutterfire_cli
    export PATH="$PATH:$HOME/.pub-cache/bin"
  else
    echo "❌ Dart no está disponible para instalar flutterfire_cli automáticamente."
    exit 1
  fi
fi

echo "🧹 flutter clean"
flutter clean

echo "📦 flutter pub get"
flutter pub get

echo "🔥 flutterfire configure --project=${PROJECT_ID}"
flutterfire configure --project="${PROJECT_ID}"

if [[ ! -f .env ]]; then
  echo "⚠️ No existe .env. Copiando plantilla desde .env.example"
  cp .env.example .env
  echo "   Editá .env y agregá tu OPENAI_API_KEY real antes de correr en modo Pro."
fi

OPENAI_KEY=""
if [[ -f .env ]]; then
  OPENAI_KEY=$(grep '^OPENAI_API_KEY=' .env | head -n1 | cut -d'=' -f2- || true)
fi

if [[ -n "${OPENAI_KEY}" && "${OPENAI_KEY}" != "sk-tu_clave_real_aqui" ]]; then
  echo "🚀 flutter run con OPENAI_API_KEY desde .env"
  flutter run --dart-define=OPENAI_API_KEY="${OPENAI_KEY}"
else
  echo "🚀 flutter run (sin OPENAI_API_KEY válida; chat seguirá en modo básico)"
  flutter run
fi
