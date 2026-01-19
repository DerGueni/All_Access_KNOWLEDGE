@echo off
chcp 65001 >nul
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo ========================================
echo Auto Claude - btnMail Phase 6
echo E-Mail-Versand (mailto Fallback)
echo ========================================
echo.

"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" ^
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" ^
--task "Phase 6 von btnMail Implementierung: Implementiere E-Mail-Versand in frm_MA_VA_Schnellauswahl.logic.js. (1) Funktion sendAnfrageEmail(email, subject, htmlBody) mit zwei Modi: (a) Primaer: Bridge.execute sendEmail falls Backend verfuegbar, (b) Fallback: mailto-Link oeffnen mit window.open. (2) Fuer mailto: Subject und Body URL-encodieren, HTML-Tags fuer Plain-Text entfernen. (3) Funktion checkEmailCapability() die prueft ob Backend-Email verfuegbar ist. (4) Bei mailto-Fallback: Warnung anzeigen dass E-Mails manuell gesendet werden muessen. Betreff-Format: CONSEC Anfrage zu [Auftrag], [Datum] in [Ort]. Referenz: VBA create_Mail und send_Mail in zmd_Mail.bas." ^
--complexity standard ^
--no-ai-assessment ^
--project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] Phase 6 erfolgreich abgeschlossen
    echo Starte Phase 7...
    call "%~dp0run_phase7.bat"
) else (
    echo [FEHLER] Phase 6 fehlgeschlagen - Code: %ERRORLEVEL%
    pause
)
