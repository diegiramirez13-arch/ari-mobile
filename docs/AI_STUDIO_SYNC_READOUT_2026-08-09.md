# ARI MÔBILE AI — AI Studio Sync Readout

Fecha de sincronización: 2026-08-09
Origen informado: Google I/O Studio / AI Studio
Destino: Codex repo `ari-mobile`

## Identidad del proyecto

- Proyecto: ARI MÔBILE AI
- Fundador / líder técnico: Diego Ramírez (NOR13)
- Origen: Villa María, Córdoba, Argentina
- Dominio oficial: arimobile.ai
- Email admin informado: arimobile.ai@gmail.com

## Lectura recibida desde AI Studio

AI Studio reporta una plataforma más avanzada que el cliente Flutter aislado:

- Web/Dashboard: React 18 + Vite + Tailwind CSS + Motion.
- Backend: Node.js / Express con build TypeScript/esbuild en Cloud Run.
- Persistencia: Firebase Auth + Cloud Firestore.
- Push: Firebase Cloud Messaging con service workers.
- Mobile target: Android APK `com.umbra.ariapp` con SDK 34.
- Marca unificada: ARI MÔBILE AI / arimobile.ai.

## Contrato backend que debe mantenerse estable

Codex debe conservar estos endpoints para que Flutter, Web y CI hablen con el
mismo backend:

```text
GET  /api/system-status
POST /api/chat/hybrid
POST /api/paypal/activate-plan
```

## Orquestación multi-IA informada

Orden operativo informado por AI Studio:

1. OpenAI GPT-4o / GPT-4o-mini como proveedor primario.
2. Google Gemini como fallback inmediato.
3. Moonshot Kimi como fallback adicional.
4. Anthropic Claude 3.5 como redundancia extra.
5. AriCore local kernel para continuidad offline/local.

En este repo se agregó soporte backend para Anthropic/Claude en `server/`.
La app Flutter sigue usando Cloud Run como ruta segura para proveedores que no
deben exponer claves en cliente.

## Variables de entorno informadas

No incluir valores reales en Git.

```text
OPENAI_API_KEY=
GEMINI_API_KEY=
KIMI_API_KEY=
ANTHROPIC_API_KEY=
STRIPE_SECRET_KEY=
MERCADOPAGO_TOKEN=
FIREBASE_PROJECT=
ADMIN_EMAIL=
```

## Bloqueos detectados por AI Studio

1. Carga final de secretos productivos en Cloud Run / Secret Manager.
2. Mapeo DNS final para `arimobile.ai` hacia Cloud Run.
3. Verificación FCM en APK Android real.
4. Pruebas E2E de pagos Stripe / Mercado Pago / PayPal.
5. Build release Android con firma final.

## Decisiones para Codex

- No copiar secretos reales al repo.
- Mantener `server/` como fuente deployable del workflow Cloud Run.
- Mantener `/api/chat/hybrid` como contrato único para Web y Mobile.
- Alinear futuros modelos Flutter con Firestore real: `projects`, `tasks`,
  `decisions`, `users`, `messages`.
- Solicitar patch/código real de AI Studio antes de reemplazar dashboard o
  backend avanzado React/Express, porque la auditoría recibida no incluye los
  archivos fuente.
