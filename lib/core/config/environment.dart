class Environment {
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDev => env == 'dev';
  static bool get isProd => env == 'prod';
  static bool get isProMode => openAiApiKey.isNotEmpty;

  static void validate() {
    if (isProd && openAiApiKey.isEmpty) {
      throw Exception(
        'OPENAI_API_KEY es obligatoria en producción. '
        'Usa: --dart-define=OPENAI_API_KEY=sk-...',
      );
    }
  }
}

void configureEnvironment() {
  Environment.validate();
}
