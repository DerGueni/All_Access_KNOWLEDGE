@echo off
REM ========================================
REM Automatischer Server-Start einrichten
REM ========================================
REM Installiert Module für automatischen
REM Server-Start beim Access-Öffnen
REM ========================================

echo.
echo ========================================
echo AUTO SERVER START - INSTALLATION
echo ========================================
echo.
echo Folgende Module werden installiert:
echo   - mod_API_Server.bas
echo   - mod_VBA_Bridge.bas (aktualisiert)
echo   - mdlAutoexec.bas (aktualisiert)
echo.
echo Server starten dann automatisch:
echo   - API Server (Port 5000)
echo   - VBA Bridge (Port 5002)
echo.
pause

cd /d "%~dp0\01_VBA"
python import_server_modules.py

echo.
echo ========================================
echo INSTALLATION ABGESCHLOSSEN
echo ========================================
echo.
echo Naechste Schritte:
echo   1. Access-Frontend schliessen
echo   2. Access-Frontend neu oeffnen
echo   3. Server starten automatisch
echo.
pause
