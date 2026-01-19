@echo off
REM ============================================
REM CONSYS API Server - Auto-Start Script
REM Startet den Flask API-Server für HTML-Formulare
REM ============================================

title CONSYS API Server

REM Prüfe ob Server bereits läuft
netstat -an | find "5000" | find "LISTENING" >nul
if %errorlevel%==0 (
    echo API-Server läuft bereits auf Port 5000
    exit /b 0
)

echo ============================================
echo CONSYS API Server wird gestartet...
echo ============================================

REM Wechsle ins Verzeichnis
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"

REM Starte Python Server
echo Starte Flask-Server auf http://localhost:5000
python api_server.py

REM Falls Server beendet wird
echo.
echo API-Server wurde beendet.
pause
