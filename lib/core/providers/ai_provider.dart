import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../services/ai_service.dart';

class ChatConfig {
  final bool hasKey;

  const ChatConfig({required this.hasKey});
}

final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig(hasKey: AppEnvironment.hasOpenAiKey);
});

final aiServiceProvider = Provider<AIService?>((ref) {
  final apiKey = AppEnvironment.openAiApiKey;
  if (apiKey.trim().isEmpty) {
    debugPrint('⚠️ OPENAI_API_KEY no configurada');
    return null;
  }

  final service = AIService(config: AIServiceConfig(apiKey: apiKey));
  ref.onDispose(service.dispose);
  return service;
});

class ChatMessage {
  final String content;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  const ChatMessage({
    required this.content,
    required this.isUser,
    this.isError = false,
    required this.timestamp,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isProMode;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isProMode = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isProMode,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isProMode: isProMode ?? this.isProMode,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;

  ChatController(this.ref) : super(const ChatState()) {
    _initializeChat();
  }

  AIService? get _aiService => ref.read(aiServiceProvider);

  void _initializeChat() {
    state = state.copyWith(
      messages: [
        ChatMessage(
          content: '¡Hola! Soy ARI. ¿Qué querés organizar hoy?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      clearError: true,
    );
  }

  Future<void> sendMessage(String text) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty || state.isLoading) {
      return;
    }

    final userMessage = ChatMessage(
      content: cleanedText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      clearError: true,
    );

    try {
      if (!state.isProMode || _aiService == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        final fallbackReply = _basicReply(updatedMessages.length);
        _appendAssistantMessage(fallbackReply);
        return;
      }

      final history = updatedMessages
          .map(
            (m) => AIMessage(
              role: m.isUser ? 'user' : 'assistant',
              content: m.content,
              timestamp: m.timestamp,
            ),
          )
          .toList();

      final response = await _aiService!.generateResponse(
        userMessage: cleanedText,
        history: history,
      );

      if (response.isError) {
        _appendAssistantMessage(
          response.text,
          isError: true,
          error: response.errorMessage ?? 'No se pudo obtener respuesta de IA.',
        );
        return;
      }

      _appendAssistantMessage(response.text);
    } catch (e) {
      _appendAssistantMessage(
        'Lo siento, hubo un problema procesando tu mensaje.',
        isError: true,
        error: e.toString(),
      );
    }
  }

  String _basicReply(int seed) {
    final responses = [
      '¡Interesante! ¿Cómo te gustaría empezar?',
      'Dale, dividamos eso en pasos. ¿Cuál es el primero?',
      'Perfecto. ¿Querés que te cree un proyecto para organizarlo?',
      'Entendido. ¿Tenés fecha límite para esto?',
    ];
    return responses[seed % responses.length];
  }

  void _appendAssistantMessage(
    String text, {
    bool isError = false,
    String? error,
  }) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          content: text,
          isUser: false,
          isError: isError,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
      error: error,
      clearError: !isError,
    );
  }

  void toggleMode() {
    final hasKey = ref.read(chatConfigProvider).hasKey;
    if (!hasKey) {
      state = state.copyWith(
        error: 'No hay OPENAI_API_KEY configurada para activar modo Pro.',
      );
      return;
    }

    state = state.copyWith(isProMode: !state.isProMode, clearError: true);
  }

  void clearChat() {
    final wasPro = state.isProMode;
    state = ChatState(isProMode: wasPro);
    _initializeChat();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref);
});
