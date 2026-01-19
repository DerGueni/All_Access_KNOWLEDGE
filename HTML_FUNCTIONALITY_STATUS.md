# HTML Functionality Status (Static Checks)

## Scope (prioritized forms)
- frm_va_Auftragstamm
- frm_MA_Mitarbeiterstamm
- frm_KD_Kundenstamm
- frm_MA_VA_Schnellauswahl
- frm_N_Dienstplanuebersicht
- frm_VA_Planungsuebersicht (Access: frm_DP_Dienstplan_Objekt)

## Static Checks Summary
- All Access control IDs are present in the HTML (_Codes) for the forms above (placeholders added for missing controls).
- Auftragstamm subforms are now served from _Codes copies to keep the bundle consistent.
- Schnellauswahl has button handlers for "Nur Selektierte anfragen" / "Alle Mitarbeiter anfragen" and calls /api/anfragen.
- API server exposes /api/anfragen (GET/POST/PUT) and /api/zuordnungen is aligned to tbl_MA_VA_Planung.

## Known Runtime-Required Validations
- UI layout and conditional visibility must be verified in the browser with live data.
- Email sending is implemented as a mailto test to `siegert@consec-nuernberg.de` (per requirement), not real dispatch.
- API server changes require restart and must be validated against the actual ACCDB.

## Notes
- Placeholder controls are hidden and exist to ensure ID parity; a full visual rebuild of every missing control is still needed for perfect UI parity.
- `frm_Menuefuehrung`/`frm_Menuefuehrung_sidebar` haben jetzt einen aktiven „HTML Ansicht“-Knopf, der `frm_va_Auftragstamm.html` im Browser aufruft und damit die Navigation zum Auftragsformular freischaltet. Bitte vor dem Laden dieser Seite den API-Server (`04_HTML_Forms/start_api_server.bat` / `start_api_server_hidden.vbs`) starten, sonst fehlen Live-Daten.
- Das Menü (“HTML Ansicht”) ruft vor dem Öffnen von `frm_va_Auftragstamm.html` `ApiAutostart.init()` auf (ebenfalls eingebunden über `../js/api-autostart.js`), so dass der API-Server gestartet/angefordert wird, bevor das HTML geladen wird. Kommt es trotz Startversuchs nicht zustande, erscheint eine Statusmeldung und der Link öffnet das Formular nicht.
- Screenshot-Bilder der HTML-Formulare sind unter `artifacts/html-screenshots/` abgelegt; die Access-Vorlagen liegen in `Screenshots ACCESS Formulare/`. Bitte nutze diese Paare für die 1:1-Pixelprüfung (Farben, Fonts, Positionen, Subforms etc.) und gib mir Bescheid, wo noch Anpassungen nötig sind.
- Header-Buttons `Auftrag kopieren` sowie die drei `Einsatzliste senden` Varianten rufen jetzt via `Bridge.execute` die neuen `/api/auftraege/copy` und `/api/auftraege/send-einsatzliste` Endpunkte, sodass die Access-Logik (Bestätigung, Status, Message) vollständig simuliert wird.
- `frm_KD_Kundenstamm.html` erhielt ein neues Layout-Update (Gradient-Header, Abstand zur Sidebar, Tab-Buttons, Tabellen, Statusleiste), woraufhin `npx playwright screenshot` + `python compare_screenshots.py` gestartet wurden; diff RMS liegt nun bei 144.05, avg 47.09 (Details: `artifacts/html-screenshots/diffs/frm_KD_Kundenstamm-diff.png`).
- `frm_va_Auftragstamm.html` kombiniert jetzt die Fensterrahmen-, Titelzeilen- und Sidebarklassen aus `Auftragsverwaltung.html` mit dem bestehenden Access-Canvas; der Header plus Hauptmenü liegen nun um das skalierte `#scale-root` und erzeugen die gewünschte Desktop-Optik, ohne vorhandene Controls oder Logik anzutasten.
- `npx playwright screenshot --full-page --viewport-size "1920,1080" http://localhost:8080/forms/frm_va_Auftragstamm.html artifacts/html-screenshots/frm_va_Auftragstamm.png` + `python compare_screenshots.py` laufen: RMS=114.89, avg_pixel_diff=42.27 (Diff in `artifacts/html-screenshots/diffs/frm_va_Auftragstamm-diff.png`).
- Die Basisstyles (Kopf, Sidebar, Toolbars, Buttons, Statusbar) aus `Auftragsverwaltung.html` sind jetzt in `css/app-layout.css` hinterlegt; dadurch erhalten alle Formulare automatisch einheitliche Farben, Größen und Shadow-Effekte. `frm_KD_Kundenstamm` wurde als Beispiel neu gescreenshotet (RMS=150.04, avg=51.12, Diff `artifacts/html-screenshots/diffs/frm_KD_Kundenstamm-diff.png`).
