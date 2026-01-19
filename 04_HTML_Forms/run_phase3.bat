@echo off
chcp 65001 >nul
cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo ========================================
echo Auto Claude - btnMail Phase 3
echo Daten-Vorbereitung: Texte laden
echo ========================================
echo.

"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" ^
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" ^
--task "Phase 3 von btnMail Implementierung: Implementiere die Funktion loadAnfrageTexte(maId, vaId, vaDatumId, vaStartId) in frm_MA_VA_Schnellauswahl.logic.js. Diese Funktion soll alle Daten fuer die E-Mail laden: (1) MA-Daten via Bridge: Vorname, Nachname, Email aus tbl_MA_Mitarbeiterstamm, (2) VA-Daten: Auftrag, Objekt, Ort, Dienstkleidung, Treffpunkt, Treffp_Zeit aus tbl_VA_Auftragstamm, (3) Planungs-Daten: VADatum, MVA_Start, MVA_Ende aus tbl_MA_VA_Planung. Returniere ein Objekt mit allen Feldern. Nutze die bestehende Bridge.execute Struktur. Referenz: VBA Funktion Texte_lesen in zmd_Mail.bas." ^
--complexity standard ^
--no-ai-assessment ^
--project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] Phase 3 erfolgreich abgeschlossen
    echo Starte Phase 4...
    call "%~dp0run_phase4.bat"
) else (
    echo [FEHLER] Phase 3 fehlgeschlagen - Code: %ERRORLEVEL%
    pause
)
