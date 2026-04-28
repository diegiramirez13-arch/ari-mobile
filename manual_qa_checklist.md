# QA Checklist - ARI Chat

## Preparación
- [ ] Limpiar caché: `flutter clean && flutter pub get`
- [ ] Ejecutar: `flutter run`

## Caso 1: Sin API Key (Modo Básico)
- [ ] Iniciar sin `OPENAI_API_KEY`
- [ ] Verificar: Banner naranja "Modo IA no disponible"
- [ ] Verificar: Badge gris "BÁSICO"
- [ ] Enviar mensaje: Respuesta inmediata (< 1s)
- [ ] Verificar: No hay ícono de ⚡ en AppBar
- [ ] Enviar 5 mensajes: Verificar rotación de respuestas

## Caso 2: Con API Key (Modo Pro)
- [ ] Setear: `export OPENAI_API_KEY=sk-...`
- [ ] Reiniciar app
- [ ] Verificar: No hay banner naranja
- [ ] Verificar: Badge inicial "PRO" (o toggle a Pro)
- [ ] Verificar: Ícono ⚡ dorado en AppBar
- [ ] Enviar mensaje: Verificar "ARI está pensando..."
- [ ] Verificar: Respuesta de IA real (3-10s)
- [ ] Verificar: Respuestas en español rioplatense

## Caso 3: Toggle Modo
- [ ] En Pro, tocar ⚡
- [ ] Verificar: Mensaje "Modo cambiado a: Básico"
- [ ] Enviar mensaje: Respuesta rápida (básica)
- [ ] Volver a Pro: Verificar respuesta de IA

## Caso 4: Errores
- [ ] Desconectar internet (modo Pro)
- [ ] Enviar mensaje: Verificar mensaje de error
- [ ] Verificar: Botón X para cerrar error
- [ ] Reconectar: Verificar recuperación

## Caso 5: Ciclo de Vida UI
- [ ] Enviar 20 mensajes: Verificar auto-scroll
- [ ] Durante carga: Verificar botón deshabilitado
- [ ] Rotar pantalla: Verificar estado preservado
- [ ] Background/foreground: Verificar no crash
- [ ] Clear chat: Verificar reset a mensaje inicial

## Caso 6: Input
- [ ] Enviar con botón
- [ ] Enviar con tecla Enter (soft keyboard)
- [ ] Intentar enviar vacío: No debe pasar nada
- [ ] Escribir durante carga: Input debe estar habilitado
- [ ] Focus: Al enviar, focus vuelve al input

## Evidencia recomendada
- [ ] Capturas de pantalla por caso clave (inicio básico, modo Pro, error y clear chat)
- [ ] Registro de entorno probado (`ENV`, dispositivo/emulador, versión app)
- [ ] Si falla: adjuntar pasos de reproducción + logs y crear issue `qa-failed`

## Resultado
- [ ] Todos los casos pasan → ✅ Listo para prod
- [ ] Algún fallo → Crear issue con label `qa-failed`
