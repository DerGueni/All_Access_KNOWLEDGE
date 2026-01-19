# HTML-Form Konventionen (CONSYS)

## Dateipfade
- HTML: `04_HTML_Forms/forms/<FORM>.html`
- Logik: `04_HTML_Forms/forms/logic/<FORM>.logic.js`
- API: `04_HTML_Forms/api/bridgeClient.js`

## Minimalstruktur
- `<form>` mit klaren Field-IDs (entsprechend Control-Namen / Feldnamen)
- Buttons haben stabile IDs (`btnSave`, `btnNew`, ...)
- Layout: Grid/Sections (Subforms als Tabs/Accordion)

## Datenbindung
- Laden über `bridgeClient` (GET) beim Start
- Speichern über `bridgeClient` (POST/PUT) über `btnSave`
- Fehler: user-friendly anzeigen + console.log für Debug
