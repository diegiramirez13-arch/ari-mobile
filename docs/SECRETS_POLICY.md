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

### GitHub Actions (QA/PROD)

Configurar en **Settings → Secrets and variables → Actions**:

- `OPENAI_API_KEY_QA`
- `OPENAI_API_KEY_PROD`

> Recomendación: mapear el secreto correcto según rama/entorno y pasarlo a `--dart-define=OPENAI_API_KEY=...` en el workflow de build.

### Codespaces / Dev Container

En `.devcontainer/devcontainer.json` se propaga la key local:

```json
"remoteEnv": {
  "OPENAI_API_KEY": "${localEnv:OPENAI_API_KEY}"
}
```

## Checklist antes de commit

- [ ] `.env` está en `.gitignore`
- [ ] No hay keys hardcodeadas en código
- [ ] Se usa `String.fromEnvironment` para obtener `OPENAI_API_KEY`
