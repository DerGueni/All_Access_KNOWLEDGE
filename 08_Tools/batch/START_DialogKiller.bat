@echo off
REM Dialog Killer starten (versteckt im Hintergrund)
REM Läuft 60 Minuten, prüft alle 30ms

start /B powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0DialogKillerPermanent.ps1" -Minutes 60 -IntervalMs 30

echo Dialog Killer gestartet!
echo Log: %TEMP%\DialogKiller.log
echo.
echo Dieses Fenster kann geschlossen werden.
timeout /t 3 >nul
