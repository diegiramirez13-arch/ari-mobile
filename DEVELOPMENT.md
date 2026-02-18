# ARI Assistant Development Log

## Sprint 0 - Foundation ✅

### Paso 1: Dependencies Setup ✅
- [x] Created `pubspec.yaml` with all core dependencies.
- [x] Added `shared_preferences` for local persistence.
- [x] Added Firebase dependencies (`firebase_core`, `firebase_auth`, `cloud_firestore`).
- [x] Added state management dependencies (`provider`, `get_it`, `riverpod`).
- [x] Added networking (`dio`).
- [x] Created assets directory structure.

### Paso 2: Firebase Integration ✅
- [x] Created `AuthService` for authentication.
- [x] Created `FirestoreService` for database access.
- [x] Created auth and firestore providers (Riverpod).
- [x] Updated `main.dart` with Firebase init.
- [x] Created `LoginScreen` with anonymous + email auth.
- [x] Created `ProjectModel` with Firestore serialization.
- [x] Added `firebase_options.dart` template.
- [x] Created Firebase setup guide (`docs/FIREBASE_SETUP.md`).

**TODO Usuario (bloqueante):** correr `flutterfire configure` después de crear el proyecto en Firebase.

---

## Plan de ejecución sugerido (Pasos 3, 4 y 5)

### Paso 3: Función de perfil
- [x] Crear `UserProfileModel` (`lib/core/models/user_profile_model.dart`).
- [x] Crear `profile_repository.dart` para Firestore + cache local (SharedPreferences).
- [x] Crear `profile_provider.dart` con estado `{data, isLoading, error}`.
- [x] Crear pantalla de alta/edición de perfil (`lib/features/profile/profile_screen.dart`).
- [x] Conectar guardado automático y lectura al iniciar sesión.

### Paso 4: Gestión estatal mejorada
- [x] Migrar side effects de pantallas a Notifiers/AsyncNotifiers de Riverpod.
- [x] Unificar estado de error con providers dedicados por feature.
- [x] Estandarizar estados de carga (`AsyncValue`, `when`, skeletons/spinners).
- [x] Añadir tests unitarios de providers críticos.

### Paso 5: Integración de IA
- [ ] Crear servicio `ai_service.dart` usando `dio`.
- [ ] Definir contrato para múltiples backends (OpenAI / Mistral).
- [ ] Crear “modo Pro” en chat con feature flag por usuario.
- [ ] Añadir prompt base de personalidad ARI y reglas de seguridad.
- [ ] Persistir historial relevante (resumen, no tokens crudos sensibles).

---

## Stack actual
- Flutter 3.16+
- Firebase (Auth + Firestore)
- Provider + Riverpod (State Management)
- Dio (HTTP client)
- SharedPreferences (almacenamiento local)

## Siguiente comando

```bash
flutter pub get
```

Si falla con `flutter: command not found`, instala Flutter o ejecuta desde un entorno que ya lo tenga en `PATH`.
