@echo off
REM ====================================================================
REM Access Bridge VOLLAUTOMATISCH - Schnellstart
REM ====================================================================

title Access Bridge - Vollautomatisch

:MENU
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo   ACCESS BRIDGE - VOLLAUTOMATISCH
echo   Automatische Dialog-Behandlung
echo ═══════════════════════════════════════════════════════════════
echo.
echo   [1] Installation starten
echo   [2] Test ausfuhren
echo   [3] Python-Bridge Demo
echo   [4] PowerShell-Bridge Demo
echo   [5] Dokumentation offnen
echo   [6] Config bearbeiten
echo.
echo   [0] Beenden
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

set /p choice="Ihre Wahl: "

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto TEST
if "%choice%"=="3" goto PYTHON_DEMO
if "%choice%"=="4" goto POWERSHELL_DEMO
if "%choice%"=="5" goto DOCS
if "%choice%"=="6" goto CONFIG
if "%choice%"=="0" goto END

echo Ungultige Eingabe!
timeout /t 2 >nul
goto MENU

:INSTALL
cls
echo.
echo [INSTALLATION]
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0install_auto_bridge.ps1"
pause
goto MENU

:TEST
cls
echo.
echo [VOLLSTANDIGER TEST]
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0test_auto_bridge.ps1"
pause
goto MENU

:PYTHON_DEMO
cls
echo.
echo [PYTHON-BRIDGE DEMO]
echo.
python -c "import sys; sys.path.insert(0, r'%~dp0'); from access_bridge_auto import AccessBridge; bridge = AccessBridge(); print('✓ Bridge gestartet!'); info = bridge.get_database_info(); print(f'\nTabellen: {info[\"tables_count\"]}'); print(f'Formulare: {info[\"forms_count\"]}'); print(f'Watchdog: {\"AKTIV\" if info[\"watchdog_active\"] else \"INAKTIV\"}'); bridge.disconnect(); print('\n✓ Bridge beendet')"
echo.
pause
goto MENU

:POWERSHELL_DEMO
cls
echo.
echo [POWERSHELL-BRIDGE DEMO]
echo.
powershell -ExecutionPolicy Bypass -Command "Import-Module '%~dp0bridge_auto.ps1'; $bridge = New-AccessBridgeAuto; Write-Host ''; Write-Host '✓ Bridge gestartet!' -ForegroundColor Green; Write-Host 'Frontend:' $bridge.FrontendPath; Write-Host 'Verbunden:' $bridge.IsConnected; Write-Host ''; Disconnect-AccessBridge -Bridge $bridge; Write-Host '✓ Bridge beendet' -ForegroundColor Green"
echo.
pause
goto MENU

:DOCS
start "" "%~dp0README_VOLLAUTOMATISCH.md"
goto MENU

:CONFIG
notepad "%~dp0config.json"
goto MENU

:END
exit
