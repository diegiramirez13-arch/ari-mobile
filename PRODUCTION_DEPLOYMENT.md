# 🚀 Deployment a producción - checklist final

## 48 horas antes

### Código

- [ ] Merge de `feature/cloud-integration-audit-unified` a `main` aprobado.
- [ ] `flutter analyze` sin errores.
- [ ] `flutter test` exitoso.
- [ ] `dart format` aplicado.
- [ ] Revisión de seguridad completada.

### Backend

- [ ] `cd server && npm run check` valida la sintaxis del backend sin errores.
- [ ] Endpoints `/api/system-status`, `/api/chat/hybrid` y `/api/paypal/activate-plan` probados.
- [ ] Secret Manager contiene claves productivas vigentes.
- [ ] Health check OK.
- [ ] Logs y métricas centralizados en Cloud Logging/Monitoring.

### Firebase

- [ ] Firebase Authentication habilitado.
- [ ] Firestore en modo producción.
- [ ] Reglas de `docs/FIRESTORE_RULES_PRODUCTION.rules` publicadas.
- [ ] Usuarios de prueba creados.

## Día de deployment

1. Congelar cambios no críticos.
2. Ejecutar suite local.
3. Hacer merge a `main`.
4. Verificar GitHub Actions.
5. Ejecutar smoke tests con token válido.
6. Validar logs de Cloud Run durante 30 minutos.
7. Monitorear costos y errores de proveedores IA.

## Rollback

```bash
gcloud run revisions list --service ari-backend --region us-central1

gcloud run services update-traffic ari-backend \
  --region us-central1 \
  --to-revisions <REVISION_ANTERIOR>=100
```

## Criterios de éxito

- Login funciona en plataformas objetivo.
- Chat responde usando Cloud Run.
- Fallback local funciona si Cloud Run falla.
- Plan PayPal se activa solo después de validación server-side.
- No hay secretos expuestos en logs, builds ni repositorio.
