import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// User stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user?.uid;
});

// Is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId != null;
});
