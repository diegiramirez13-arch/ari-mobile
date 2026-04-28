# ARI Mobile — Lectura completa de avance (Arcos A, B, C y D)
**Fecha:** 2026-04-25

## TL;DR
- **Arco A (modelos):** completado a nivel placeholder/contrato base.
- **Arco B (multi-backend):** completado en estructura, pero todavía no integrado al flujo principal de app (`ai_provider`/`main`).
- **Arco C (persistencia):** implementación en memoria lista; persistencia local real sigue en placeholder.
- **Arco D (documentación):** guía técnica completa agregada, útil como roadmap de integración.

Conclusión práctica: la base está avanzada, pero **todavía falta integración end-to-end y estabilización de tests** para considerar el stack V2 “en producción”.

---

## Arco A — Modelos (estado actual)

### Hecho
Se incorporaron los modelos base:
- `chat_mode.dart`
- `ai_service_config.dart`
- `ai_response.dart`
- `chat_message.dart`

### Valor
- Ya existe un contrato mínimo común para backends y mensajes.
- Permite desacoplar UI/servicio/backend a futuro.

### Riesgo pendiente
- Hay tests legacy que esperan forma distinta de algunos tipos/campos (por ejemplo propiedades heredadas del servicio anterior).

---

## Arco B — Contrato multi-backend (estado actual)

### Hecho
Se agregaron:
- interfaz `AIBackend`
- `OpenAIBackend`
- `GeminiBackend`
- `LocalBackend`
- orquestador `AIServiceV2`

### Qué funciona hoy
- selección por modo/config
- fallback local
- errores básicos tipados por `AIResponse`

### Qué falta para cerrar B
1. Integrar `AIServiceV2` en `ai_provider.dart` actual (hoy conviven V1 y V2).
2. Definir política de selección explícita por proveedor (hoy `pro/enterprise` prioriza el primer backend remoto disponible en la lista).
3. Soportar API keys separadas por proveedor (OpenAI/Gemini) y no una sola `apiKey` genérica.
4. Añadir retries/timeouts/circuit-breaker básico y métricas por backend.

---

## Arco C — Persistencia de contexto (estado actual)

### Hecho
- `ContextPersistence` definido.
- `MemoryPersistence` implementado y funcional para sesión en runtime.
- `LocalStoragePersistence` existe, pero sigue como placeholder.

### Qué falta para cerrar C
1. Implementar `LocalStoragePersistence` real (web: localStorage; mobile: SharedPreferences u otra opción).
2. Definir estrategia de versionado de schema de mensajes.
3. Definir límites (cantidad de mensajes/tamaño) y política de limpieza.
4. Decidir si se persiste contenido crudo o resumen semántico para privacidad.

---

## Arco D — Documentación/guía de implementación

### Hecho
- Se agregó guía `IMPLEMENTATION_GUIDE_ABCD.md` con estructura, ejemplo de integración y prioridades.

### Observaciones
- La guía está bien para alinear equipo, pero incluye código de ejemplo no aplicado aún en la app real.
- Debe tratarse como plan de implementación, no como reflejo exacto de estado productivo.

---

## Errores / inconsistencias detectadas hoy

1. **Desalineación tests vs implementación actual**
   - Hay tests que referencian contratos/propiedades del stack anterior o de forma distinta a los modelos actuales.

2. **V1 y V2 de IA coexistiendo**
   - El flujo productivo aún no migró completamente al nuevo contrato multi-backend.

3. **Persistencia local incompleta**
   - `LocalStoragePersistence` no está implementado; sólo memoria.

4. **Entorno sin toolchain en esta instancia**
   - Sin `flutter`/`dart` disponibles aquí no se puede certificar estado real de compilación/tests.

---

## Qué falta para dar por “cerrado” el trabajo de los 4 arcos

## Bloque 1 (obligatorio, corto plazo)
- Migrar provider/UI principal a `AIServiceV2`.
- Unificar contrato de tests con modelos actuales.
- Completar `LocalStoragePersistence`.
- Ejecutar baseline de calidad (`flutter pub get`, `flutter analyze`, `flutter test`).

## Bloque 2 (recomendado)
- Política formal de selección de backend (por modo + proveedor explícito).
- Observabilidad mínima: latencia, errores, backend activo.
- Manejo de seguridad: reglas de prompt/sanitización y límites.

---

## Prioridad sugerida (orden de trabajo)
1. **P0**: Test suite + compile green.
2. **P1**: Migración funcional a `AIServiceV2` en provider/main/chat real.
3. **P2**: Persistencia local real + recuperación de sesiones.
4. **P3**: Hardening de red/errores/telemetría.
5. **P4**: Ajuste final de docs para que describan estado real pos-migración.

---

## Estado final resumido (honesto)
Estamos en un punto de **arquitectura preparada pero integración incompleta**.
No está “mal hecho”; está en una fase de transición natural: el diseño nuevo (A+B+C+D) ya existe, pero falta cerrarlo en runtime real + test suite para que el equipo trabaje sobre una base verdaderamente estable.
