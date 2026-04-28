import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../models/chat_message.dart';
import '../models/chat_mode.dart';
import '../config/environment.dart';

// Estado inmutable unificado
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ChatMode mode;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.mode = ChatMode.basic,
  });

  factory ChatState.initial() {
    final initialMode = AppEnvironment.isProMode ? ChatMode.pro : ChatMode.basic;
    return ChatState(
      messages: [
        ChatMessage(
          text: "¡Hola Diego! Soy ARI. ¿Qué vamos a construir hoy?",
          isUser: false,
          timestamp: DateTime.now(),
          mode: initialMode,
        )
      ],
      mode: initialMode,
    );
  }

  // CopyWith válido y consistente
  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading, ChatMode? mode}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      mode: mode ?? this.mode,
    );
  }
}

// Inyección de dependencias
final aiProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final service = AIService(apiKey: AppEnvironment.openAIApiKey);
  return ChatController(service);
});

class ChatController extends StateNotifier<ChatState> {
  final AIService _aiService;

  ChatController(this._aiService) : super(ChatState.initial());

  // Bloque try/catch estructurado sin fugas
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now(), mode: state.mode);
    state = state.copyWith(messages: [...state.messages, userMsg], isLoading: true);

    try {
      final responseText = await _aiService.generateResponse(text);
      final aiMsg = ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now(), mode: state.mode);

      state = state.copyWith(messages: [...state.messages, aiMsg], isLoading: false);
    } catch (e) {
      final errorMsg = ChatMessage(text: "Error procesando solicitud en el orquestador.", isUser: false, timestamp: DateTime.now(), mode: state.mode);
      state = state.copyWith(messages: [...state.messages, errorMsg], isLoading: false);
    }
  }
}
