import 'package:firebase_auth/firebase_auth.dart';
import 'logger_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream de usuario autenticado
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up anónimo (para desarrollo)
  Future<UserCredential?> signUpAnonymously() async {
    try {
      return await _firebaseAuth.signInAnonymously();
    } catch (e, st) {
      LoggerService.error('Error en sign up anónimo', e, stackTrace: st);
      return null;
    }
  }

  // Sign up con email/password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, st) {
      LoggerService.error('Error en sign up', e, stackTrace: st);
      return null;
    }
  }

  // Login con email/password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, st) {
      LoggerService.error('Error en login', e, stackTrace: st);
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e, st) {
      LoggerService.error('Error en reset', e, stackTrace: st);
    }
  }
}
