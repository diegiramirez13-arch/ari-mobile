import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';

class LoginUiState {
  final bool useAnonymous;
  final bool isLoading;

  const LoginUiState({
    required this.useAnonymous,
    required this.isLoading,
  });

  const LoginUiState.initial()
      : useAnonymous = true,
        isLoading = false;

  LoginUiState copyWith({
    bool? useAnonymous,
    bool? isLoading,
  }) {
    return LoginUiState(
      useAnonymous: useAnonymous ?? this.useAnonymous,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final loginErrorProvider = StateProvider<String?>((ref) => null);

final loginControllerProvider =
    NotifierProvider<LoginController, LoginUiState>(LoginController.new);

class LoginController extends Notifier<LoginUiState> {
  @override
  LoginUiState build() => const LoginUiState.initial();

  void showAnonymous() {
    state = state.copyWith(useAnonymous: true);
    ref.read(loginErrorProvider.notifier).state = null;
  }

  void showEmail() {
    state = state.copyWith(useAnonymous: false);
    ref.read(loginErrorProvider.notifier).state = null;
  }

  Future<void> loginAnonymously() async {
    state = state.copyWith(isLoading: true);
    ref.read(loginErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpAnonymously();
    } catch (e) {
      ref.read(loginErrorProvider.notifier).state = 'Error: $e';
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      ref.read(loginErrorProvider.notifier).state =
          'Por favor completa todos los campos';
      return;
    }

    state = state.copyWith(isLoading: true);
    ref.read(loginErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      ref.read(loginErrorProvider.notifier).state = 'Error: $e';
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
