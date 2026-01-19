@echo off
chcp 65001 >nul
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo ========================================
echo Auto Claude - btnMail Phase 8
echo Hauptfunktion zusammenfuehren
echo ========================================
echo.

"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" ^
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" ^
--task "Phase 8 von btnMail Implementierung: Erweitere die bestehende versendeAnfragen(alle) Funktion in frm_MA_VA_Schnellauswahl.logic.js zu einer vollstaendigen Implementierung. Ablauf: (1) showAnfrageLog() aufrufen, (2) MA-Liste aus lstMA_Plan holen (alle oder nur ausgewaehlte je nach Parameter), (3) Fuer jeden MA in Schleife: (a) Status pruefen mit getPlanungStatus - bei Status 3 oder 4 ueberspringen mit Meldung, (b) Texte laden mit loadAnfrageTexte, (c) MD5-Hash erzeugen mit createMD5Hash, (d) URLs generieren mit createAnfrageUrls, (e) E-Mail-Body erstellen mit createEmailBody, (f) E-Mail senden mit sendAnfrageEmail, (g) Bei Erfolg: setzeAngefragt und setInfoFlag aufrufen, (h) Log-Eintrag mit addAnfrageLogEntry, (i) Fortschritt mit updateAnfrageProgress. (4) Nach Schleife: Zusammenfassung anzeigen, (5) Nach Modal-Schliessen: Navigation zu frm_VA_Auftragstamm. Fehlerbehandlung mit try-catch fuer jeden MA. Referenz: VBA btnMail_Click und show_requestlog in Form_frm_MA_VA_Schnellauswahl." ^
--complexity complex ^
--no-ai-assessment ^
--project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] Phase 8 erfolgreich abgeschlossen
    echo.
    echo ========================================
    echo ALLE PHASEN ABGESCHLOSSEN!
    echo ========================================
    echo.
    echo Bitte testen Sie die btnMail Funktion in:
    echo frm_MA_VA_Schnellauswahl.html
    echo.
) else (
    echo [FEHLER] Phase 8 fehlgeschlagen - Code: %ERRORLEVEL%
)
pause
