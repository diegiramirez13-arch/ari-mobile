import 'package:flutter/foundation.dart';

class Environment {
  // API Keys - Inyectadas en tiempo de compilación
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

  // Feature Flags
  static bool get isProMode => openAiApiKey.isNotEmpty;

  // Entorno
  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static bool get isDev => env == 'dev';
  static bool get isProd => env == 'prod';

  // Validación
  static void validate() {
    if (isProd && openAiApiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY requerida en producción');
    }

    if (isDev) {
      debugPrint('🔧 Environment: $env | Pro mode: $isProMode');
    }
  }
}

void configureEnvironment() {
  Environment.validate();
}
