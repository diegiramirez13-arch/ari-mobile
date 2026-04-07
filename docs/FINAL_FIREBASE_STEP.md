# Paso final: conectar Firebase realmente (Windows + VS Code)

## Ejecutar en orden

```powershell
cd C:\Users\COMPUTADORA\ari-mobile
dart pub global activate flutterfire_cli
flutterfire configure
```

Durante `flutterfire configure`:
- Seleccioná tu proyecto de Firebase (`ari-mobile`).
- Aceptá opciones por defecto para Android/iOS/Web.
- Confirmá generación de `lib/firebase_options.dart` real.

## Validar entorno de despliegue

```powershell
flutter doctor --android-licenses
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" kill-server
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" start-server
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" devices -l
```

## Correr la app en el Motorola

```powershell
flutter clean
flutter pub get
flutter run --dart-define=OPENAI_API_KEY=sk-tu_clave_real_aqui
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
