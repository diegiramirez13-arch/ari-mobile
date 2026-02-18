import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_service.dart';

// ============================================
// CONFIGURACIÓN DE ENTORNO
// ============================================

class AIConfig {
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static bool get hasKey => apiKey.isNotEmpty;

  // Feature flags por entorno
  static bool get enableProMode => hasKey;
  static bool get enableLocalFallback => true;
}

// ============================================
// SERVICIO
// ============================================

final aiServiceProvider = Provider<AIService?>((ref) {
  if (!AIConfig.hasKey) {
    debugPrint('🔧 Modo IA deshabilitado - API key no configurada');
    return null;
  }
  return AIService(config: const AIServiceConfig(apiKey: AIConfig.apiKey));
});

// ============================================
// ESTADO UNIFICADO
// ============================================

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

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.mode = ChatMode.basic,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    ChatMode? mode,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        mode: mode ?? this.mode,
        error: error,
      );

  bool get isProMode => mode == ChatMode.pro;
  bool get canSwitchToPro => AIConfig.enableProMode;
}

// ============================================
// CONTROLLER UNIFICADO
// ============================================

class ChatController extends StateNotifier<ChatState> {
  final Ref _ref;
  AIService? get _ai => _ref.read(aiServiceProvider);

  ChatController(this._ref) : super(const ChatState()) {
    _initialize();
  }

  void _initialize() {
    // Auto-switch a Pro si está disponible (opcional, podés quitar)
    final initialMode = AIConfig.hasKey ? ChatMode.pro : ChatMode.basic;

    state = ChatState(
      mode: initialMode,
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
    // MODO PRO: Usar IA real
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

    // MODO BÁSICO: Respuestas deterministas
    return _generateBasicResponse(userText);
  }

  String _generateBasicResponse(String userText) {
    final lower = userText.toLowerCase();
    final step = state.messages.length ~/ 2; // Contador de intercambios

    // Lógica simple pero útil
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

    // Respuestas genéricas rotativas
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
    if (!AIConfig.enableProMode && state.mode == ChatMode.basic) {
      // No permitir switch a Pro si no hay API key
      state = state.copyWith(
        error: 'Modo Pro no disponible. Configurá OPENAI_API_KEY',
      );
      return;
    }

    final newMode = state.isProMode ? ChatMode.basic : ChatMode.pro;

    state = state.copyWith(
      mode: newMode,
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

// ============================================
// PROVIDERS PÚBLICOS
// ============================================

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(ref),
);

final chatConfigProvider = Provider<AIConfig>((ref) => AIConfig());

// Selectores específicos para evitar rebuilds innecesarios
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
