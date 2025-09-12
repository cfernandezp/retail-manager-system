@echo off
echo ========================================
echo    RECOMPILANDO FLUTTER WEB
echo      (SUPABASE YA INICIADO)
echo ========================================

echo Liberando puerto 8000...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000') do (
    echo Matando proceso %%a en puerto 8000
    taskkill /f /pid %%a >nul 2>&1
)

echo ========================================
echo COMPILANDO FLUTTER PARA WEB
echo ========================================
cd /d "%~dp0retail_manager"

echo Limpiando cache de Flutter...
flutter clean >nul

echo Obteniendo dependencias...
flutter pub get >nul

echo Compilando aplicacion web...
flutter build web

echo ========================================
echo INICIANDO SERVIDOR WEB EN PUERTO 8000
echo ========================================
echo La aplicacion estara disponible en:
echo http://localhost:8000/login
echo ========================================

cd build\web
npx http-server -p 8000 -c-1 -o

pause