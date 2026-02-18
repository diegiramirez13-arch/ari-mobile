import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_service.dart';

const _apiKey = String.fromEnvironment('OPENAI_API_KEY');

final aiServiceProvider = Provider<AIService?>((ref) {
  if (_apiKey.isEmpty) {
    debugPrint('⚠️ OPENAI_API_KEY no configurada');
    return null;
  }
  return AIService(config: const AIServiceConfig(apiKey: _apiKey));
});

class ChatState {
  final List<AIMessage> messages;
  final bool isLoading;
  final bool isProMode;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isProMode = false,
  });

  ChatState copyWith({
    List<AIMessage>? messages,
    bool? isLoading,
    bool? isProMode,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isProMode: isProMode ?? this.isProMode,
      );
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;
  ChatController(this.ref) : super(ChatState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(messages: [
      AIMessage(
        role: 'assistant',
        content: '¡Hola! Soy ARI. ¿Qué querés organizar hoy?',
      )
    ]);
  }

  AIService? get _ai => ref.read(aiServiceProvider);

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AIMessage(role: 'user', content: text.trim());
    state = state.copyWith(messages: [...state.messages, userMsg], isLoading: true);

    if (!state.isProMode || _ai == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      final responses = [
        '¡Interesante! ¿Cómo te gustaría empezar?',
        'Dale, dividamos eso en pasos. ¿Cuál es el primero?',
        'Perfecto. ¿Querés que te cree un proyecto para organizarlo?',
        'Entendido. ¿Tenés fecha límite para esto?',
      ];
      final reply = responses[state.messages.length % responses.length];
      state = state.copyWith(
        messages: [...state.messages, AIMessage(role: 'assistant', content: reply)],
        isLoading: false,
      );
      return;
    }

    final response = await _ai!.generateResponse(
      userMessage: text,
      history: state.messages,
    );

    state = state.copyWith(
      messages: [...state.messages, AIMessage(role: 'assistant', content: response.text)],
      isLoading: false,
    );
  }

  void togglePro() => state = state.copyWith(isProMode: !state.isProMode);
  void clear() => _init();
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(ref),
);

final hasAIProvider = Provider<bool>((ref) => ref.watch(aiServiceProvider) != null);
