import '../config/environment.dart';

class ChatConfig {
  final String model;
  final double temperature;
  final int maxTokens;
  final bool isProMode;

  const ChatConfig({
    this.model = 'gpt-4o-mini',
    this.temperature = 0.7,
    this.maxTokens = 1000,
    required this.isProMode,
  });

  factory ChatConfig.fromEnvironment() {
    return ChatConfig(
      isProMode: Environment.isProMode,
      // Opcional: leer otros valores de environment si los agregás
    );
  }

  bool get hasKey => isProMode;
  bool get enableAI => isProMode;
}
