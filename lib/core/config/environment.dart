enum Environment { dev, qa, prod }

class AppEnvironment {
  static Environment _current = Environment.dev;

  static Environment get current => _current;

  static void setEnvironment(Environment env) {
    _current = env;
  }

  // API Keys por fuente
  static String get openAIApiKey {
    // 1. Intentar desde --dart-define (producción)
    const fromDefine = String.fromEnvironment('OPENAI_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;

    // 2. Fallback para desarrollo (NO usar en prod)
    if (_current == Environment.dev) {
      // Opcional: leer de archivo local .env.dev
      // return dotenv.env['OPENAI_API_KEY'] ?? '';
    }

    return '';
  }

  static bool get hasOpenAIKey => openAIApiKey.isNotEmpty;

  // Feature flags
  static bool get enableAI => hasOpenAIKey;
  static bool get enableAnalytics => _current == Environment.prod;
  static bool get enableDebugLogs => _current == Environment.dev;
}

// Helper para inicializar desde main
void configureEnvironment() {
  // Detectar por variables de entorno del sistema o compilar-mode
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  switch (env) {
    case 'prod':
      AppEnvironment.setEnvironment(Environment.prod);
      break;
    case 'qa':
      AppEnvironment.setEnvironment(Environment.qa);
      break;
    default:
      AppEnvironment.setEnvironment(Environment.dev);
  }
}
