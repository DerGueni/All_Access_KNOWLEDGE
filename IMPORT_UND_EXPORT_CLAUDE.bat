@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo   CONSYS - Claude Export Tool
echo   Importiert VBA-Modul und fuehrt Export aus
echo ====================================================
echo.

cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE"

echo Starte Import und Export...
cscript //nologo "08_Tools\vbs\ImportAndRunClaudeExport.vbs"

echo.
echo ====================================================
echo   FERTIG - Pruefe exports\ Ordner
echo ====================================================
echo.
pause
