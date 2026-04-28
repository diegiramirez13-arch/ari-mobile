# ARI Mobile — Reporte de Ingeniería de Combate

Fecha de corte: 2026-04-19 (UTC)

## 1) Resumen de Estructura (Acción > Charla)

### Confirmación arquitectónica
Sí: el repo está organizado por capas y usa una aproximación de **Clean Architecture pragmática**:
- **Modelos**: `lib/core/models/`.
- **Servicios de infraestructura**: `lib/core/services/` (Firebase/Auth/AI).
- **Repositorio de orquestación**: `lib/core/repositories/chat_repository.dart`.
- **Estado/UI logic**: `lib/core/providers/ai_provider.dart` con Riverpod.
- **Presentación**: `lib/features/*`.

### Orquestación ChatRepository (Rama A + Rama B)
- **Rama A (Persistencia)**: `getMessages()` y `saveMessage()` delegan en Firestore.
- **Rama B (IA)**: `getAIResponse()` transforma historial a `{role, content}` y llama `AIService.generateResponse()`.

Resultado: el controller no depende de detalles de OpenAI/Firestore, solo del repositorio.

---

## 2) Lo que SOBRA (Deuda técnica reducida)

### Archivos obsoletos
Confirmado: no están presentes los viejos duplicados del chat:
- `lib/features/chat/chat_provider.dart` → ausente
- `lib/features/chat/chat_logic.dart` → ausente
- `lib/features/chat/message.dart` → ausente

### Consolidación efectiva
- Estado/chat logic centralizado en `lib/core/providers/ai_provider.dart`.
- Modelo único de mensaje en `lib/core/models/chat_message.dart`.

---

## 3) Lo que FALTA (Bloqueantes operativos)

### A. Infraestructura Firebase (bloqueante real)
`firebase_options.dart` aún tiene placeholders (`YOUR_ANDROID_API_KEY`, etc.).
=> Falta ejecutar:
```bash
flutterfire configure --project=ari-mobile
```
Sin esto, el inicio real contra backend Firebase no queda operativo en móvil.

### B. Entorno Windows / Toolchain (bloqueante real)
En este estado de trabajo, `flutter` no está disponible en PATH (`command not found`).
Para Windows 10 v1607: sin Flutter SDK + PATH correcto no hay `pub get`, `run`, ni build.

### C. Secretos (avance correcto)
Ya migrado a `.env` con `flutter_dotenv`:
- `AppEnvironment.setup()` carga `.env`.
- `main.dart` ejecuta configuración de entorno antes de inicializar Firebase.

---

## 4) Estado del MVP

- **Conceptual:** ~85% (arquitectura y flujo objetivo ya definidos).
- **Técnico:** ~75% (núcleo escrito, falta validación de punta a punta en entorno real con Flutter + Firebase real).

Interpretación: el diseño ya está, pero falta “prueba de mar” en dispositivo real.

---

## 5) Diagnóstico final para salir a marea tranquila

Para que **compile en Windows** y el chat **no tenga amnesia** al cerrar sesión, la secuencia mínima es:

1. **Recuperar toolchain Flutter en Windows**
   - Instalar Flutter SDK.
   - Agregar `flutter/bin` al PATH.
   - Verificar con `flutter --version`.

2. **Restaurar/validar carpetas nativas** (si faltan)
   - Ejecutar `flutter create --platforms=android,ios .` desde raíz del repo.

3. **Conectar Firebase real**
   - Ejecutar `flutterfire configure --project=ari-mobile` para reemplazar placeholders en `firebase_options.dart`.
   - Validar reglas de Firestore para lectura/escritura autenticada.

4. **Validación técnica inmediata**
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
   - `flutter run`

5. **Prueba funcional crítica (anti-amnesia)**
   - Login.
   - Enviar mensajes.
   - Cerrar y reabrir app.
   - Confirmar que `ChatController` vuelve a hidratar desde `ChatRepository.getMessages()` y Firestore devuelve historial.

---

## Veredicto del Ingeniero Jefe

ARI Mobile está bien encaminado: la base de persistencia y orquestación ya existe y es coherente con “Acción > Charla”.
El único freno serio no es de diseño, es de **operación del entorno** (Flutter/FlutterFire/Firebase real).
Resuelto eso, el sistema debería pasar de prototipo frágil a MVP validable.
