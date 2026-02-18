#!/bin/bash
set -e

echo "🚀 Instalando ARI Pro completo..."

# 1. Estructura
mkdir -p lib/core/config lib/core/services lib/core/providers lib/features/chat test/core/services test/core/providers test/features/chat

# 2. Dependencias
flutter pub add openai_dart

# 3. Crear archivos (copiar todo el código de arriba)
# - lib/core/config/environment.dart
# - lib/core/services/ai_service.dart
# - lib/core/providers/ai_provider.dart
# - lib/features/chat/chat_screen.dart
# - test/core/services/ai_service_test.dart
# - test/core/providers/ai_provider_test.dart
# - test/features/chat/chat_provider_test.dart
# - verify.sh
# - .github/workflows/flutter_ci.yml

# 4. Borrar archivos obsoletos
rm -f lib/features/chat/chat_provider.dart
rm -f lib/features/chat/chat_logic.dart
rm -f lib/features/chat/message.dart

# 5. Verificar
flutter pub get
flutter analyze

echo "✅ Completo. Ejecutá: flutter test"
