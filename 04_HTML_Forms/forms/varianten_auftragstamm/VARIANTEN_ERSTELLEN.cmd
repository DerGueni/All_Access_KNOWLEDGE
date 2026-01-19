@echo off
REM === Design-Varianten erstellen ===
REM Doppelklick auf diese Datei um die Varianten zu erstellen

echo.
echo ===============================================
echo   Auftragstamm Design-Varianten erstellen
echo ===============================================
echo.

cd /d "%~dp0"

REM Pruefe ob Python verfuegbar ist
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Python gefunden - verwende Python-Script
    python create_variants.py
) else (
    echo [INFO] Python nicht gefunden - verwende PowerShell
    powershell -ExecutionPolicy Bypass -File "create_variants.ps1"
)

echo.
echo ===============================================
echo   FERTIG!
echo ===============================================
echo.
echo Die Varianten wurden erstellt:
echo   - variante_05_dark_mode.html
echo   - variante_06_enterprise.html
echo.
echo Oeffnen Sie die Dateien im Browser zum Testen.
echo.

pause
