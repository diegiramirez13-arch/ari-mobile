# 🔐 Checklist de seguridad pre-launch

## Código cliente

- [ ] No hay API keys hardcodeadas.
- [ ] `PAYPAL_SECRET` no se incluye en builds release.
- [ ] La app usa Firebase ID tokens para llamar al backend.
- [ ] Los logs redactan tokens, claves y datos financieros.
- [ ] Las URLs productivas se configuran por entorno.

## Backend Cloud Run

- [ ] `--no-allow-unauthenticated` activo si la API requiere IAM.
- [ ] El backend valida Firebase ID tokens en cada endpoint privado.
- [ ] Secret Manager es la única fuente de secretos productivos.
- [ ] La cuenta de servicio usa permisos mínimos.
- [ ] Rate limiting por usuario/IP habilitado.
- [ ] CORS restringido a dominios esperados.

## Firebase

- [ ] Firestore Rules publicadas en modo producción.
- [ ] Reglas probadas con usuarios autenticados y no autenticados.
- [ ] App Check evaluado para Android/iOS/Web.
- [ ] Métodos de autenticación revisados.
- [ ] Backups/exportaciones programadas si aplica.

## PayPal

- [ ] Transacciones validadas server-side.
- [ ] Webhooks verificados con firma.
- [ ] Sandbox y Live separados por entorno.
- [ ] Idempotencia para activación de planes.
- [ ] No se guardan secretos PayPal en Firestore.

## CI/CD

- [ ] Secretos GitHub protegidos por ambientes.
- [ ] Deploy solo desde `main` o `production`.
- [ ] Smoke test obligatorio después de Cloud Run deploy.
- [ ] Rollback documentado.
- [ ] Dependencias auditadas antes de release.

## Monitoreo

- [ ] Alertas por error rate 5xx.
- [ ] Alertas por latencia p95.
- [ ] Alertas por costos de proveedores IA.
- [ ] Alertas por intentos 401/403 anómalos.
- [ ] Dashboard operativo compartido con el equipo.
