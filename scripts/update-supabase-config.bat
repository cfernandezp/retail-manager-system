@echo off
echo 🔄 Actualizando configuración dinámica de Supabase...

cd /d "%~dp0\.."

echo.
echo 📋 Obteniendo estado actual de Supabase...
supabase status

echo.
echo 🔍 Verificando configuración JSON...
supabase status --output json

echo.
echo ✅ Configuración actualizada. La aplicación detectará los nuevos puertos automáticamente.
echo.
echo 💡 Sugerencia: Si la app ya está ejecutándose, haz hot reload (R) para aplicar cambios.
echo.

pause