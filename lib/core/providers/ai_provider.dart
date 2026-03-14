import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_config.dart';
import '../services/ai_service.dart';

// Provider del servicio
final aiServiceProvider = Provider<AIService>((ref) {
  final config = ref.watch(chatConfigProvider);
  return AIService(config);
});

// Configuración del chat
final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig.fromEnvironment();
});

class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

// Alias de compatibilidad con UI existente
typedef ChatMessage = Message;

// Estado del chat
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final ChatConfig config;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    required this.config,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    ChatConfig? config,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      config: config ?? this.config,
    );
  }

  bool get isProMode => config.isProMode;
}

// Controller con StateNotifier
class ChatController extends StateNotifier<ChatState> {
  final AIService _aiService;

  ChatController(this._aiService, ChatConfig config)
      : super(ChatState(config: config));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    // Modo Básico (sin IA)
    if (!state.config.isProMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final botMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Modo básico activo. Configurá OPENAI_API_KEY para usar IA.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
      return;
    }

    // Modo Pro (con OpenAI)
    try {
      final response = await _aiService.sendMessage(text);
      final botMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    _aiService.clearHistory();
    state = state.copyWith(messages: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void toggleMode() {
    state = state.copyWith(
      error:
          'El modo está definido por OPENAI_API_KEY. Configurá esa variable para activar/desactivar Pro.',
    );
  }
}

// Provider del controller
final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final config = ref.watch(chatConfigProvider);
  return ChatController(aiService, config);
});

final chatMessagesProvider = Provider<List<Message>>(
  (ref) => ref.watch(chatControllerProvider).messages,
);

final chatIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatControllerProvider).isLoading,
);
