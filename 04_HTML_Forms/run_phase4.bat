@echo off
chcp 65001 >nul
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo ========================================
echo Auto Claude - btnMail Phase 4
echo MD5-Hash und URL-Generierung
echo ========================================
echo.

"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" ^
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" ^
--task "Phase 4 von btnMail Implementierung: Implementiere MD5-Hash und URL-Generierung in frm_MA_VA_Schnellauswahl.logic.js. (1) Funktion createMD5Hash(text) die einen MD5-Hash erzeugt - nutze crypto-js Library oder Web Crypto API mit Fallback. (2) Funktion createAnfrageUrls(md5, maId, vaId, vaDatumId, vaStartId, dienstkleidung) die zwei URLs zurueckgibt: urlJa fuer Zusage mit ZUSAGE=1 und urlNein fuer Absage mit ZUSAGE=0. Basis-URL: http://noreply.consec-security.selfhost.eu/mail/index.php. Parameter: md5hash, MA_ID, VA_ID, VADatum_ID, VAStart_ID, dress, ZUSAGE. Leerzeichen durch Unterstriche ersetzen. Referenz: VBA Funktionen FnsCalculateMD5 und create_URL in zmd_Mail.bas." ^
--complexity standard ^
--no-ai-assessment ^
--project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] Phase 4 erfolgreich abgeschlossen
    echo Starte Phase 5...
    call "%~dp0run_phase5.bat"
) else (
    echo [FEHLER] Phase 4 fehlgeschlagen - Code: %ERRORLEVEL%
    pause
)
