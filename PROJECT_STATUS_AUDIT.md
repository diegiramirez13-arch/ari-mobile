# Estado integral de ARI Mobile (auditoría técnica)

Fecha de corte: 2026-04-13 (UTC)

## Resumen ejecutivo

ARI Mobile tiene una base funcional **real** para autenticación, chat, perfil y almacenamiento local/Firebase, pero el proyecto está en una fase intermedia: hay avances importantes en arquitectura con Riverpod y sincronización de perfil, y al mismo tiempo hay inconsistencias serias entre implementación, documentación y suite de tests.

Conclusión operativa: el producto está **bien encaminado técnicamente**, pero **no está listo para una validación confiable de calidad** hasta alinear tests/documentación con el código actual y correr un pipeline real de CI con Flutter disponible.

---

## Qué está bien (fortalezas actuales)

1. **Bootstrap de app sólido**
   - Inicializa `Firebase` al arranque y usa `ProviderScope` global.
   - Tiene `AuthWrapper` con control de estados `loading/error/data`.
   - Incluye sincronización de perfil en login (`syncProfileOnLogin`).

2. **Separación por capas razonable**
   - `services` para Firebase/Auth/AI.
   - `repositories` para persistencia y cache (`ProfileRepository`).
   - `providers` para estado de UI y flujos async (Riverpod).

3. **Feature de perfil bien planteada para MVP+**
   - Cache local (SharedPreferences) + remota (Firestore).
   - Estrategia offline-first parcial (lee cache y luego remoto).
   - Manejo explícito de errores de sincronización y guardado.

4. **Chat con configuración por entorno y usuario**
   - `ChatConfig` combina disponibilidad de API key + flag de usuario Pro.
   - Fallback en modo básico cuando no hay IA habilitada.

5. **Módulo proyectos utilizable en local**
   - Persistencia local simple con SharedPreferences.
   - Controller con operaciones de carga, creación y toggle de completado.

---

## Qué falta (gaps para avanzar a una versión confiable)

1. **Alineación crítica tests ↔ implementación (prioridad alta)**
   - Los tests de chat/IA referencian APIs y tipos que no existen en el código actual (`AIServiceConfig`, `AIResponse`, `ChatMode`, `state.mode`, etc.).
   - Esto sugiere una refactorización no acompañada por actualización de pruebas.

2. **Pipeline de verificación ejecutable en entorno real**
   - Existe `verify.sh` con `flutter pub get/analyze/test/build`, pero sin Flutter en entorno no se puede validar estado real.
   - Hace falta CI (GitHub Actions o similar) para chequeos automáticos por commit.

3. **Integración IA incompleta respecto al plan**
   - El plan de desarrollo mantiene pendientes: contrato multi-backend, prompt/safety más robusto y persistencia resumida de historial.
   - Además, la documentación del plan habla de `dio` para IA pero implementación actual usa `openai_dart`.

4. **Documentación desactualizada o inconsistente**
   - Estado en `DEVELOPMENT.md` no refleja plenamente lo implementado en `ai_service.dart`.
   - `PASO_2_STATUS.md` describe estado anterior (útil históricamente, pero requiere refresh para estado actual del repo).

5. **Flujo de navegación de producto incompleto**
   - Aunque existen pantallas de `Projects` y `Profile`, el flujo principal actual entra a `ChatScreen` tras auth, sin navegación visible a esas features en el entrypoint.

---

## Errores / riesgos detectados

### 1) Riesgo de calidad: tests aparentemente rotos por drift de API
La suite de tests incluida no coincide con los contratos actuales del código en varios puntos. Esto suele romper `flutter test` al compilar.

Impacto:
- Baja confianza en regresiones.
- Bloqueo para releases estables.

### 2) Riesgo de observabilidad y manejo de errores
En `AuthService` y `FirestoreService` se usa `print(...)` para errores.

Impacto:
- Difícil trazabilidad en producción.
- Sin clasificación estructurada de fallas.

### 3) Riesgo de UX funcional
`ChatScreen` no expone visualmente errores de `ChatState.error` como banner/snackbar dedicado; varios errores quedan implícitos en mensaje de texto o estado interno.

Impacto:
- Usuario final puede no entender por qué falló una acción.

### 4) Riesgo de seguridad/robustez IA
Hay prompt base en el servicio IA, pero falta una capa declarada de políticas/safety más completa y versionada (como señala el plan).

Impacto:
- Comportamiento de respuestas menos controlado.

### 5) Riesgo de “estado del proyecto” ambiguo
Documentos de estado y código dicen cosas diferentes en puntos clave.

Impacto:
- Decisiones de producto/tecnología pueden tomarse con diagnóstico equivocado.

---

## Estado por componente

- **Auth/Firebase:** funcional base, pendiente hardening de errores y validación end-to-end en entorno con Flutter/Firebase configurado.
- **Perfil:** buen avance, probablemente el módulo más consistente entre arquitectura y código.
- **Chat/IA:** funcional en básico y pro condicionada, pero requiere estabilización fuerte de pruebas y definición clara de contratos.
- **Proyectos:** funcional local; falta integrar mejor con navegación global y estrategia de sincronización si se quiere paridad con perfil/chat.
- **Testing/QA:** principal deuda técnica inmediata.

---

## Plan de acción recomendado (orden sugerido)

1. **Corregir/reescribir tests para reflejar APIs actuales** (chat/IA primero).
2. **Habilitar CI obligatorio** (`flutter analyze`, `flutter test`, build objetivo).
3. **Actualizar documentación de estado** (`DEVELOPMENT.md`, `PASO_2_STATUS.md`) para evitar drift.
4. **Mejorar manejo de errores** (logger estructurado + surface en UI).
5. **Cerrar pendientes de IA del plan** (contrato multi-backend, safety, memoria resumida).
6. **Agregar navegación explícita a Projects/Profile** desde flujo principal.

---

## Diagnóstico final (cómo estamos parados)

- **Semáforo general:** 🟡 Amarillo.
- **Base técnica:** buena.
- **Riesgo actual:** medio-alto por falta de validación automatizada confiable.
- **Listo para escalar features:** sí, pero solo después de estabilizar QA y alinear documentación.

