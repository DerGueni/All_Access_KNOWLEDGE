# STAND DER ARBEIT - WebView2 HTML Formulare

**Letztes Update:** 2026-01-19 14:50
**Session:** Excel-Issues abgearbeitet + Gesamtprojekt committed

---

## AKTUELLER STAND

### Commits (heute gepusht auf GitHub)
```
7da7c8e chore: Add all project files (WinUI3, Tools, Docs, Reports) - 12.709 Dateien
ca4c526 fix: Excel-Issues #23, #24, #26, #38, #39 + postMessage Handler
a40ae7e feat: 95% Access-Parität für alle Hauptformulare erreicht
```

**Branch:** `main` (synchron mit origin/main)

---

## Erledigte Excel-Issues (Session 2026-01-19)

| Issue | Beschreibung | Status |
|-------|--------------|--------|
| #23 | Objekt-Auswahl -> Ansprechpartner automatisch laden | ✅ |
| #24 | Datumsbereich-Filter (API akzeptiert beide Varianten) | ✅ |
| #26 | Hat_Fahrerausweis wird gespeichert | ✅ |
| #38 | Anstellungsart Dropdown dynamisch aus DB | ✅ |
| #39 | Beginn/Ende-Zeiten in Schnellauswahl | ✅ |
| #10 | 11 neue postMessage Handler | ✅ |
| #28 | /api/adressen geprüft (nicht benötigt) | ✅ |
| #29 | MA-Filter nur aktive (bereits default) | ✅ |

---

## Geänderte Dateien (Session 2026-01-19)

### frm_va_Auftragstamm.logic.js
- `applyObjektRules()` erweitert: lädt Ansprechpartner/Treffpunkt/Dienstkleidung vom Objekt
- 11 neue postMessage Handler:
  - SCHICHT_SELECTED, DAY_SELECTED, DAY_DBLCLICK
  - FILTER_CHANGED, SCHICHT_CHANGED
  - ZUORDNUNG_RECALC_REQUEST
  - ADD_DAY, REMOVE_DAY, COPY_DAY
  - ADD_SCHICHT, EDIT_SCHICHT

### frm_MA_Mitarbeiterstamm.logic.js
- `Hat_Fahrerausweis` zu saveRecord() hinzugefügt
- `loadAnstellungsarten()` neue Funktion für dynamisches Dropdown

### api_server.py
- `Hat_Fahrerausweis` zur allowed-Liste für PUT
- Datum-Parameter flexibel (von/bis ODER datum_von/datum_bis)
- Neuer Endpoint `/api/anstellungsarten`

### webview2-bridge.js
- Case `getAnstellungsarten` hinzugefügt

### frm_MA_VA_Schnellauswahl.html
- `dataset.beginn`/`dataset.ende` für Schicht-Zeiten als Fallback

---

## Offene Punkte

### Niedrige Priorität
- [ ] #37 - 2 Planungsuebersicht Formulare (forms/ und forms3/)
- [ ] Worktree `04_HTML_Forms/.worktrees/007-pending` bereinigen

### Dokumentation
- CLAUDE2.md enthält vollständiges Änderungslog
- FROZEN_FEATURES.md Plan genehmigt (noch nicht implementiert)

---

## Wichtige Pfade

| Bereich | Pfad |
|---------|------|
| HTML-Formulare | `04_HTML_Forms/forms3/` |
| Logic-Dateien | `04_HTML_Forms/forms3/logic/` |
| API Server | `08_Tools/python/api_server.py` (Port 5000) |
| VBA Bridge | `04_HTML_Forms/api/` (Port 5002) |
| Änderungslog | `CLAUDE2.md` |
| VBA-Exports | `exports/vba/forms/` |
| Excel-Issues | `ABWEICHUNGEN_AKTUELL_18012026.xlsx` |

---

## Vorherige Sessions (Zusammenfassung)

### 2026-01-17 - Access-Parität
- 47 HTML-Formulare analysiert
- Header-Fixes (16px)
- Button-Events korrigiert
- Logic-Dateien modularisiert
- API-Fix für ODBC Crash

### 2026-01-18 - Excel-Issues Batch 1
- Verrechnungssätze API-Tabellen-Fix
- postMessage Handler Grundlage
- Hat_Fahrerausweis, Anstellungsart, etc.

---

## Nächste Schritte (Vorschläge)

1. Excel-Liste Status aktualisieren
2. Browser-Test aller Formulare
3. FROZEN_FEATURES.md implementieren
4. Worktree 007-pending prüfen
