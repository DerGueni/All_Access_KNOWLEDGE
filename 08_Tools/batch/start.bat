@echo off
REM Access Bridge - Windows Starter
REM Startet die Access Bridge mit verschiedenen Optionen

title Access Bridge

:MENU
cls
echo.
echo ================================================================
echo                    ACCESS BRIDGE - MENU
echo ================================================================
echo.
echo   1. Setup ausfuehren
echo   2. Demo starten
echo   3. Interaktives Python-Menu
echo   4. PowerShell-Interface
echo   5. CONSEC-Helpers Demo
echo   6. Python-Console mit Bridge
echo.
echo   Q. Beenden
echo.
echo ================================================================

set /p choice="Wahl: "

if /i "%choice%"=="1" goto SETUP
if /i "%choice%"=="2" goto DEMO
if /i "%choice%"=="3" goto INTERACTIVE
if /i "%choice%"=="4" goto POWERSHELL
if /i "%choice%"=="5" goto CONSEC
if /i "%choice%"=="6" goto CONSOLE
if /i "%choice%"=="Q" goto END

echo Ungueltige Eingabe!
timeout /t 2 >nul
goto MENU

:SETUP
cls
echo Starte Setup...
python setup.py
pause
goto MENU

:DEMO
cls
echo Starte Demo...
python quick_start.py --demo
pause
goto MENU

:INTERACTIVE
cls
echo Starte interaktives Menu...
python quick_start.py --interactive
pause
goto MENU

:POWERSHELL
cls
echo Starte PowerShell-Interface...
powershell -ExecutionPolicy Bypass -File bridge.ps1
pause
goto MENU

:CONSEC
cls
echo Starte CONSEC-Helpers...
python consec_helpers.py
pause
goto MENU

:CONSOLE
cls
echo Starte Python-Console mit Access Bridge...
echo.
echo Beispiel-Code:
echo   from access_bridge import AccessBridge
echo   bridge = AccessBridge("pfad/zur/db.accdb")
echo   tables = bridge.list_tables()
echo   print(tables)
echo.
pause
python -i -c "from access_bridge import AccessBridge; from access_helpers import AccessHelper; from consec_helpers import ConsecHelper; print('Bridge-Module geladen!')"
goto MENU

:END
echo.
echo Auf Wiedersehen!
timeout /t 2 >nul
exit
