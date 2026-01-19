@echo off
REM START_QUICK_TEST.bat - Schneller Test des Servers

setlocal
cd /d "%~dp0"
cls

echo.
echo ╔════════════════════════════════════════════════╗
echo ║          Quick API Server TEST                ║
echo ╚════════════════════════════════════════════════╝
echo.

REM Prüfe Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python nicht installiert
    pause
    exit /b 1
)

REM Installiere Flask falls nötig
python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo Installing Flask...
    pip install flask --quiet
)

REM Starte Server
echo [*] Starte Quick API Server...
echo [*] Öffne: http://localhost:5000/shell.html in 3 Sekunden
echo.

start "CONSYS Quick API" python quick_api_server.py
timeout /t 3 /nobreak

REM Öffne Browser
start "" "http://localhost:5000/shell.html"

echo [✓] Server läuft
echo [✓] Browser öffnet sich
echo.
echo Drücke eine Taste zum Beenden...
pause

REM Beende Server
taskkill /F /FI "WINDOWTITLE eq CONSYS Quick API" >nul 2>&1
