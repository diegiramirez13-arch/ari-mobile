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
- [x] Added `firebase_options.dart` and actualización manual de credenciales Android/iOS/Web.
- [x] Created Firebase setup guide (`docs/FIREBASE_SETUP.md`).

**TODO Usuario (bloqueante):** correr `flutterfire configure` después de crear el proyecto en Firebase.

---

## Estado real de avance (actualizado)

### Paso 3: Función de perfil ✅
- [x] `UserProfileModel` implementado (`lib/core/models/user_profile_model.dart`).
- [x] Persistencia de perfil en Firestore + cache local (SharedPreferences).
- [x] `profile_provider.dart` con estados de carga/error.
- [x] Pantalla de alta/edición de perfil (`lib/features/profile/profile_screen.dart`).
- [x] Sincronización del perfil al iniciar sesión (`syncProfileOnLogin`).

### Paso 4: Gestión estatal mejorada 🟡 (parcial)
- [x] Migración principal de side effects de chat a Riverpod (`ChatController`).
- [x] Manejo de errores por estado (`error`) en chat y perfil.
- [x] Estados de carga visibles en chat/perfil.
- [ ] Añadir tests unitarios de providers/controladores críticos.

### Paso 5: Integración de IA 🟡 (parcial)
- [x] Servicio IA (`lib/core/services/ai_service.dart`) con `openai_dart`.
- [x] Modo Pro en chat con fallback básico y toggle en UI.
- [x] Prompt base de personalidad ARI implementado.
- [ ] Completar contrato multi-backend real (OpenAI / Mistral).
- [ ] Persistencia de historial optimizada para IA (resumen/token policy).

---

## Cierre de sprint (pendientes finales)
1. Ejecutar `flutterfire configure` en entorno con Flutter instalado.
2. Correr pruebas manuales E2E: login, perfil, chat básico, chat Pro.
3. Agregar tests unitarios mínimos (`ChatController`, `ProfileController`, `AIService`).
4. Revisión final de reglas Firestore + limpieza de documentación de release.

## Ejecución rápida (recomendada)

Para dejar todo listo en una sola pasada (clean + pub get + flutterfire + run):

```bash
./scripts/setup_and_run.sh
```

## Stack actual
- Flutter 3.16+
- Firebase (Auth + Firestore)
- Provider + Riverpod (State Management)
- Dio + openai_dart (HTTP / IA)
- SharedPreferences (almacenamiento local)

## Siguiente comando

```bash
flutter pub get
```

Si falla con `flutter: command not found`, instala Flutter o ejecuta desde un entorno que ya lo tenga en `PATH`.
