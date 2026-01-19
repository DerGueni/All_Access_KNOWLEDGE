@echo off
chcp 65001 >nul
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo ========================================
echo Auto Claude - btnMail Phase 5
echo E-Mail-Body-Generierung
echo ========================================
echo.

"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" ^
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" ^
--task "Phase 5 von btnMail Implementierung: Erstelle E-Mail-Template und Body-Generierung. (1) Erstelle forms3/templates/email_anfrage_template.js mit HTML-Template fuer Mitarbeiter-Anfrage. Das Template soll professionell aussehen mit CONSEC Branding, Buttons fuer Zusage (gruen) und Absage (rot), und alle Auftragsinformationen enthalten. (2) Implementiere Funktion createEmailBody(templateData) in frm_MA_VA_Schnellauswahl.logic.js die Platzhalter ersetzt: [A_URL_JA], [A_URL_NEIN], [A_Auftr_Datum], [A_Auftrag], [A_Ort], [A_Objekt], [A_Start_Zeit], [A_End_Zeit], [A_Treffpunkt], [A_Treffp_Zeit], [A_Dienstkleidung], [A_Wochentag], [A_Sender]. Umlaute als HTML-Entities kodieren. Referenz: VBA create_HTML und create_Mail in zmd_Mail.bas." ^
--complexity standard ^
--no-ai-assessment ^
--project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] Phase 5 erfolgreich abgeschlossen
    echo Starte Phase 6...
    call "%~dp0run_phase6.bat"
) else (
    echo [FEHLER] Phase 5 fehlgeschlagen - Code: %ERRORLEVEL%
    pause
)
