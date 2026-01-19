@echo off
REM =====================================================
REM START ACCESS MIT SERVERN
REM Startet automatisch API-Server und Access
REM =====================================================

echo.
echo ======================================================================
echo CONSYS - ACCESS MIT HTML-FORMULAREN STARTEN
echo ======================================================================
echo.

REM Wechsle zum Script-Verzeichnis
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts"

echo [1/3] Starte API Server (Port 5000)...
echo.

REM Starte API Server im Hintergrund (minimiert)
start /min "CONSYS API Server" python mini_api.py

echo [OK] API Server gestartet im Hintergrund
echo.

echo [2/3] Warte 3 Sekunden bis Server hochgefahren ist...
timeout /t 3 /nobreak >nul
echo [OK] Server sollte jetzt bereit sein
echo.

echo [3/3] Starte Access Frontend...
echo.

REM Starte Access mit Test-Frontend
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"

echo [OK] Access gestartet
echo.
echo ======================================================================
echo [SUCCESS] ALLES GESTARTET!
echo ======================================================================
echo.
echo - API Server laeuft auf Port 5000
echo - Access ist geoeffnet
echo - HTML Formulare sollten funktionieren
echo.
echo Dieses Fenster kann geschlossen werden.
echo ======================================================================
echo.

REM Warte 5 Sekunden bevor Fenster schließt
timeout /t 5 /nobreak
