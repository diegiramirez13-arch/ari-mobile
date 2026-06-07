import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/config/environment.dart';
import 'core/providers/ai_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/services/admob_service.dart';
import 'core/services/logger_service.dart';
import 'features/auth/login_screen.dart';
import 'features/chat/chat_screen.dart';

const Color _ariPrimary = Color(0xFF00E5FF);
const Color _ariBackground = Color(0xFF050A14);
const Color _ariSurface = Color(0xFF0B1220);

ThemeData buildAriDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _ariPrimary,
    brightness: Brightness.dark,
    surface: _ariSurface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _ariBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _ariSurface,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardColor: _ariSurface,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _ariSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _ariPrimary, width: 1.4),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _ariPrimary,
    ),
  );
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AdMobService.initialize();

    await dotenv.load(fileName: '.env', isOptional: true);
    configureEnvironment();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final bootstrapContainer = ProviderContainer();
    bootstrapContainer.read(chatConfigProvider);
    bootstrapContainer.read(aiServiceProvider);

    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }, (error, stack) {
    LoggerService.error(
      'Error Fatal No Capturado',
      error,
      stackTrace: stack,
    );
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(aiServiceProvider);

    return MaterialApp(
      title: 'ARI - Asistente de IA',
      debugShowCheckedModeBanner: false,
      theme: buildAriDarkTheme(),
      home: const AuthWrapper(),
    );
  }
}

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
    ref.read(chatConfigProvider);

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
