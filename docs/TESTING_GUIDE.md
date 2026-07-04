# 🧪 Guía de testing completo - ARI Mobile

## Fase 1: Local sin cloud

```bash
flutter pub get
dart format \
  lib/core/models/ai_response.dart \
  lib/core/config/cloud_secrets.dart \
  lib/core/services/cloud_run_backend.dart \
  lib/core/services/openai_backend.dart \
  lib/core/services/kimi_backend.dart \
  lib/core/services/gemini_backend.dart \
  lib/core/services/hybrid_ai_orchestrator.dart
flutter analyze
flutter test
```

Validar que el fallback local responde sin claves de IA y que el orquestador no convierte errores de proveedor en respuestas exitosas.


## Fase 1B: Backend local

```bash
cd server
npm run check
npm start
```

En otra terminal:

```bash
curl http://localhost:8080/api/system-status
curl -X POST http://localhost:8080/api/chat/hybrid \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"Hola ARI"}'
```

## Fase 2: Local con API keys de desarrollo

Crear `.env` desde `.env.example` y definir claves de sandbox/desarrollo (`OPENAI_API_KEY`, `KIMI_API_KEY`, `GEMINI_API_KEY`). Nunca usar claves productivas en máquinas no confiables.

```bash
flutter test test/core/services
```

## Fase 3: Android emulator

```bash
flutter run -d emulator-5554 --dart-define=BACKEND_URL=http://10.0.2.2:3000
```

Casos mínimos:

- Login/logout.
- Envío de mensaje.
- Persistencia de historial.
- Fallback cuando Cloud Run no responde.

## Fase 4: Dispositivo Android real

```bash
flutter devices
flutter run -d <device-id> --release
```

Validar conectividad real, permisos de red y tiempos de respuesta.

## Fase 5: iOS

```bash
flutter run -d <ios-device-id>
```

Validar Firebase config, deep links de PayPal si se usan y experiencia de login.

## Fase 6: Cloud Run backend

```bash
SERVICE_URL=$(gcloud run services describe ari-backend \
  --region us-central1 \
  --format 'value(status.url)')

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  "$SERVICE_URL/api/system-status"
```

## Fase 7: Seguridad

- Intentar leer datos de otro usuario en Firestore: debe fallar.
- Llamar endpoints sin token: debe responder `401`.
- Llamar endpoints con token expirado: debe responder `401`.
- Simular proveedor IA caído: debe activar fallback en orden OpenAI GPT-4o → Kimi Moonshot → Gemini → Local.

## Fase 8: Load testing controlado

Ejecutar solo contra un ambiente preparado:

```bash
k6 run scripts/load/chat_orchestrator.js
```

Métricas objetivo iniciales:

- p95 menor a 5 segundos para health/API ligera.
- Error rate menor a 1% excluyendo límites intencionales.
- Costos por usuario dentro del presupuesto.

## Fase 9: Pre-launch stores

- Revisar permisos Android/iOS.
- Confirmar política de privacidad.
- Confirmar eliminación de datos de usuario.
- Confirmar capturas y textos de tienda.
