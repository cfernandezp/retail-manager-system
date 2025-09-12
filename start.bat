@echo off
@echo off
echo ========================================
echo    INICIANDO PROYECTO RETAIL MANAGER
echo          (PRESERVANDO DATOS)
echo ========================================

echo Matando procesos Flutter existentes...
taskkill /f /im flutter.exe >nul 2>&1
taskkill /f /im dart.exe >nul 2>&1

echo Liberando puerto 8000...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000') do (
    echo Matando proceso %%a en puerto 8000
    taskkill /f /pid %%a >nul 2>&1
)

echo ========================================
echo INICIANDO SUPABASE (PRESERVANDO DATOS)
echo ========================================
cd /d "%~dp0"

echo Detener Supabase correctamente...
supabase stop

echo Iniciar Supabase preservando datos...
supabase start

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
echo Credenciales preservadas en BD
echo ========================================

cd build\web
npx http-server -p 8000 -c-1 -o

pause