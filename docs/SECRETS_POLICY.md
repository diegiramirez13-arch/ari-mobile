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

## Reglas obligatorias antes de publicar el repositorio

- Nunca poner PATs o API keys en comandos como `git remote set-url https://TOKEN@github.com/...`.
- Si un token se expone por consola, historial o capturas, revocarlo inmediatamente en GitHub.
- Mantener el remoto sin credenciales embebidas: `https://github.com/<owner>/<repo>.git`.
- Subir secretos solo vía GitHub Actions Secrets / entorno de ejecución, nunca al código.

## Verificación rápida

```bash
# Confirmar remoto sin token inline
git remote -v

# Confirmar ignore de secretos comunes
git check-ignore -v .env .env.local .env.production google-services.json GoogleService-Info.plist android/app/google-services.json

# Buscar patrones sensibles en tracked files
git grep -nE "ghp_|AIza|sk-[A-Za-z0-9]|OPENAI_API_KEY|api[_-]?key|secret|token|password" -- . ":(exclude).gitignore"
```
