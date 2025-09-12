@echo off
echo ================================================
echo 🚀 DEBUGGING DROPDOWNS VACÍOS
echo ================================================
echo.
echo 1. Abriendo navegador en página de crear producto...
echo 2. Mira los logs en consola de Flutter
echo 3. Verifica si aparece la vista de debug
echo.
start chrome "http://localhost:7000/#/products/create"
echo.
echo 📝 INSTRUCCIONES:
echo - Si ves una pantalla roja con "DEBUG: PROBLEMA CON DATOS" = PROBLEMA ENCONTRADO
echo - Si ves dropdowns normales = TODO FUNCIONA
echo - Si ves loading infinito = ERROR EN CARGA
echo.
echo 💡 Revisa los logs de Flutter en la terminal para ver detalles específicos
echo.
pause