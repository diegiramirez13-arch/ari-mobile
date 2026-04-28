# ARI Mobile — Lectura de estado (25 abril 2026)

## Resumen ejecutivo

El proyecto **sí tiene base funcional de app Flutter** (autenticación Firebase, chat, proyectos locales y perfil), pero está en una fase de transición donde hay señales claras de **desalineación entre implementación, documentación y tests**.

En términos prácticos:

- La arquitectura base está armada y el flujo principal existe.
- Hay features “semicompletadas” (IA Pro y sincronización completa de datos).
- El mayor riesgo actual no es una sola feature faltante, sino la **consistencia del proyecto** (tests que no reflejan el código actual, docs parcialmente desactualizadas y setup bloqueado por entorno).

---

## Qué está implementado hoy

### 1) Base de app y arranque

- Inicialización de Firebase en `main.dart`.
- App envuelta en `ProviderScope` con Riverpod.
- Router básico por estado de autenticación (`AuthWrapper`):
  - usuario no autenticado -> `LoginScreen`
  - usuario autenticado -> `ChatScreen`
- Tema dark básico ya aplicado.

### 2) Autenticación y Firestore

- Servicio de auth y provider de estado de usuario.
- Servicio de Firestore con operaciones para:
  - proyectos
  - historial de chat
  - perfil
- Proveedores Riverpod para streams de proyectos/chat.

### 3) Perfil de usuario

- Modelo de perfil con persistencia remota y cache local (SharedPreferences).
- `ProfileController` con:
  - carga remota con fallback a cache
  - guardado con estado de error
  - sincronización en login (cache <-> remoto)

### 4) Proyectos

- Módulo de proyectos local con `ProjectsRepository` + `ProjectsStorage`.
- Provider AsyncNotifier para:
  - carga inicial
  - alta de proyecto
  - toggle de completado
- Seed inicial de 2 proyectos si no hay datos.

### 5) Chat e IA

- `ChatController` con estado de mensajes/carga/error.
- Modo básico cuando no hay API key.
- Integración de OpenAI con `openai_dart` cuando `OPENAI_API_KEY` existe.
- Prompt de sistema inicial y manejo de historial corto en memoria.

---

## Qué falta (brecha contra el plan)

Tomando como referencia el plan de `DEVELOPMENT.md`, la mayor brecha está en Paso 5 (IA):

1. **Contrato multi-backend IA** (OpenAI / Mistral) no implementado.
2. **Prompt/rules de seguridad robustas**: hay prompt base, pero no un marco de seguridad/versionado más completo.
3. **Persistencia útil de contexto IA**: hoy hay historial acotado en memoria, no una estrategia de resumen persistente segura.

Además, el flujo funcional principal todavía está acotado:

4. No hay navegación visible a módulos clave (por ejemplo, proyectos/perfil) desde un shell unificado.
5. Falta endurecer observabilidad y manejo de errores (logging estructurado, trazabilidad).

---

## Errores y problemas detectados

## 1) Tests desactualizados vs implementación actual (crítico)

Se detecta una inconsistencia fuerte:

- Tests esperan APIs/estructuras que ya no existen en `ai_provider.dart` y `ai_service.dart`.
- Ejemplos visibles:
  - tests que usan `ChatMode` / propiedad `mode`, mientras el estado actual usa `ChatConfig`.
  - tests que esperan `AIServiceConfig` y `AIResponse`, pero el servicio actual no expone esa API.
  - tests de integración de chat esperan ícono `bolt` y diálogo de “Limpiar” que no están en la UI actual.

**Impacto:** hoy la suite de tests no es fuente confiable de calidad en ese módulo; primero hay que realinearla.

## 2) Entorno sin Flutter/Dart instalado en esta instancia (bloqueante operativo)

No se pudo ejecutar validación local (`flutter`/`dart` no están en PATH en esta máquina).

**Impacto:** no se puede verificar build/analyze/test en este entorno hasta resolver toolchain.

## 3) Riesgo de dualidad de fuentes de verdad en proyectos

Existe capa de proyectos local (`features/projects/...`) y capa Firestore (`core/providers/firestore_provider.dart`) en paralelo.

**Impacto:** sin una estrategia explícita de sincronización/conflictos, hay riesgo de divergencia entre datos locales y remotos cuando se integren flujos completos de UI.

---

## Qué sigue (prioridad recomendada)

## Prioridad 1 — Recuperar confiabilidad del proyecto

1. Instalar/estandarizar toolchain (Flutter + Dart + Firebase CLI) en entorno de trabajo.
2. Correr baseline:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
3. Corregir tests rotos para que reflejen el contrato actual de chat/IA.

## Prioridad 2 — Cerrar arquitectura de datos

4. Definir si proyectos/chat serán:
   - local-first con sync diferida, o
   - remote-first con cache.
5. Unificar providers/repositorios para evitar duplicación de responsabilidades.

## Prioridad 3 — Completar Paso 5 IA

6. Extraer interfaz de proveedor IA (adapter pattern) para soportar OpenAI/Mistral.
7. Consolidar “ARI Safety + Tone Pack” versionado.
8. Diseñar persistencia de contexto segura (resúmenes, no logs crudos sensibles).

## Prioridad 4 — UX de producto

9. Agregar navegación clara entre Chat / Proyectos / Perfil.
10. Definir estados vacíos, errores y acciones de recuperación consistentes.

---

## Plan de ejecución sugerido (7 días)

### Día 1-2

- Setup entorno y baseline técnico.
- Inventario de tests rotos + issue list priorizada.

### Día 3-4

- Refactor de tests de chat/IA para contrato vigente.
- Decisión y RFC corta de estrategia de sincronización de proyectos/chat.

### Día 5-6

- Implementación del contrato multi-backend IA.
- Mejoras de manejo de errores + telemetría mínima.

### Día 7

- Regression run completo.
- Actualizar `DEVELOPMENT.md` a estado real.

---

## Indicadores de “estamos listos para avanzar bien”

- `flutter analyze` en verde.
- Suite de tests unitaria base pasando en chat/proyectos/perfil.
- Flujo end-to-end mínimo: login -> chat -> crear proyecto -> editar perfil.
- Documento de arquitectura de datos (1 fuente de verdad por entidad).
- Backlog IA con tareas cerrables por sprint.

---

## Conclusión

Hoy ARI Mobile está en una fase **MVP técnico funcional, pero no aún endurecido**. La base existe y permite trabajar rápido, pero antes de ampliar alcance conviene invertir un sprint corto en **alinear tests, toolchain y arquitectura de datos**. Eso reduce retrabajo y habilita completar IA Pro con mucho menos riesgo.
