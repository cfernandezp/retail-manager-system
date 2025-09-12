@echo off
echo Forcing Flutter hot reload...
echo r | flutter run -d chrome --web-port=6000 --no-pub
pause