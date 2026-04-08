# Paso final: conectar Firebase realmente (Windows + VS Code)

## Paso A: reparar PATH (PowerShell actual)

```powershell
$env:Path += ";C:\Users\COMPUTADORA\AppData\Local\Pub\Cache\bin;C:\flutter\bin"
```

## Paso B: reconstruir carpetas Android + Web (si faltan)

```powershell
flutter create --platforms=android,web .
```

Si falla por PATH:

```powershell
C:\flutter\bin\flutter.bat create --platforms=android,web .
```

## Paso C: configurar Firebase de verdad

```powershell
cd C:\Users\COMPUTADORA\ari-mobile
dart pub global activate flutterfire_cli
flutterfire configure
```

Durante `flutterfire configure`:
- Seleccioná tu proyecto de Firebase (`ari-mobile`).
- Aceptá opciones por defecto para Android/iOS/Web.
- Confirmá generación de `lib/firebase_options.dart` real.

En `flutterfire configure`, seleccioná el proyecto `ari-mobile`, elegí al menos `android` y `web`, y aceptá los defaults.

## Paso D: validar entorno de despliegue

```powershell
flutter doctor --android-licenses
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" kill-server
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" start-server
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" devices -l
```

## Paso E: correr la app en el Motorola

```powershell
flutter clean
flutter pub get
flutter run --dart-define=OPENAI_API_KEY=sk-tu_clave_real_aqui
```

## Paso F: previsualización rápida en Chrome

```powershell
flutter run -d chrome --dart-define=OPENAI_API_KEY=tu_clave_aqui
```

## Checklist MVP funcional

- Login con Firebase Auth.
- Persistencia de chat/proyectos en Firestore por usuario.
- Modo Básico sin API key.
- Modo Pro si `OPENAI_API_KEY` está definida.
- Navegación chat/proyectos/perfil.

## Script opcional automatizado

También podés ejecutar el script:

```powershell
./scripts/windows/finalizar_ari_windows.ps1
```
