import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/cloud_secrets.dart';
import '../config/environment.dart';
import '../models/chat_message.dart';
import '../models/chat_mode.dart';
import '../services/hybrid_ai_orchestrator.dart';

final openAIApiKeyProvider = Provider<String>((ref) => AppEnvironment.openAIApiKey);

class ChatConfig {
  final bool isProMode;

  ChatConfig({required this.isProMode});
}

final chatConfigProvider = Provider<ChatConfig>((ref) {
  final hasOpenAIKey = ref.watch(openAIApiKeyProvider).isNotEmpty;
  return ChatConfig(isProMode: hasOpenAIKey || CloudSecrets.hasConfiguredBackendUrl);
});

final hybridAIOrchestratorProvider = Provider<HybridAIOrchestrator>((ref) {
  final orchestrator = HybridAIOrchestrator(
    preferCloudRun: CloudSecrets.hasConfiguredBackendUrl,
  )..initialize();
  ref.onDispose(orchestrator.dispose);
  return orchestrator;
});

typedef Message = ChatMessage;

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ChatMode mode;
  final String? error;

  const ChatState({
    this.messages = const <ChatMessage>[],
    this.isLoading = false,
    this.mode = ChatMode.basic,
    this.error,
  });

  bool get isProMode => mode == ChatMode.pro || mode == ChatMode.enterprise;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    ChatMode? mode,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      mode: mode ?? this.mode,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final config = ref.watch(chatConfigProvider);
  final openAIKey = ref.watch(openAIApiKeyProvider);
  final orchestrator = ref.watch(hybridAIOrchestratorProvider);
  return ChatController(
    orchestrator: orchestrator,
    hasProAccess: config.isProMode,
    hasOpenAIKey: openAIKey.isNotEmpty,
  );
});

final aiProvider = chatControllerProvider;

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required HybridAIOrchestrator orchestrator,
    required bool hasProAccess,
    required bool hasOpenAIKey,
  })  : _orchestrator = orchestrator,
        _hasOpenAIKey = hasOpenAIKey,
        super(
          ChatState(
            messages: [
              ChatMessage(
                content: '¡Hola Diego! Soy ARI. ¿Qué vamos a construir hoy?',
                isUser: false,
              ),
            ],
            mode: hasProAccess ? ChatMode.pro : ChatMode.basic,
          ),
        );

  final HybridAIOrchestrator _orchestrator;
  final bool _hasOpenAIKey;

  Future<void> sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    final userMsg = ChatMessage(content: input, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    try {
      final response = await _orchestrator.getResponse(input);
      final aiMsg = ChatMessage(
        content: response.text,
        isUser: false,
        isError: response.isError,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        error: response.isError ? response.errorCode : null,
        clearError: !response.isError,
      );
    } catch (_) {
      const fallbackError = 'Error procesando solicitud en la IA Híbrida.';
      final errorMsg = ChatMessage(
        content: fallbackError,
        isUser: false,
        isError: true,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: fallbackError,
      );
    }
  }

  void toggleMode() {
    if (state.mode == ChatMode.basic && !_hasOpenAIKey) {
      state = state.copyWith(
        error: 'Configurá OPENAI_API_KEY para activar modo Pro local.',
      );
      return;
    }

    final nextMode = state.mode == ChatMode.basic ? ChatMode.pro : ChatMode.basic;
    final modeMsg = ChatMessage(
      content: 'Modo cambiado a ${nextMode == ChatMode.pro ? 'PRO' : 'BÁSICO'}.',
      isUser: false,
    );

    state = state.copyWith(
      mode: nextMode,
      messages: [...state.messages, modeMsg],
      clearError: true,
    );
  }

  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          content: 'Chat reiniciado. ¿En qué te ayudo, Capitán?',
          isUser: false,
        ),
      ],
      mode: state.mode,
    );
  }
}
