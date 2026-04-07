# Finalización ARI Mobile en Windows (PowerShell)
# Ejecutar desde terminal integrada de VS Code.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '== 1) Ir al proyecto =='
Set-Location 'C:\Users\COMPUTADORA\ari-mobile'

Write-Host '== 2) Instalar flutterfire_cli (si falta) =='
dart pub global activate flutterfire_cli

Write-Host '== 3) Configurar Firebase (interactivo) =='
flutterfire configure

Write-Host '== 4) Licencias Android y ADB =='
flutter doctor --android-licenses
$adb = 'C:\Program Files\Android\Android SDK\platform-tools\adb.exe'
& $adb kill-server
& $adb start-server
& $adb devices -l

Write-Host '== 5) Dependencias y ejecución =='
flutter clean
flutter pub get
flutter run --dart-define=OPENAI_API_KEY=sk-tu_clave_real_aqui
