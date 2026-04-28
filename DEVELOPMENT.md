# ARI Mobile - Asistente de Inteligencia Aplicada

## Estado de Desarrollo y Roadmap Técnico

- [x] **Paso 1:** Setup de dependencias y estructura base.
- [x] **Paso 2:** Integración Firebase (Auth + Firestore).
- [x] **Paso 3:** Implementación del perfil de usuario completo.
- [x] **Paso 4:** Gestión de estado unificada con Riverpod.
- [ ] **Paso 5: Integración IA Híbrida (EN PROGRESO - PARCIALMENTE IMPLEMENTADO)**
  - [x] Lógica de feature flag (Basic/Pro) mediante `OPENAI_API_KEY`.
  - [x] Servicio `AIService` integrado con `openai_dart`.
  - [x] Adaptación de UI de Chat al contrato único (`ChatMessage`).
  - [ ] Reestructurar tests para que coincidan con los nuevos contratos.
  - [ ] Parser de intenciones (creación automática de proyectos desde el chat).

## Siguiente Foco de Acción:
* Saneamiento de dependencias y pruebas unitarias de `ai_provider` y `ai_service`.
* Vincular vista de proyectos a Firestore (Persistencia Real).
