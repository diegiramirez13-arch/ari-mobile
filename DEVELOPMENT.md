# ARI Mobile - Bitácora de Desarrollo Oficial

**Estado Actual:** MVP Funcional y Validación CI/CD Activa.
**Filosofía:** Acción > Charla.

## Hoja de Ruta de Implementación

- [x] **PASO 1:** Arquitectura Base y Setup Inicial.
- [x] **PASO 2:** Integración Firebase (Auth funcional).
- [x] **PASO 3:** Módulo de Perfil y UI Dark Premium.
- [x] **PASO 4:** Gestión de Estado con Riverpod.
- [x] **PASO 5:** Inteligencia Híbrida y Orquestación (COMPLETADO).
  - Implementación de `AIServiceV2` (OpenAI + LocalBackend).
  - Safety wrapper (try/catch) contra fallos de red.
  - Memoria de contexto de corto plazo (6 mensajes).
- [x] **QA & CI/CD:** Pipeline de validación en GitHub Actions integrado. Tests alineados con el código vigente.

## Siguientes Pasos (Roadmap Enterprise)
1. Conectar persistencia profunda de `ChatRepository` a Firestore.
2. Generar compilación `.apk` final con Keystore.
3. Desplegar demo en Play Store.
