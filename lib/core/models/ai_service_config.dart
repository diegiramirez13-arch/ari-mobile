import 'chat_mode.dart';

class AIServiceConfig {
  final String? apiKey;
  final ChatMode mode;
  final String? modelName;
  final double temperature;
  final int maxTokens;

  const AIServiceConfig({
    this.apiKey,
    this.mode = ChatMode.basic,
    this.modelName,
    this.temperature = 0.7,
    this.maxTokens = 150,
  });

  bool get isPro => mode == ChatMode.pro || mode == ChatMode.enterprise;
  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;
}
