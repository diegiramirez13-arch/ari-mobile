import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/environment.dart';
import '../models/chat_message.dart';
import '../models/hybrid_response.dart';
import '../services/ai_service.dart';
import '../services/hybrid_orchestrator.dart';
import '../services/backend_ai_service.dart';
import '../services/logger_service.dart';

class ChatConfig {
  final bool isProMode;
  final String backendUrl;

  ChatConfig({required this.isProMode, required this.backendUrl});
}

final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig(
    isProMode: AppEnvironment.isProMode,
    backendUrl: AppEnvironment.backendUrl,
  );
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(apiKey: AppEnvironment.openAIApiKey);
});

final hybridOrchestratorProvider = Provider<HybridOrchestrator>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return HybridOrchestrator(openaiService: aiService);
});

final backendAIServiceProvider = Provider<BackendAIService>((ref) {
  final config = ref.watch(chatConfigProvider);
  // TODO: Inject Firebase auth token when available
  return BackendAIService(backendUrl: config.backendUrl);
});

typedef Message = ChatMessage;

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isProMode;
  final String? activeProvider; // Metadata: which provider responded last

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.isProMode = false,
    this.activeProvider,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isProMode,
    String? activeProvider,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isProMode: isProMode ?? this.isProMode,
      activeProvider: activeProvider ?? this.activeProvider,
    );
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final config = ref.watch(chatConfigProvider);
  final hybridOrchestrator = ref.watch(hybridOrchestratorProvider);
  final backendService = ref.watch(backendAIServiceProvider);
  return ChatController(
    orchestrator: hybridOrchestrator,
    backendService: backendService,
    isProMode: config.isProMode,
  );
});

final aiProvider = chatControllerProvider;

class ChatController extends StateNotifier<ChatState> {
  final HybridOrchestrator _hybridOrchestrator;
  final BackendAIService _backendService;

  ChatController({
    required HybridOrchestrator orchestrator,
    required BackendAIService backendService,
    required bool isProMode,
  })
      : _hybridOrchestrator = orchestrator,
        _backendService = backendService,
        super(
          ChatState(
            messages: [
              ChatMessage(
                content: '¡Hola Diego! Soy ARI. ¿Qué vamos a construir hoy?',
                isUser: false,
              ),
            ],
            isProMode: isProMode,
          ),
        );

  Future<void> sendMessage(String input, {String? userId}) async {
    if (input.trim().isEmpty) return;

    final userMsg = ChatMessage(content: input, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      // Try backend first, fallback to local orchestrator
      late HybridResponse response;
      
      LoggerService.info('📡 Attempting backend connection...');
      response = await _backendService.sendChatMessage(input, userId: userId);
      
      // If backend failed, try local orchestrator
      if (response.isError && response.metadata.provider == 'backend') {
        LoggerService.info('🔄 Backend failed, falling back to local orchestrator...');
        response = await _hybridOrchestrator.generateHybridResponse(
          input,
          userId: userId,
        );
      }

      final aiMsg = ChatMessage(
        content: response.text,
        isUser: false,
        isError: response.isError,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        activeProvider: response.metadata.provider,
      );

      LoggerService.info(
          '✅ Response from ${response.metadata.provider} (${response.metadata.latencyMs}ms)');
    } catch (e, st) {
      LoggerService.error('Chat error', e, stackTrace: st);
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

  /// Diagnostic: Check which providers are available
  Future<Map<String, dynamic>> getSystemStatus() async {
    return _backendService.getSystemStatus();
  }
}
