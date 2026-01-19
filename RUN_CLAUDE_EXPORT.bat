@echo off
REM ============================================================================
REM RUN_CLAUDE_EXPORT.bat - Startet den Claude Export in Access
REM ============================================================================

echo.
echo ====================================
echo   CONSYS Claude Export Tool
echo ====================================
echo.

set ACCESS_DB=C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb

echo Starte Export...
echo Datenbank: %ACCESS_DB%
echo.

REM Access starten und Makro ausführen
start "" msaccess.exe "%ACCESS_DB%" /x ExportForClaude

echo.
echo Export wurde gestartet.
echo Warte auf Abschluss in Access...
echo.
pause
