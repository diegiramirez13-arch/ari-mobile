import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/providers/auth_provider.dart';
import 'features/chat/chat_screen.dart';
import 'features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: AriApp(),
    ),
  );
}

class AriApp extends StatelessWidget {
  const AriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue.shade700,
          secondary: Colors.cyan.shade400,
          surface: Colors.grey.shade900,
          error: Colors.red.shade400,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Widget que verifica autenticación
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const SplashScreen(),
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        );
      },
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        return const ChatScreen();
      },
    );
  }
}

// Splash screen mientras se carga Firebase
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'ARI',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Inicializando...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
