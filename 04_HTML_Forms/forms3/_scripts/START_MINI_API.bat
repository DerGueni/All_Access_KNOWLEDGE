@echo off
REM START_MINI_API.bat - Startet mini_api.py mit echter Access-Datenbank

setlocal
cd /d "%~dp0"

echo.
echo ============================================
echo CONSYS Mini API Server
echo ============================================
echo.

REM Prüfe Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ FEHLER: Python nicht installiert
    pause
    exit /b 1
)

REM Installiere Packages falls nötig
python -c "import pyodbc" >nul 2>&1
if errorlevel 1 (
    echo Installing pyodbc...
    pip install pyodbc flask waitress --quiet
)

REM Starte mini_api.py
echo [*] Starte mini_api.py...
echo [*] Verbinde mit echte Access-Datenbank...
echo [*] Server läuft auf http://localhost:5000
echo.
echo Drücke Ctrl+C um zu beenden
echo.

python mini_api.py
