@echo off
REM START_VBA_BRIDGE.bat - Startet VBA Bridge Server

setlocal
cd /d "%~dp0"

echo.
echo ============================================
echo CONSYS VBA Bridge Server
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
python -c "import win32com" >nul 2>&1
if errorlevel 1 (
    echo Installing win32com...
    pip install pywin32 --quiet
)

echo [*] Pruefe Access...
python -c "import win32com.client; access = win32com.client.GetObject(Class='Access.Application'); print('[OK] Access laeuft')" 2>nul
if errorlevel 1 (
    echo 00! FEHLER: Access laeuft nicht!
    echo Bitte oeffnen Sie zuerst das Access Frontend
    pause
    exit /b 1
)

echo [*] Starte VBA Bridge Server...
echo [*] Server läuft auf http://localhost:5002
echo.
echo Drücke Ctrl+C um zu beenden
echo.

python vba_bridge_server.py
