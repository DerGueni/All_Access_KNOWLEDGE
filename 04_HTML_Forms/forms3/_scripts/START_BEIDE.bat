@echo off
title forms3 Server starten
cd /d "%~dp0"

echo ============================================
echo forms3 Server werden gestartet...
echo ============================================
echo.

REM Starte API-Server in neuem Fenster
start "Mini API Server" cmd /k "cd /d %~dp0 && python mini_api.py"

REM Warte kurz
timeout /t 2 /nobreak >nul

REM Starte HTTP-Server in neuem Fenster
start "HTTP Server" cmd /k "cd /d %~dp0 && python -m http.server 8080"

REM Warte bis Server bereit
timeout /t 2 /nobreak >nul

echo.
echo Server gestartet!
echo.
echo API-Server:  http://localhost:5000
echo HTTP-Server: http://localhost:8080
echo.
echo Oeffne Browser...

REM Oeffne Browser mit Auftragstamm
start "" "http://localhost:8080/frm_va_Auftragstamm.html"

echo.
echo Zum Beenden beide CMD-Fenster schliessen.
