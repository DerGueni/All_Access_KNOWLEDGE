@echo off
REM ============================================
REM CONSYS HTTP Server - Fuer HTML-Formulare
REM Startet einen lokalen HTTP-Server auf Port 8080
REM ============================================

title CONSYS HTTP Server (Port 8080)

REM Prüfe ob Server bereits läuft
netstat -an | find "8080" | find "LISTENING" >nul
if %errorlevel%==0 (
    echo HTTP-Server läuft bereits auf Port 8080
    exit /b 0
)

echo ============================================
echo CONSYS HTTP Server wird gestartet...
echo http://localhost:8080
echo ============================================

cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

REM Starte Python HTTP Server
python -m http.server 8080

echo.
echo HTTP-Server wurde beendet.
pause
