@echo off
title HTTP Server - forms3
cd /d "%~dp0"

echo ============================================
echo HTTP Server fuer forms3 HTML-Formulare
echo ============================================
echo.
echo Server: http://localhost:8080
echo.
echo Formulare oeffnen:
echo   http://localhost:8080/frm_va_Auftragstamm.html
echo   http://localhost:8080/frm_MA_Mitarbeiterstamm.html
echo.
echo Druecke Ctrl+C zum Beenden
echo.

python -m http.server 8080

pause
