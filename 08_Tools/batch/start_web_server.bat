@echo off
echo ============================================
echo CONSYS Web-Interface Starter
echo ============================================
echo.

REM Pruefe ob Python installiert ist
python --version >nul 2>&1
if errorlevel 1 (
    echo FEHLER: Python ist nicht installiert oder nicht im PATH
    echo Bitte Python von https://www.python.org installieren
    pause
    exit /b 1
)

REM Pruefe/Installiere Abhaengigkeiten
echo Pruefe Abhaengigkeiten...
pip show flask >nul 2>&1
if errorlevel 1 (
    echo Installiere Flask...
    pip install flask flask-cors pyodbc
)

echo.
echo ============================================
echo Starte API Server auf http://localhost:5000
echo ============================================
echo.
echo Oeffne im Browser: http://localhost:5000
echo.
echo Druecke Strg+C zum Beenden
echo ============================================
echo.

cd /d "%~dp0"
python api_server.py

pause
