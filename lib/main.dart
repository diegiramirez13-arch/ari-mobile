import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/config/environment.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/chat/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno y feature flags antes de inicializar servicios.
  configureEnvironment();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARI - Asistente de IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
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
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  String? _lastSyncedUserId;
  late final ProviderSubscription<AsyncValue<User?>> _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        ref.listenManual<AsyncValue<User?>>(authStateProvider, (previous, next) {
      final userId = next.value?.uid;
      if (userId != null && userId != _lastSyncedUserId) {
        _lastSyncedUserId = userId;
        ref.read(profileControllerProvider.notifier).syncProfileOnLogin();
      }

      if (userId == null) {
        _lastSyncedUserId = null;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
