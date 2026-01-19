# frmTop_MA_Abwesenheitsplanung - Abwesenheitsplanung

## Übersicht
Vollständige HTML-Version des Access-Formulars `frmTop_MA_Abwesenheitsplanung` zur Planung und Verwaltung von Mitarbeiter-Abwesenheiten.

## Dateien
- `frmTop_MA_Abwesenheitsplanung.html` - Hauptformular
- `logic/frmTop_MA_Abwesenheitsplanung.logic.js` - Geschäftslogik

## Features

### Mitarbeiter-Auswahl
- Dropdown mit aktiven Mitarbeitern (ohne Subunternehmer)
- Sortiert nach Nachname, Vorname
- Daten von API-Endpoint `/api/mitarbeiter?aktiv=true`

### Abwesenheitsgrund
- Dropdown mit Gründen aus `tbl_MA_Zeittyp`
- Daten von API-Endpoint `/api/dienstplan/gruende`
- Optional: Bemerkungsfeld für Freitext

### Zeitraum-Eingabe
**Radio-Buttons:**
- **Ganztägig** (Standard)
- **Teilzeit** - zeigt Uhrzeitfelder an

**Datumsfelder:**
- Von Datum (date picker)
- Bis Datum (date picker)

**Teilzeit-Felder (nur bei Teilzeit):**
- Von Uhrzeit (time picker, Default: 08:00)
- Bis Uhrzeit (time picker, Default: 12:00)

**Checkbox:**
- "Nur Werktage (Mo-Fr)" - filtert Wochenenden aus

### Berechnen-Funktion
**Button: "Berechnen"**
- Validiert Eingaben (MA, Zeitraum, Grund)
- Generiert Liste aller Tage im Zeitraum
- Berücksichtigt "Nur Werktage" Option
- Zeigt Ergebnisliste rechts an

**Ergebnisliste:**
- Checkbox pro Eintrag (für Löschfunktion)
- Datum (DD.MM.YYYY)
- Wochentag (Mo, Di, Mi, ...)
- Typ (Ganztägig oder "Teilzeit HH:MM - HH:MM")
- Anzahl in Header

### Listen-Aktionen
**Buttons:**
- **Markierte löschen** - löscht ausgewählte Einträge
- **Alle löschen** - löscht komplette Liste (mit Bestätigung)

### Speichern
**Button: "Speichern"**
- Speichert alle berechneten Einträge via API
- Endpoint: `POST /api/abwesenheiten`
- Payload pro Tag:
  ```json
  {
    "MA_ID": 123,
    "vonDat": "2025-01-15",
    "bisDat": "2025-01-15",
    "Grund": "Urlaub",
    "Bemerkung": "Optional",
    "IstGanztag": true,
    "ZeitVon": null,
    "ZeitBis": null
  }
  ```
- Zeigt Fortschritt und Ergebnis an
- Resettet Formular nach erfolgreichem Speichern

### Reset-Funktion
**Button: "Zurücksetzen"**
- Leert alle Felder
- Löscht Ergebnisliste
- Setzt auf Standardwerte zurück

## API-Abhängigkeiten

### GET /api/mitarbeiter?aktiv=true
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "ID": 1,
      "Nachname": "Mustermann",
      "Vorname": "Max",
      "IstAktiv": true,
      "Subunternehmer": false
    }
  ]
}
```

### GET /api/dienstplan/gruende
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "ID": 1,
      "Bezeichnung": "Urlaub",
      "DP_Grund": "U"
    },
    {
      "ID": 2,
      "Bezeichnung": "Krank",
      "DP_Grund": "K"
    }
  ]
}
```

### POST /api/abwesenheiten
**Request:**
```json
{
  "MA_ID": 1,
  "vonDat": "2025-01-15",
  "bisDat": "2025-01-15",
  "Grund": "Urlaub",
  "Bemerkung": "Jahresurlaub",
  "IstGanztag": true,
  "ZeitVon": null,
  "ZeitBis": null
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 456,
    "message": "Abwesenheit erstellt"
  }
}
```

## Layout

### Header (BLAU #4316B2)
- Titel: "Abwesenheitsplanung"
- Buttons: Speichern (Primary), Schließen
- Version-Info + Datum

### Content Area
**Zweiteilung:**
- **Links (400px):** Eingabeformular mit Fieldsets
  - Mitarbeiter
  - Abwesenheitsart
  - Zeitraum
  - Buttons
- **Rechts (flex):** Ergebnisliste
  - Header mit Anzahl
  - Scrollbare Liste mit Checkboxen
  - Aktions-Buttons

### Footer (BLAU #4316B2)
- Links: "CONSYS Abwesenheitsplanung"
- Mitte: Statustext
- Rechts: Benutzer-Info

### Sidebar
- Access-Style Hauptmenü
- Aktiver Eintrag: "Abwesenheitsplanung"

## Validierungen
1. **Mitarbeiter muss gewählt sein**
2. **Von-Datum muss gesetzt sein**
3. **Bis-Datum muss gesetzt sein**
4. **Von-Datum ≤ Bis-Datum**
5. **Abwesenheitsgrund muss gewählt sein**

## UI-States

### Loading
- Overlay mit Spinner während API-Calls

### Toast-Notifications
- **Success** (grün): Erfolgsmeldungen
- **Error** (rot): Fehlermeldungen
- **Warning** (orange): Warnungen
- **Info** (blau): Informationen
- Auto-Close nach 3 Sekunden

### Status-Bar
- "Bereit" - Initial
- "X Mitarbeiter geladen" - Nach Mitarbeiter-Load
- "X Tage berechnet" - Nach Berechnung
- "Speichere Abwesenheiten..." - Während Speichern
- "X Abwesenheiten gespeichert" - Nach Speichern

## Performance-Optimierungen
- Event Delegation für Liste
- Batch-Insert via API (sequenziell)
- Cached State-Management
- Minimales Re-Rendering

## Styling
- **CSS-Framework:** app-layout.css + consys_theme.css
- **Farb-Schema:** CONSYS-Blau (#4316B2)
- **Schrift:** Segoe UI, 11px Base
- **Responsive:** 12"-24" Monitore

## Browser-Kompatibilität
- Chrome/Edge (Chromium) 90+
- Firefox 88+
- Safari 14+
- Requires: ES6, Fetch API, CSS Grid

## Entwickler-Notizen
- Keine jQuery-Abhängigkeit
- Vanilla JavaScript (ES6 Modules)
- REST API über fetch()
- State Management ohne Framework
- Event-driven Architecture

## TODO / Erweiterungen
- [ ] Export als CSV/Excel
- [ ] Import aus CSV
- [ ] Duplikats-Prüfung
- [ ] Bulk-Edit für mehrere MA
- [ ] Vorlagen-System (z.B. "Alle MA Urlaub Weihnachten")
- [ ] Kalender-Ansicht als Alternative zur Liste
- [ ] Integration mit Outlook-Kalender
- [ ] Push-Notifications bei Überschneidungen

## Version
- **1.0** - 2025-01-02 - Initial Release
