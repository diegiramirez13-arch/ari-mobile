import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_config.dart';
import '../services/ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) => AIService());

final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig.fromEnvironment();
});

class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

typedef ChatMessage = Message;

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

class ChatController extends StateNotifier<ChatState> {
  final AIService _aiService;
  final ChatConfig _config;

  ChatController(this._aiService, this._config)
      : super(
          ChatState(
            config: _config,
            messages: [
              Message(
                id: 'welcome',
                content:
                    '¡Hola! Soy ARI. ¿En qué plan de acción trabajamos hoy?',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      error: null,
    );

    if (_config.isProMode) {
      final history = updatedMessages
          .map(
            (message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'content': message.content,
            },
          )
          .toList();

      final response = await _aiService.generateResponse(history);
      final isError = response.startsWith('Error de conexión');
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        isError: isError,
      );

      state = state.copyWith(
        messages: [...updatedMessages, aiMessage],
        isLoading: false,
        error: isError ? response : null,
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 1));
    final basicResponse = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Modo básico: Recibí tu idea. ¿Querés que la desglosamos en tareas?',
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...updatedMessages, basicResponse],
      isLoading: false,
    );
  }

  void clearChat() {
    _aiService.clearHistory();
    state = ChatState(
      config: _config,
      messages: [
        Message(
          id: 'reset',
          content: 'Chat reiniciado. ¿Qué sigue en la lista?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
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
