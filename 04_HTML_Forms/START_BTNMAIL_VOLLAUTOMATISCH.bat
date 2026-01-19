@echo off
chcp 65001 >nul
cls

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  AUTO CLAUDE - btnMail Implementierung                        ║
echo ║  VOLLAUTOMATISCH mit Auto-Approve                             ║
echo ╠════════════════════════════════════════════════════════════════╣
echo ║  Phase 2: UI Modal fuer Anfrage-Log                           ║
echo ║  Phase 3: Daten-Vorbereitung (Texte laden)                    ║
echo ║  Phase 4: MD5-Hash und URL-Generierung                        ║
echo ║  Phase 5: E-Mail-Body-Generierung                             ║
echo ║  Phase 6: E-Mail-Versand (mailto Fallback)                    ║
echo ║  Phase 7: Status-Update in Datenbank                          ║
echo ║  Phase 8: Hauptfunktion zusammenfuehren                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo VOLLAUTOMATISCHER MODUS - Keine manuelle Genehmigung noetig!
echo.
echo Druecken Sie eine Taste um zu starten...
pause >nul

cd /d "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
set CLAUDE_CODE_STREAM_CLOSE_TIMEOUT=180000

echo.
echo ════════════════════════════════════════
echo  PHASE 2: UI Modal fuer Anfrage-Log
echo ════════════════════════════════════════
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" "C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" --task "Phase 2 von btnMail Implementierung: Erstelle einen Modal-Dialog fuer das Anfrage-Log in frm_MA_VA_Schnellauswahl.html. Der Modal soll folgende Elemente enthalten: (1) Titel Mitarbeiter werden angefragt, (2) Fortschrittsbalken mit Prozentanzeige, (3) Tabelle mit Spalten Nr Mitarbeiter Status Ergebnis, (4) Schliessen-Button der erst nach Abschluss aktiv wird. Nutze das bestehende CSS-Design der anderen Modals im Projekt. Fuege in frm_MA_VA_Schnellauswahl.logic.js Funktionen hinzu: showAnfrageLog(), updateAnfrageProgress(current, total), addAnfrageLogEntry(name, status, result), closeAnfrageLog(). Referenz: Access Formular zfrm_Log." --complexity simple --no-ai-assessment --auto-approve --project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ════════════════════════════════════════
echo  PHASE 3: Daten-Vorbereitung
echo ════════════════════════════════════════
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" "C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" --task "Phase 3 von btnMail Implementierung: Implementiere die Funktion loadAnfrageTexte(maId, vaId, vaDatumId, vaStartId) in frm_MA_VA_Schnellauswahl.logic.js. Diese Funktion soll alle Daten fuer die E-Mail laden: (1) MA-Daten via Bridge: Vorname, Nachname, Email aus tbl_MA_Mitarbeiterstamm, (2) VA-Daten: Auftrag, Objekt, Ort, Dienstkleidung, Treffpunkt, Treffp_Zeit aus tbl_VA_Auftragstamm, (3) Planungs-Daten: VADatum, MVA_Start, MVA_Ende aus tbl_MA_VA_Planung. Returniere ein Objekt mit allen Feldern. Nutze die bestehende Bridge.execute Struktur. Referenz: VBA Funktion Texte_lesen in zmd_Mail.bas." --complexity simple --no-ai-assessment --auto-approve --project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ════════════════════════════════════════
echo  PHASE 4: MD5-Hash und URL-Generierung
echo ════════════════════════════════════════
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" "C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" --task "Phase 4 von btnMail Implementierung: Implementiere MD5-Hash und URL-Generierung in frm_MA_VA_Schnellauswahl.logic.js. (1) Funktion createMD5Hash(text) die einen MD5-Hash erzeugt - nutze Web Crypto API. (2) Funktion createAnfrageUrls(md5, maId, vaId, vaDatumId, vaStartId, dienstkleidung) die zwei URLs zurueckgibt: urlJa fuer Zusage mit ZUSAGE=1 und urlNein fuer Absage mit ZUSAGE=0. Basis-URL: http://noreply.consec-security.selfhost.eu/mail/index.php. Parameter: md5hash, MA_ID, VA_ID, VADatum_ID, VAStart_ID, dress, ZUSAGE. Leerzeichen durch Unterstriche ersetzen." --complexity simple --no-ai-assessment --auto-approve --project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ════════════════════════════════════════
echo  PHASE 5: E-Mail-Body-Generierung
echo ════════════════════════════════════════
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" "C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" --task "Phase 5 von btnMail Implementierung: Erstelle E-Mail-Template und Body-Generierung. (1) Erstelle forms3/templates/email_anfrage_template.js mit HTML-Template fuer Mitarbeiter-Anfrage. Das Template soll professionell aussehen mit CONSEC Branding, Buttons fuer Zusage gruen und Absage rot, und alle Auftragsinformationen enthalten. (2) Implementiere Funktion createEmailBody(templateData) in frm_MA_VA_Schnellauswahl.logic.js die Platzhalter ersetzt: URL_JA, URL_NEIN, Auftr_Datum, Auftrag, Ort, Objekt, Start_Zeit, End_Zeit, Treffpunkt, Treffp_Zeit, Dienstkleidung, Wochentag, Sender. Umlaute als HTML-Entities kodieren." --complexity simple --no-ai-assessment --auto-approve --project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ════════════════════════════════════════
echo  PHASE 6: E-Mail-Versand
echo ════════════════════════════════════════
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" "C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" --task "Phase 6 von btnMail Implementierung: Implementiere E-Mail-Versand in frm_MA_VA_Schnellauswahl.logic.js. (1) Funktion sendAnfrageEmail(email, subject, htmlBody) mit zwei Modi: Primaer Bridge.execute sendEmail falls Backend verfuegbar, Fallback mailto-Link oeffnen mit window.open. (2) Fuer mailto Subject und Body URL-encodieren, HTML-Tags fuer Plain-Text entfernen. (3) Bei mailto-Fallback Warnung anzeigen dass E-Mails manuell gesendet werden muessen. Betreff-Format: CONSEC Anfrage zu Auftrag Datum in Ort." --complexity simple --no-ai-assessment --auto-approve --project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ════════════════════════════════════════
echo  PHASE 7: Status-Update
echo ════════════════════════════════════════
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" "C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" --task "Phase 7 von btnMail Implementierung: Implementiere Status-Updates in frm_MA_VA_Schnellauswahl.logic.js. (1) Funktion getPlanungStatus(maId, vaId, vaDatumId, vaStartId) die aktuellen Status aus tbl_MA_VA_Planung holt 1=Geplant 2=Benachrichtigt 3=Zusage 4=Absage. (2) Funktion setzeAngefragt(maId, vaId, vaDatumId, vaStartId) die Status auf 2 setzt und Anfragezeitpunkt speichert via Bridge.execute updatePlanung. (3) Funktion setInfoFlag(vaId, vaDatumId, vaStartId) die IstFraglich=true in tbl_MA_VA_Zuordnung setzt. Alle Funktionen nutzen Bridge.execute." --complexity simple --no-ai-assessment --auto-approve --project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ════════════════════════════════════════
echo  PHASE 8: Hauptfunktion zusammenfuehren
echo ════════════════════════════════════════
"C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\.venv\Scripts\python.exe" "C:\Users\guenther.siegert\AppData\Local\Programs\auto-claude-ui\resources\backend\runners\spec_runner.py" --task "Phase 8 von btnMail Implementierung: Erweitere die bestehende versendeAnfragen Funktion in frm_MA_VA_Schnellauswahl.logic.js. Ablauf: (1) showAnfrageLog aufrufen, (2) MA-Liste aus lstMA_Plan holen, (3) Fuer jeden MA: Status pruefen bei 3 oder 4 ueberspringen, Texte laden, MD5-Hash erzeugen, URLs generieren, E-Mail-Body erstellen, E-Mail senden, Bei Erfolg setzeAngefragt aufrufen, Log-Eintrag mit addAnfrageLogEntry, Fortschritt mit updateAnfrageProgress. (4) Nach Schleife Zusammenfassung anzeigen, (5) Nach Modal-Schliessen Navigation zu frm_VA_Auftragstamm. Fehlerbehandlung mit try-catch fuer jeden MA." --complexity standard --no-ai-assessment --auto-approve --project-dir "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  ALLE PHASEN ERFOLGREICH ABGESCHLOSSEN!                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Die btnMail Funktion ist jetzt implementiert in:
echo   forms3/frm_MA_VA_Schnellauswahl.html
echo   forms3/logic/frm_MA_VA_Schnellauswahl.logic.js
echo.
goto :end

:error
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  FEHLER! Eine Phase ist fehlgeschlagen.                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:end
pause
