# Codex Prompt Template (Copy/Paste)

## Kontext
Du arbeitest im Projekt **CONSYS**. Nutze als Source-of-Truth:
- `CODEX_CONSYS_ACCESS_WEB_KNOWLEDGE.md`
- `FORM_MAP_INDEX.json`
- `exports/forms/<FORM>/controls.json`, `recordsource.json`, `subforms.json`, `tabs.json`
- HTML/JS Bestand unter `04_HTML_Forms/`
- React Bestand unter `07_Web_Client/src/`
- Backend/Bridge: `08_Tools/python/api_server.py` + `04_HTML_Forms/api/bridgeClient.js`

## Aufgabe
1) Erzeuge oder ändere das Web-Formular **<FORMNAME>**.
2) Beachte Subforms/Master-Child Links aus `exports/forms/<FORMNAME>/subforms.json`.
3) Verwende API Calls ausschließlich über den Bridge Client (wenn möglich).
4) Liefere die Änderungen als:
   - vollständige Datei-Inhalte (HTML + logic.js) **oder**
   - Patch/Diff, wenn explizit gewünscht.

## Akzeptanzkriterien
- Formular lädt Datensatz anhand übergebener ID
- Speichern aktualisiert den Datensatz (inkl. Validierung)
- Buttons/Events entsprechen Access Logik (wo vorhanden)
- Subforms filtern korrekt nach Master-Key

## Output-Format
- Datei: `04_HTML_Forms/forms/<FORMNAME>.html`
- Datei: `04_HTML_Forms/forms/logic/<FORMNAME>.logic.js`
- Optional: Mapping-Update in `FORM_MAP_INDEX.json`
