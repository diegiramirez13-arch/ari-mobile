# Política de Secretos ARI

## Entornos

| Entorno | Quién setea | Cómo | OPENAI_API_KEY |
|---------|-------------|------|----------------|
| DEV | Developer local | `.env` local o `--dart-define` | Key personal de dev |
| QA | CI/CD GitHub Actions | Secrets del repo | Key de testing (rate limit alto) |
| PROD | Lead + DevOps | GitHub Secrets + Cloud | Key de producción (billing alert) |

## Configuración por entorno

### Local (DEV)

```bash
# Archivo .env (NO commitear)
echo "OPENAI_API_KEY=sk-dev-tu-key" > .env
flutter run --dart-define-from-file=.env
```
