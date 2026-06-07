# 🌐 Setup Google Cloud paso a paso

## 1. Crear proyecto GCP

```bash
gcloud projects create ari-ai-prod --name="ARI AI Production"
gcloud config set project ari-ai-prod
```

Habilitar facturación antes de activar servicios administrados.

## 2. Activar APIs necesarias

```bash
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  firestore.googleapis.com \
  firebase.googleapis.com \
  iamcredentials.googleapis.com
```

## 3. Crear cuenta de servicio para Cloud Run

```bash
gcloud iam service-accounts create ari-backend \
  --display-name="ARI Cloud Run Backend"
```

Permisos recomendados:

```bash
gcloud projects add-iam-policy-binding ari-ai-prod \
  --member="serviceAccount:ari-backend@ari-ai-prod.iam.gserviceaccount.com" \
  --role="roles/datastore.user"

gcloud projects add-iam-policy-binding ari-ai-prod \
  --member="serviceAccount:ari-backend@ari-ai-prod.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## 4. Configurar Secret Manager

```bash
printf '%s' "$OPENAI_API_KEY" | gcloud secrets create openai-api-key --data-file=-
printf '%s' "$KIMI_API_KEY" | gcloud secrets create kimi-api-key --data-file=-
printf '%s' "$GEMINI_API_KEY" | gcloud secrets create gemini-api-key --data-file=-
printf '%s' "$PAYPAL_SECRET" | gcloud secrets create paypal-secret --data-file=-
```

Rotación recomendada: cada 90 días o inmediatamente ante sospecha de exposición.

## 5. Configurar Firebase

1. Crear o vincular el proyecto Firebase con `ari-ai-prod`.
2. Agregar apps Android/iOS/Web.
3. Descargar `google-services.json` y `GoogleService-Info.plist` cuando aplique.
4. Habilitar Firebase Authentication.
5. Crear Firestore en modo producción.
6. Publicar `docs/FIRESTORE_RULES_PRODUCTION.rules`.

## 6. Desplegar Cloud Run manualmente

```bash
docker build -t gcr.io/ari-ai-prod/ari-backend:manual server/
docker push gcr.io/ari-ai-prod/ari-backend:manual

gcloud run deploy ari-backend \
  --image gcr.io/ari-ai-prod/ari-backend:manual \
  --platform managed \
  --region us-central1 \
  --no-allow-unauthenticated \
  --service-account ari-backend@ari-ai-prod.iam.gserviceaccount.com \
  --memory 512Mi \
  --timeout 300s
```

## 7. Configurar GitHub Actions

Crear secretos en GitHub:

- `GCP_SA_KEY`: JSON de cuenta de servicio de despliegue o migrar a Workload Identity Federation.
- `FIREBASE_TOKEN` si se automatiza despliegue de reglas.

## 8. Validación post-deploy

```bash
SERVICE_URL=$(gcloud run services describe ari-backend \
  --region us-central1 \
  --format 'value(status.url)')

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  "$SERVICE_URL/api/system-status"
```
