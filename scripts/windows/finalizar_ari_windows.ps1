# Finalización ARI Mobile en Windows (PowerShell)
# Ejecutar desde terminal integrada de VS Code.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '== 1) Ir al proyecto =='
Set-Location 'C:\Users\COMPUTADORA\ari-mobile'

Write-Host '== 2) Reparar PATH para sesión actual =='
$env:Path += ';C:\flutter\bin;C:\Users\COMPUTADORA\AppData\Local\Pub\Cache\bin'

Write-Host '== 3) Reconstruir carpeta Android si falta =='
if (-not (Test-Path '.\android') -or -not (Test-Path '.\web')) {
  try {
    flutter create --platforms=android,web .
  } catch {
    & 'C:\flutter\bin\flutter.bat' create --platforms=android,web .
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

Write-Host '== 8) (Opcional) Previsualización en Chrome =='
flutter run -d chrome --dart-define=OPENAI_API_KEY=tu_clave_aqui
