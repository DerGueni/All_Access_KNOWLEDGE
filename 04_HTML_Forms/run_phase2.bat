@echo off
chcp 65001 >nul
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo ========================================
echo Auto Claude - btnMail Phase 2
echo UI-Erweiterungen: Log-Modal
echo ========================================
echo.

"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" ^
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" ^
--task "Phase 2 von btnMail Implementierung: Erstelle einen Modal-Dialog fuer das Anfrage-Log in frm_MA_VA_Schnellauswahl.html. Der Modal soll folgende Elemente enthalten: (1) Titel Mitarbeiter werden angefragt, (2) Fortschrittsbalken mit Prozentanzeige, (3) Tabelle mit Spalten Nr Mitarbeiter Status Ergebnis, (4) Schliessen-Button der erst nach Abschluss aktiv wird. Nutze das bestehende CSS-Design der anderen Modals im Projekt. Fuege in frm_MA_VA_Schnellauswahl.logic.js Funktionen hinzu: showAnfrageLog(), updateAnfrageProgress(current, total), addAnfrageLogEntry(name, status, result), closeAnfrageLog(). Referenz: Access Formular zfrm_Log." ^
--complexity standard ^
--no-ai-assessment ^
--project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] Phase 2 erfolgreich abgeschlossen
    echo Starte Phase 3...
    call "%~dp0run_phase3.bat"
) else (
    echo [FEHLER] Phase 2 fehlgeschlagen - Code: %ERRORLEVEL%
    pause
)
