import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ChatConfig {
  final bool isProMode;

  ChatConfig({required this.isProMode});
}

final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig(isProMode: AppEnvironment.isProMode);
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(apiKey: AppEnvironment.openAIApiKey);
});

typedef Message = ChatMessage;

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isProMode;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.isProMode = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isProMode,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isProMode: isProMode ?? this.isProMode,
    );
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final config = ref.watch(chatConfigProvider);
  final service = ref.watch(aiServiceProvider);
  return ChatController(service, config.isProMode);
});

final aiProvider = chatControllerProvider;

class ChatController extends StateNotifier<ChatState> {
  final AIService _aiService;

  ChatController(this._aiService, bool isPro)
      : super(
          ChatState(
            messages: [
              ChatMessage(
                content: '¡Hola Diego! Soy ARI. ¿Qué vamos a construir hoy?',
                isUser: false,
              ),
            ],
            isProMode: isPro,
          ),
        );

  Future<void> sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    final userMsg = ChatMessage(content: input, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final responseText = await _aiService.generateResponse(input);
      final aiMsg = ChatMessage(content: responseText, isUser: false);

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
    } catch (_) {
      final errorMsg = ChatMessage(
        content: 'Error procesando solicitud en la IA Híbrida.',
        isUser: false,
        isError: true,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = state.copyWith(
      messages: [
        ChatMessage(
          content: 'Chat reiniciado. ¿En qué te ayudo, Capitán?',
          isUser: false,
        ),
      ],
      isLoading: false,
    );
  }
}
