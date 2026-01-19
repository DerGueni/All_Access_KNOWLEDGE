@echo off
REM VBA Bridge Server starten auf Port 5002
REM Ermöglicht HTML-Formularen den Aufruf von VBA-Funktionen

cd /d "%~dp0"
echo ========================================
echo VBA Bridge Server - Port 5002
echo ========================================
echo.
echo WICHTIG: Access muss bereits geöffnet sein!
echo Frontend: 0_Consys_FE_Test.accdb
echo.
echo Starte Server...
python vba_bridge_server.py
pause
