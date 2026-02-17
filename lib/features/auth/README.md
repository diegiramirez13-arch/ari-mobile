# Auth Feature

Gestión de autenticación con Firebase.

## Componentes:

- **LoginScreen** - Pantalla de login/signup
  - Opción de login anónimo (para desarrollo)
  - Opción de email/password
  - Integración con AuthService

## Usage:

```dart
// Obtener estado de autenticación
final user = ref.watch(authStateProvider).value;

// Obtener ID del usuario actual
final userId = ref.watch(currentUserIdProvider);

// Chequear si está autenticado
final isAuth = ref.watch(isAuthenticatedProvider);
```

## Flujo:

1. App inicia y carga Firebase
2. SplashScreen mientras inicializa
3. Si no hay usuario -> LoginScreen
4. Si hay usuario -> ChatScreen

## Auth Methods:

- `signUpAnonymously()` - Autenticación anónima
- `signUpWithEmail()` - Crear cuenta
- `signInWithEmail()` - Ingresar
- `signOut()` - Cerrar sesión
- `resetPassword()` - Reset contraseña
