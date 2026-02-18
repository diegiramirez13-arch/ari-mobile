import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../services/ai_service.dart';

class ChatConfig {
  final bool hasKey;
  final bool enableAI;

  const ChatConfig({required this.hasKey, required this.enableAI});
}

final openAIApiKeyProvider = Provider<String>(
  (ref) => AppEnvironment.openAIApiKey,
);

final chatConfigProvider = Provider<ChatConfig>(
  (ref) => ChatConfig(
    hasKey: ref.watch(openAIApiKeyProvider).isNotEmpty,
    enableAI: AppEnvironment.enableAI,
  ),
);

final aiServiceProvider = Provider<AIService?>((ref) {
  final key = ref.watch(openAIApiKeyProvider);
  if (key.isEmpty) {
    debugPrint('🔧 Modo IA deshabilitado - API key no configurada');
    return null;
  }
  return AIService(config: AIServiceConfig(apiKey: key));
});

enum ChatMode { basic, pro }

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage.error(this.content)
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        isUser = false,
        timestamp = DateTime.now(),
        isError = true;
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ChatMode mode;
  final String? error;
  final bool canSwitchToPro;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.mode = ChatMode.basic,
    this.error,
    this.canSwitchToPro = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    ChatMode? mode,
    String? error,
    bool? canSwitchToPro,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        mode: mode ?? this.mode,
        error: error,
        canSwitchToPro: canSwitchToPro ?? this.canSwitchToPro,
      );

  bool get isProMode => mode == ChatMode.pro;
}

class ChatController extends StateNotifier<ChatState> {
  final Ref _ref;
  AIService? get _ai => _ref.read(aiServiceProvider);
  bool get _hasAIKey => _ref.read(openAIApiKeyProvider).isNotEmpty;

  ChatController(this._ref) : super(const ChatState()) {
    _initialize();
  }

  void _initialize() {
    final initialMode = _hasAIKey ? ChatMode.pro : ChatMode.basic;

    state = ChatState(
      mode: initialMode,
      canSwitchToPro: _hasAIKey,
      messages: [
        ChatMessage(
          id: 'welcome',
          content: _getWelcomeMessage(initialMode),
          isUser: false,
        ),
      ],
    );
  }

  String _getWelcomeMessage(ChatMode mode) {
    if (mode == ChatMode.pro) {
      return '¡Hola! Soy ARI con modo Pro activado. Tengo inteligencia artificial para ayudarte mejor. ¿Qué proyecto querés organizar?';
    }
    return '¡Hola! Soy ARI. Estoy en modo básico (sin IA). Configurá OPENAI_API_KEY para activar el modo Pro. ¿Qué querés organizar?';
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text.trim(),
      isUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _generateResponse(text);

      final assistantMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<String> _generateResponse(String userText) async {
    if (state.isProMode && _ai != null) {
      final history = state.messages
          .map((m) => AIMessage(
                role: m.isUser ? 'user' : 'assistant',
                content: m.content,
              ))
          .toList();

      final result = await _ai!.generateResponse(
        userMessage: userText,
        history: history,
      );

      if (result.isError) {
        throw Exception(result.errorMessage);
      }

      return result.text;
    }

    return _generateBasicResponse(userText);
  }

  String _generateBasicResponse(String userText) {
    final lower = userText.toLowerCase();
    final step = state.messages.length ~/ 2;

    if (lower.contains('hola') || lower.contains('buenas')) {
      return '¡Hola! ¿Qué proyecto querés organizar hoy?';
    }

    if (lower.contains('proyecto') ||
        lower.contains('quiero') ||
        lower.contains('necesito')) {
      return 'Perfecto, veo que querés empezar algo nuevo. ¿Cómo se llama el proyecto?';
    }

    if (step == 1) {
      return 'Entendido. ¿Qué objetivo querés lograr con esto? Sé específico.';
    }

    if (step == 2) {
      return 'Buenísimo. ¿Para cuándo lo necesitás? Fijemos una fecha.';
    }

    final generics = [
      'Dale, seguimos. ¿Qué sigue?',
      'Perfecto. ¿Necesitás ayuda con algún paso específico?',
      'Interesante. ¿Cómo te gustaría organizar eso?',
      'Vamos bien. ¿Querés que dividamos esto en tareas más chicas?',
      'Ok. ¿Hay algo que te esté trabando?',
    ];

    return generics[step % generics.length];
  }

  void toggleMode() {
    if (!_hasAIKey && state.mode == ChatMode.basic) {
      state = state.copyWith(
        error: 'Modo Pro no disponible. Configurá OPENAI_API_KEY',
      );
      return;
    }

    final newMode = state.isProMode ? ChatMode.basic : ChatMode.pro;

    state = state.copyWith(
      mode: newMode,
      canSwitchToPro: _hasAIKey,
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'system-${DateTime.now().millisecondsSinceEpoch}',
          content:
              '🔄 Modo cambiado a: ${newMode == ChatMode.pro ? "Pro (IA)" : "Básico"}',
          isUser: false,
        ),
      ],
      error: null,
    );
  }

  void clearChat() {
    _initialize();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(ref),
);

final chatMessagesProvider = Provider<List<ChatMessage>>(
  (ref) => ref.watch(chatControllerProvider).messages,
);

final chatIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatControllerProvider).isLoading,
);

final chatErrorProvider = Provider<String?>(
  (ref) => ref.watch(chatControllerProvider).error,
);

final chatModeProvider = Provider<ChatMode>(
  (ref) => ref.watch(chatControllerProvider).mode,
);
