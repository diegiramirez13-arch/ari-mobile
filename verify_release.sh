#!/bin/bash
# verify_release.sh

set -e

echo "🔍 Analyzing..."
flutter analyze --fatal-infos

echo "🧪 Testing..."
flutter test

echo "📦 Building APK (smoke test)..."
flutter build apk --release \
  --dart-define=OPENAI_API_KEY=test_key \
  --dart-define=ENV=prod

echo "✅ Listo para release"
