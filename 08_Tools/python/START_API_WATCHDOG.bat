@echo off
REM =========================================
REM API Server Watchdog Starter
REM =========================================
REM Startet den API-Server mit automatischem
REM Neustart bei Crash/Absturz
REM =========================================

cd /d "%~dp0"

echo.
echo =============================================
echo   CONSYS API Server Watchdog
echo =============================================
echo.
echo Der Watchdog ueberwacht den API-Server und
echo startet ihn automatisch bei Crash/Absturz.
echo.
echo Zum Beenden: Ctrl+C druecken
echo.
echo =============================================
echo.

python api_server_watchdog.py

pause
