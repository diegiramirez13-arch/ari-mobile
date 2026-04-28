# Debug ADB/Flutter en Windows 10 Enterprise 2016 (1607)

Guía práctica para cuando `flutter doctor` muestra errores al ejecutar:

`C:\Program Files\Android\Android SDK\platform-tools\adb.exe`

> Caso objetivo: Motorola G30 por USB + VS Code en Windows.

## 1) Diagnóstico rápido: ruta, permisos, arquitectura

Abrí **PowerShell** como usuario normal (y si falla, repetí en **Administrador**) y ejecutá:

```powershell
# Confirmar qué Flutter está primero en PATH
where.exe flutter

# Confirmar ADB de Android SDK
$adb = "C:\Program Files\Android\Android SDK\platform-tools\adb.exe"
Test-Path $adb
Get-Item $adb | Format-List FullName,Length,CreationTime,LastWriteTime

# Ver versión de adb y si puede ejecutarse
& $adb version

# Ver variables clave
[Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "Machine")
[Environment]::GetEnvironmentVariable("ANDROID_HOME", "Machine")
$env:Path -split ';' | Select-String -Pattern 'Android|platform-tools|flutter'

# Validar arquitectura del SO
wmic os get osarchitecture
```

### Qué mirar
- Si `where.exe flutter` devuelve varias rutas, hay instalación duplicada/conflictiva.
- Si `& $adb version` falla con error de ejecución/permisos, puede ser:
  - políticas de seguridad (Defender/AppLocker/EDR),
  - SDK corrupto,
  - incompatibilidad binaria con entorno viejo.

---

## 2) Reinicio completo de ADB + detección del Motorola G30

```powershell
$adb = "C:\Program Files\Android\Android SDK\platform-tools\adb.exe"

& $adb kill-server
Start-Sleep -Seconds 1
& $adb start-server
Start-Sleep -Seconds 1
& $adb devices -l
```

Si aparece `unauthorized`:
1. Desconectá y reconectá USB.
2. En el teléfono: activar **Depuración USB**.
3. Aceptar huella RSA en el teléfono.
4. Repetir `& $adb devices -l`.

---

## 3) Revisar permisos de archivo/carpeta (Windows)

```powershell
$adb = "C:\Program Files\Android\Android SDK\platform-tools\adb.exe"

# ACL del ejecutable
Get-Acl $adb | Format-List

# Quitar marca de archivo descargado (si aplica)
Unblock-File -Path $adb

# Verificar carpeta completa
Get-Acl "C:\Program Files\Android\Android SDK\platform-tools" | Format-List
```

Si hay bloqueo por seguridad corporativa, pedí excepción para:
- `adb.exe`
- `fastboot.exe`
- `flutter.bat`
- `java.exe` / `gradle` (según políticas).

---

## 4) SDK 36.1.0 en Windows 10 1607: cómo validar si está afectando

En sistemas viejos (como 1607), algunas toolchains nuevas pueden dar problemas.

```powershell
$adb = "C:\Program Files\Android\Android SDK\platform-tools\adb.exe"
& $adb version

# Mostrar paquetes instalados (si sdkmanager está disponible)
$sdkm = "C:\Program Files\Android\Android SDK\cmdline-tools\latest\bin\sdkmanager.bat"
if (Test-Path $sdkm) { & $sdkm --list }
```

Si ADB no ejecuta correctamente, probá reinstalar **solo** `platform-tools` desde Android Studio SDK Manager.

---

## 5) Librerías de C++ (Visual C++ Redistributable)

Si `adb.exe` o herramientas Android fallan al abrir, instalá/repair:
- **Microsoft Visual C++ Redistributable 2015-2022 (x64 y x86)**.

Chequeo básico por registro:

```powershell
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes" -ErrorAction SilentlyContinue |
  ForEach-Object {
    Get-ItemProperty $_.PSPath |
      Select-Object PSChildName, Version, Installed
  }
```

---

## 6) Limpieza de “fantasmas” en VS Code (paso a paso)

Ejecutá uno por uno:

```powershell
# 1) Ver Flutter activo
where.exe flutter

# 2) Licencias Android
flutter doctor --android-licenses

# 3) Reiniciar ADB
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" kill-server
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" start-server
& "C:\Program Files\Android\Android SDK\platform-tools\adb.exe" devices -l
```

---

## 7) Puesta a punto del proyecto ARI

```powershell
flutter clean
flutter pub get
flutterfire configure
```

> En `flutterfire configure`, asegurate de incluir **Android** (no solo Web).

---

## 8) Lanzamiento final

```powershell
flutter run --dart-define=OPENAI_API_KEY=tu_clave_real_de_openai
```

---

## 9) Comando “todo en uno” para diagnóstico (opcional)

```powershell
$adb = "C:\Program Files\Android\Android SDK\platform-tools\adb.exe"
Write-Host "== FLUTTER EN PATH =="
where.exe flutter
Write-Host "`n== FLUTTER DOCTOR =="
flutter doctor -v
Write-Host "`n== ADB VERSION =="
& $adb version
Write-Host "`n== ADB DEVICES =="
& $adb kill-server
Start-Sleep -Seconds 1
& $adb start-server
& $adb devices -l
```

Si querés, el siguiente paso es que me pegues la salida de este bloque y te digo exactamente si el problema principal es permisos, SDK o runtimes de C++.
