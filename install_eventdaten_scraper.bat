@echo off
REM Event-Daten Scraper Installation Script
REM Installiert Python-Pakete und prüft Setup

echo ============================================
echo Event-Daten Web-Scraper Installation
echo ============================================
echo.

REM Schritt 1: Python-Pakete installieren
echo [1/3] Installiere Python-Pakete...
echo.
pip install requests beautifulsoup4
echo.

if %errorlevel% neq 0 (
    echo FEHLER: Python-Pakete konnten nicht installiert werden!
    echo Prüfe ob pip installiert ist: pip --version
    pause
    exit /b 1
)

echo [OK] Python-Pakete installiert
echo.

REM Schritt 2: Prüfe ob api_server.py existiert
echo [2/3] Prüfe API Server...
echo.

set API_SERVER_PATH=C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py

if not exist "%API_SERVER_PATH%" (
    echo FEHLER: api_server.py nicht gefunden!
    echo Pfad: %API_SERVER_PATH%
    pause
    exit /b 1
)

echo [OK] API Server gefunden
echo.

REM Schritt 3: Prüfe ob JavaScript Client existiert
echo [3/3] Prüfe JavaScript Client...
echo.

set JS_CLIENT_PATH=C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm_eventdaten.logic.js

if not exist "%JS_CLIENT_PATH%" (
    echo FEHLER: JavaScript Client nicht gefunden!
    echo Pfad: %JS_CLIENT_PATH%
    pause
    exit /b 1
)

echo [OK] JavaScript Client gefunden
echo.

echo ============================================
echo Installation abgeschlossen!
echo ============================================
echo.
echo NÄCHSTE SCHRITTE:
echo.
echo 1. Öffne api_server.py in einem Editor
echo.
echo 2. Füge folgende Imports am Anfang hinzu (nach den anderen Imports):
echo    import requests
echo    from bs4 import BeautifulSoup
echo    from urllib.parse import quote_plus
echo    import re
echo.
echo 3. Füge den Endpoint-Code ein (aus api_server_eventdaten_endpoint.py)
echo    Position: Nach den anderen API-Routen, vor dem Server-Start
echo.
echo 4. Starte API Server neu:
echo    cd "%~dp0..\Access Bridge"
echo    python api_server.py
echo.
echo 5. Teste den Endpoint:
echo    http://localhost:5000/api/eventdaten/123
echo.
echo 6. Integriere JavaScript Client in dein HTML-Formular
echo.
echo Weitere Infos: EVENTDATEN_SCRAPER_INTEGRATION.md
echo.

pause
