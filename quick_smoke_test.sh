#!/bin/bash
# quick_smoke_test.sh

set -e

cd app

echo "🚀 Build modo BÁSICO (sin key)..."
flutter run --dart-define=ENV=dev --observatory-port=0 &
PID=$!
sleep 15
kill $PID 2>/dev/null || true

echo "🚀 Build modo PRO (con key fake para compilar)..."
flutter build apk --release \
  --dart-define=OPENAI_API_KEY=sk-test123 \
  --dart-define=ENV=prod

echo "✅ Builds exitosos - revisar UI manualmente"
