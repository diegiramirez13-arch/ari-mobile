import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static Future<void> setup() async {
    await dotenv.load(fileName: '.env', isOptional: true);
    validate();
  }

  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static bool get isProMode => openAIApiKey.isNotEmpty;

  static String get currentEnv => dotenv.env['ENV'] ?? 'dev';
  static bool get isDev => currentEnv == 'dev';
  static bool get isProd => currentEnv == 'prod';

  static void validate() {
    if (isProd && openAIApiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY required in production');
    }

    if (isDev) {
      debugPrint('🔧 Environment: $currentEnv | Pro mode: $isProMode');
    }
  }
}
