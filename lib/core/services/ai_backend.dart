import '../models/ai_response.dart';
import '../models/ai_service_config.dart';

abstract class AIBackend {
  String get name;
  bool get isAvailable;
  Future<String> generateResponse(String prompt);
  Future<AIResponse> sendMessage(String prompt, AIServiceConfig config);
  void dispose();
}
