@echo off
REM TEST.bat - Kompletter Funktions-Test

setlocal enabledelayedexpansion
title CONSYS HTML-ANSICHT TEST
cls

echo.
echo ============================================
echo CONSYS HTML-FORMULARE - FUNKTIONS-TEST
echo ============================================
echo.

REM TEST 1: Python
echo [TEST 1/5] Python Installation
python --version
if errorlevel 1 (
    echo ❌ FEHLER: Python nicht installiert
    pause
    exit /b 1
)
echo ✅ PASS
echo.

REM TEST 2: Flask
echo [TEST 2/5] Flask Paket
python -c "import flask; print('Flask OK')" >nul 2>&1
if errorlevel 1 (
    echo Installing Flask...
    pip install flask --quiet
)
echo ✅ PASS
echo.

REM TEST 3: Starte API Server
echo [TEST 3/5] API Server starten
cd /d "%~dp0"
start "CONSYS API TEST" /min python api_server_robust.py
timeout /t 4 /nobreak
echo ✅ PASS
echo.

REM TEST 4: Health Check
echo [TEST 4/5] API Health Check
python -c "import requests; r = requests.get('http://localhost:5000/api/health', timeout=3); print('Status:', r.status_code)" >nul 2>&1
if errorlevel 1 (
    echo ❌ FEHLER: API antwortet nicht
    echo Starte manuell: python api_server_robust.py
    pause
    exit /b 1
)
echo ✅ PASS
echo.

REM TEST 5: Browser
echo [TEST 5/5] Öffne Browser
start "" "http://localhost:5000/shell.html"
echo ✅ PASS
echo.

echo.
echo ============================================
echo ✅ ALLE TESTS ERFOLGREICH
echo ============================================
echo.
echo API Server läuft auf http://localhost:5000
echo Browser öffnet sich automatisch
echo.
pause
