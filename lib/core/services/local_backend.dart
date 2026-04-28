import '../models/ai_response.dart';
import '../models/ai_service_config.dart';
import 'ai_backend.dart';

class LocalBackend implements AIBackend {
  @override
  String get name => 'Local (Demo)';

  @override
  bool get isAvailable => true;

  final Map<String, String> _respuestas = {
    'hola':
        '¡Hola! Soy ARI, tu asistente de productividad. ¿En qué puedo ayudarte hoy? 🇦🇷',
    'adios': '¡Hasta luego! Recordá: Acción > Charla. 💪',
    'tarea': '📋 Para organizar tareas:\n1. Escribí el objetivo\n2. Dividí en pasos chicos\n3. Empezá por el más fácil',
    'proyecto':
        '🚀 Plan de proyecto:\n• Definí el MVP (mínimo viable)\n• Establecé deadlines reales\n• Revisá cada 3 días',
    'ayuda':
        'Comandos disponibles:\n• "hola" - Saludo\n• "tarea" - Ayuda con tareas\n• "proyecto" - Planificación\n• "adios" - Despedida',
  };

  @override
  Future<AIResponse> sendMessage(String prompt, AIServiceConfig config) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final clave = prompt.toLowerCase().trim();
    final respuesta = _respuestas[clave] ??
        'Entendido: "$prompt".\n\nSoy ARI en modo local. Para respuestas con IA, conectá una API key en configuración.\n\n💡 Tip: Probá "ayuda" para ver comandos.';

    return AIResponse.success(respuesta);
  }

  @override
  void dispose() {}
}
