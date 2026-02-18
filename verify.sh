#!/bin/bash
set -e

echo "🔍 Verificando ARI..."

echo "📦 Pub get..."
flutter pub get

echo "🔬 Analyze..."
flutter analyze --fatal-infos

echo "🧪 Tests..."
flutter test

echo "🔨 Build debug..."
flutter build web --debug

echo "✅ Todo OK"
