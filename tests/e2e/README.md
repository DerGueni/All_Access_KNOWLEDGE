# CONSYS E2E Tests mit Playwright

Automatisierte End-to-End Tests fuer die CONSYS HTML Formulare.

## Installation

```bash
cd tests/e2e
npm install
npx playwright install chromium
```

## Tests ausfuehren

### Alle Tests
```bash
npm test
```

### Mit sichtbarem Browser
```bash
npm run test:headed
```

### Mit Playwright UI (interaktiv)
```bash
npm run test:ui
```

### Einzelne Formulare testen
```bash
npm run test:kundenstamm
npm run test:objekt
npm run test:dienstplan
npm run test:planung
```

### Debugging
```bash
npm run test:debug
```

## Test-Report

Nach dem Testlauf wird ein HTML-Report erstellt:
```bash
npm run report
```

Report-Verzeichnis: `../../reports/playwright`

## Getestete Formulare

| Formular | Test-Datei | Tests |
|----------|------------|-------|
| frm_KD_Kundenstamm.html | kundenstamm.spec.ts | Navigation, Speichern, Pflichtfeld, Ansprechpartner-Tab |
| frm_OB_Objekt.html | objekt.spec.ts | Navigation, Speichern, Pflichtfeld, Positionen-Tab |
| frm_N_Dienstplanuebersicht.html | dienstplan.spec.ts | Datums-Navigation, Filter, Grid, Export |
| frm_VA_Planungsuebersicht.html | planung.spec.ts | Zeitraum-Filter, Auftragsliste, Status-Filter |

## Test-Kategorien

### 1. Formular-Laden
- Keine JavaScript-Errors
- Titel wird angezeigt
- Grundlegende Elemente sichtbar

### 2. Navigation
- Record-Navigation (Vor/Zurueck/Erster/Letzter)
- Datums-Navigation (Woche vor/zurueck, Heute)
- Tab-Wechsel

### 3. CRUD-Operationen
- Neu-Button
- Speichern mit Pflichtfeld-Validierung
- Loeschen mit Bestaetigung

### 4. Filter
- Dropdowns
- Checkboxen
- Datumsfilter

### 5. Export
- Export-Button vorhanden
- Klick startet Export (kein Crash)

## Voraussetzungen

- Node.js >= 18
- http-server dient die forms3 Dateien
- API-Server (optional) fuer echte Daten-Tests

## Konfiguration

Die Konfiguration befindet sich in `playwright.config.ts`:
- Base URL: http://localhost:8080
- Browser: Chromium
- Webserver: http-server auf Port 8080

## Hinweise

- API-Fehler (localhost:5000) werden ignoriert, da der API-Server nicht immer laeuft
- Tests sind resilient gegen fehlende Daten
- Screenshot/Video bei Fehlern: `only-on-failure`
