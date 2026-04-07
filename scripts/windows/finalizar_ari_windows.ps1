# Finalización ARI Mobile en Windows (PowerShell)
# Ejecutar desde terminal integrada de VS Code.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '== 1) Ir al proyecto =='
Set-Location 'C:\Users\COMPUTADORA\ari-mobile'

Write-Host '== 2) Reparar PATH para sesión actual =='
$env:Path += ';C:\Users\COMPUTADORA\AppData\Local\Pub\Cache\bin;C:\flutter\bin'

Write-Host '== 3) Reconstruir carpeta Android si falta =='
if (-not (Test-Path '.\android')) {
  try {
    flutter create --platforms=android .
  } catch {
    & 'C:\flutter\bin\flutter.bat' create --platforms=android .
  }
}

Write-Host '== 4) Instalar flutterfire_cli (si falta) =='
dart pub global activate flutterfire_cli

Write-Host '== 5) Configurar Firebase (interactivo) =='
flutterfire configure

Write-Host '== 6) Licencias Android y ADB =='
flutter doctor --android-licenses
$adb = 'C:\Program Files\Android\Android SDK\platform-tools\adb.exe'
& $adb kill-server
& $adb start-server
& $adb devices -l

Write-Host '== 7) Dependencias y ejecución =='
flutter clean
flutter pub get
flutter run --dart-define=OPENAI_API_KEY=sk-tu_clave_real_aqui
