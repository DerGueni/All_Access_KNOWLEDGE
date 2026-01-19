@echo off
title CONSEC API Server Neustart
color 0A
echo.
echo ========================================
echo   CONSEC API Server wird neu gestartet
echo ========================================
echo.

REM Python-Prozesse beenden
echo [1/3] Stoppe Python-Prozesse...
taskkill /F /IM python.exe 2>nul
if %errorlevel%==0 (
    echo       Prozesse gestoppt.
) else (
    echo       Keine Prozesse gefunden.
)

timeout /t 2 /nobreak >nul

REM Verzeichnis wechseln
echo [2/3] Wechsle Verzeichnis...
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"

REM Server starten
echo [3/3] Starte API-Server...
start "CONSEC API Server" cmd /k "python api_server.py"

echo.
echo ========================================
echo   API-Server wird gestartet...
echo ========================================
echo.
echo Server: http://localhost:5000
echo Email:  http://localhost:5000/api/email/send
echo.

timeout /t 5 /nobreak >nul

REM Testen
echo Teste API-Verbindung...
curl -s http://localhost:5000/ >nul 2>&1
if %errorlevel%==0 (
    echo.
    echo [OK] API-Server laeuft!
    echo.
) else (
    echo.
    echo [INFO] Server startet noch... Bitte warten.
    echo.
)

echo Dieses Fenster schliesst sich in 10 Sekunden...
timeout /t 10
