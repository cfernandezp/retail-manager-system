@echo off
echo Matando procesos Flutter existentes...
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM chrome.exe /T 2>nul

echo Esperando 2 segundos...
timeout /t 2 /nobreak >nul

echo Iniciando Flutter en puerto 8000...
cd /d "%~dp0.."
flutter run -d chrome --web-port=8000