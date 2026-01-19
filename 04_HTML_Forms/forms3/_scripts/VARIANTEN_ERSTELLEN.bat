@echo off
chcp 65001 >nul
cls
echo.
echo ========================================================================
echo   Design-Varianten Generator für frm_va_Auftragstamm.html
echo ========================================================================
echo.
echo Starte Python-Script...
echo.

python "%~dp0create_design_variants.py"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================================
    echo   ERFOLGREICH!
    echo ========================================================================
    echo.
    echo Die Varianten wurden erstellt im Ordner:
    echo   varianten_auftragstamm\
    echo.
    echo Dateien:
    echo   - variante_07_minimalist.html
    echo   - variante_08_nord.html
    echo.
) else (
    echo.
    echo ========================================================================
    echo   FEHLER!
    echo ========================================================================
    echo.
    echo Das Python-Script konnte nicht ausgeführt werden.
    echo Bitte prüfen Sie:
    echo   1. Ist Python installiert? (python --version)
    echo   2. Existiert die Datei create_design_variants.py?
    echo.
)

echo Drücken Sie eine Taste zum Beenden...
pause >nul
