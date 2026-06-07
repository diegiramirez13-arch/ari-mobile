# 🚀 Guía de integración: Firebase + Google Cloud + ARI Mobile

Esta guía define la arquitectura de producción para conectar la app Flutter de ARI Mobile con Firebase, Cloud Run y un orquestador híbrido de IA.

## Arquitectura objetivo

```text
Flutter App
  ├─ Firebase Auth: identidad del usuario
  ├─ Firestore: sincronización en tiempo real
  └─ Cloud Run Backend: API segura autenticada
        ├─ OpenAI: proveedor primario
        ├─ Kimi: proveedor secundario
        ├─ Gemini: fallback
        ├─ PayPal validation
        └─ Firestore Admin SDK
```

## Flujo end-to-end de chat

1. El usuario escribe un mensaje en ARI Mobile.
2. La app obtiene un Firebase ID token del usuario autenticado.
3. `CloudRunBackend` envía el prompt a `/api/chat/hybrid` con `Authorization: Bearer <token>`.
4. Cloud Run valida el token con Firebase Admin SDK.
5. El backend intenta OpenAI, luego Kimi, luego Gemini.
6. El backend persiste la conversación en Firestore.
7. La app recibe la respuesta HTTP y Firestore mantiene la sincronización en tiempo real.

## Contrato mínimo del backend

### `POST /api/chat/hybrid`

Request:

```json
{
  "prompt": "string",
  "userId": "firebase-uid",
  "timestamp": "2026-06-07T00:00:00.000Z"
}
```

Response `200`:

```json
{
  "response": "Texto de ARI",
  "backend": "openai|kimi|gemini",
  "tokensUsed": 123
}
```

Errores esperados:

- `401`: token ausente, inválido o expirado.
- `429`: límite de usuario o cuota de proveedor excedida.
- `503`: proveedores temporalmente no disponibles.

### `POST /api/paypal/activate-plan`

El backend debe validar la transacción directamente contra PayPal antes de actualizar Firestore. La app solo envía identificadores públicos y el token de Firebase.

### `GET /api/system-status`

Health check usado por la app y por CI/CD. Debe responder rápido y sin consultar proveedores externos salvo que se solicite un diagnóstico profundo.

## Estrategia de secretos

- Las API keys de OpenAI, Kimi, Gemini y el secreto de PayPal viven en Google Secret Manager.
- La app Flutter puede leer claves locales solo para desarrollo, nunca como requisito de producción.
- Cloud Run usa una cuenta de servicio con permisos mínimos.
- Los logs nunca deben imprimir tokens, API keys ni payloads completos de usuarios.

## Observabilidad

Registrar en Cloud Logging:

- `requestId`, `userId` redacted/hash, endpoint y latencia.
- Proveedor usado y razón de fallback.
- Códigos de error normalizados.
- Resultado de validaciones PayPal sin imprimir datos sensibles.

## Checklist de Go-Live técnico

- [ ] Cloud Run responde `200` en `/api/system-status`.
- [ ] Firebase Auth valida tokens desde Android, iOS y Web.
- [ ] Firestore Rules bloquean acceso cruzado entre usuarios.
- [ ] Secret Manager contiene todas las claves requeridas.
- [ ] PayPal usa credenciales live solo en producción.
- [ ] Alertas configuradas para error rate, latencia y costos.
