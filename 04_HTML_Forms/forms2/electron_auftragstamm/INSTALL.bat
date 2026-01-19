@echo off
echo ========================================
echo CONSYS Auftragsverwaltung - Installation
echo ========================================
echo.

cd /d "%~dp0"

echo Pruefe Node.js...
node -v >nul 2>&1
if errorlevel 1 (
    echo FEHLER: Node.js ist nicht installiert!
    echo Bitte installieren Sie Node.js von https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js gefunden.
echo.
echo Installiere Abhaengigkeiten...
echo.

call npm install

if errorlevel 1 (
    echo.
    echo FEHLER bei npm install!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation erfolgreich!
echo ========================================
echo.
echo Starten mit: npm start
echo Oder Doppelklick auf START_APP.bat
echo.
pause
