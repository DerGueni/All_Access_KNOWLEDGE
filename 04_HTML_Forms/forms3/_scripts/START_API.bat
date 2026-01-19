@echo off
title Mini API Server - forms3
cd /d "%~dp0"

echo ============================================
echo Mini API Server fuer forms3 HTML-Formulare
echo ============================================
echo.

REM Pruefe ob Python verfuegbar ist
python --version >nul 2>&1
if errorlevel 1 (
    echo FEHLER: Python nicht gefunden!
    echo Bitte Python installieren: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Pruefe ob Flask installiert ist
python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo Flask wird installiert...
    pip install flask flask-cors pyodbc
)

echo.
echo Starte Server auf http://localhost:5000
echo Druecke Ctrl+C zum Beenden
echo.

python mini_api.py

pause
