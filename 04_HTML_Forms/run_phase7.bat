@echo off
chcp 65001 >nul
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo ========================================
echo Auto Claude - btnMail Phase 7
echo Status-Update in Datenbank
echo ========================================
echo.

"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" ^
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" ^
--task "Phase 7 von btnMail Implementierung: Implementiere Status-Updates in frm_MA_VA_Schnellauswahl.logic.js. (1) Funktion getPlanungStatus(maId, vaId, vaDatumId, vaStartId) die aktuellen Status aus tbl_MA_VA_Planung holt (1=Geplant, 2=Benachrichtigt, 3=Zusage, 4=Absage). (2) Funktion setzeAngefragt(maId, vaId, vaDatumId, vaStartId) die Status auf 2 setzt und Anfragezeitpunkt speichert via Bridge.execute updatePlanung. (3) Funktion setInfoFlag(vaId, vaDatumId, vaStartId) die IstFraglich=true in tbl_MA_VA_Zuordnung setzt fuer den ersten freien Platz (MA_ID=0). Alle Funktionen nutzen Bridge.execute. Referenz: VBA setze_Angefragt und setInfo in zmd_Mail.bas." ^
--complexity standard ^
--no-ai-assessment ^
--project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] Phase 7 erfolgreich abgeschlossen
    echo Starte Phase 8...
    call "%~dp0run_phase8.bat"
) else (
    echo [FEHLER] Phase 7 fehlgeschlagen - Code: %ERRORLEVEL%
    pause
)
