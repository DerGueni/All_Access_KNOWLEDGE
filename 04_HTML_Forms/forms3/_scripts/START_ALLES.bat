@echo off
REM START_ALLES.bat - Startet ALLES automatisch mit QUICK API Server

setlocal enabledelayedexpansion
title CONSYS - Vollständiger Start
cls

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║        CONSYS HTML-FORMULARE - VOLLSTÄNDIGER START    ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM ============================================
REM SCHRITT 1: Prüfe Vorbedingungen
REM ============================================
echo [1/4] Prüfe Vorbedingungen...

python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ FEHLER: Python nicht installiert
    pause
    exit /b 1
)
echo ✅ Python OK

REM ============================================
REM SCHRITT 2: Installiere Packages
REM ============================================
echo [2/4] Installiere Python Packages...

python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo Installing Flask...
    pip install flask --quiet >nul 2>&1
)
echo ✅ Packages OK

REM ============================================
REM SCHRITT 3: Starte QUICK API Server (Port 5000)
REM ============================================
echo [3/4] Starte Quick API Server (Port 5000)...
cd /d "%~dp0"

start "CONSYS API Server" /min python quick_api_server.py
timeout /t 3 /nobreak

echo ✅ API Server started

REM ============================================
REM SCHRITT 4: Öffne Browser
REM ============================================
echo [4/4] Öffne Browser und Access Frontend...

start "" "http://localhost:5000/shell.html"
echo ✅ Browser öffnet sich

REM Starte Access Frontend (falls vorhanden)
set ACCESS_FILE=..\..\0_Consys_FE_Test.accdb
if exist "%ACCESS_FILE%" (
    start /min "" "%ACCESS_FILE%"
    echo ✅ Access Frontend gestartet
) else (
    echo ⚠️  Access Frontend nicht gefunden
)

REM ============================================
REM FERTIG
REM ============================================
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║           ✅ ALLES ERFOLGREICH GESTARTET!             ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 📊 Services:
echo  • API Server:       http://localhost:5000
echo  • Browser:          http://localhost:5000/shell.html
echo.
echo ℹ️  Der "HTML Ansicht" Button im Access funktioniert jetzt!
echo.
echo ⏹️  Um alles zu beenden: Schließen Sie diese Fenster
echo.
pause
