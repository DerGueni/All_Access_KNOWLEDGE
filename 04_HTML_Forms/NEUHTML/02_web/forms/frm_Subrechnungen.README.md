# frm_Subrechnungen.html - Dokumentation

## Übersicht
Eigenständiges HTML-Formular für die Verwaltung von Sub-Rechnungen, extrahiert aus dem Tab "Sub Rechnungen" (pgSubRech) des Access-Formulars `frm_MA_Mitarbeiterstamm`.

## Quelle
- **Access-Formular:** frm_MA_Mitarbeiterstamm
- **Tab/Page:** pgSubRech
- **Subformular:** sub_Auftrag_Rechnung_Gueni
- **Datenquelle:** qry_Auftrag_Rechnung_Gueni

## Dateien
```
forms/
├── frm_Subrechnungen.html        # Hauptformular
├── frm_Subrechnungen.css         # Styles
├── frm_Subrechnungen.logic.js    # Logik/Funktionen
└── frm_Subrechnungen.README.md   # Diese Datei
```

## Features

### 1. Auftrags-Übersicht
- Filtert Aufträge nach Zeitraum (von/bis Datum)
- Optional: Filter nach Mitarbeiter
- Zeigt folgende Spalten:
  - Datum (VADatum)
  - Auftrag
  - Location (Objekt)
  - Ort
  - Betrag (Gesamtsumme)
  - RechNr. (Rechnungsnummer extern)
  - Geprüft (Aend_von)
  - am (Aend_am)
  - Status

### 2. Abrechnungsdetails
Nach Auswahl eines Auftrags werden Details angezeigt:
- Liste aller Mitarbeiter-Einsätze für diesen Auftrag
- Spalten: Datum, Name, von, bis, Stunden, Nacht, Sonntag, Feiertag, Fahrtkosten
- Automatische Summenberechnung

### 3. Funktionen
- **Status ändern:** Mehrere Aufträge gleichzeitig auf neuen Status setzen
- **Stundenliste exportieren:** CSV-Export der Abrechnungsdetails
- **Spiegelrechnung:** (Placeholder - noch nicht implementiert)

## Datenbankstruktur

### Primäre Abfrage: qry_Auftrag_Rechnung_Gueni
```sql
SELECT
    VA_ID,
    ErsterWertvonVADatum AS VADatum,
    Auftrag,
    Objekt,
    Ort,
    Gesamtsumme1 AS Betrag,
    RchNr_Ext AS RechNr,
    Aend_von AS Geprueft,
    Aend_am AS GeprueftAm,
    Status,
    Rch_ID
FROM qry_Auftrag_Rechnung_Gueni
WHERE ErsterWertvonVADatum >= #von# AND ErsterWertvonVADatum <= #bis#
ORDER BY ErsterWertvonVADatum DESC
```

### Detail-Abfrage: Stunden pro Auftrag
```sql
SELECT
    z.VADatum,
    m.Nachname + ' ' + m.Vorname AS Name,
    z.VA_Start,
    z.VA_Ende,
    z.Stunden,
    z.Nacht,
    z.Sonntag,
    z.Feiertag,
    z.Fahrtkosten
FROM tbl_MA_VA_Planung z
INNER JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
WHERE z.VA_ID = ?
ORDER BY z.VADatum, z.VA_Start
```

### Weitere Tabellen
- **tbl_Rch_Status:** Status-Werte (Ungeprüft, Geprüft, Freigegeben, etc.)
- **tbl_Rch_Rechnung:** Rechnungs-Stammdaten
- **tbl_MA_Mitarbeiterstamm:** Mitarbeiter-Stammdaten

## API-Integration

### Bridge Client
Das Formular nutzt `bridgeClient.js` für alle API-Calls:

```javascript
// Beispiel: Aufträge laden
const result = await Bridge.execute('executeSQL', {
    sql: auftragSQL,
    fetch: true
});

// Beispiel: Status ändern
await Bridge.execute('executeSQL', {
    sql: `UPDATE tbl_Rch_Rechnung SET Status_ID = ${statusId} WHERE ID = ${rchId}`,
    fetch: false
});
```

## Layout

### No-Sidebar Layout
Das Formular verwendet die `no-sidebar` Klasse für vollflächige Darstellung:

```html
<body class="no-sidebar" data-active-menu="subrechnungen">
```

### Responsive Design
- Header mit Filter-Controls
- 2 Tabellen-Bereiche (Aufträge + Details)
- Summen-Container
- Footer mit Statusanzeige

## Verwendung

### Öffnen
1. **Via Sidebar:** Menu-Item "Sub Rechnungen" in Sidebar
2. **Direkt:** `frm_Subrechnungen.html` im Browser öffnen
3. **Via Shell:** `ConsysShell.showForm('subrechnungen')`

### Workflow
1. Zeitraum auswählen (Standard: aktueller Monat)
2. Optional: Mitarbeiter filtern
3. "Aktualisieren" klicken
4. Auftrag in Liste auswählen
5. Details werden automatisch geladen
6. Funktionen nutzen:
   - Status ändern für markierte Aufträge
   - Stundenliste exportieren (CSV)

## Sidebar-Integration
In `sidebar.js` FORM_MAP:
```javascript
'subrechnungen': 'frm_Subrechnungen.html'
```

## Unterschiede zum Access-Original

### Entfernt
- Button "Stundenliste" (btnStdListe) - integriert in "Stundenliste Exportieren"
- Button "Freigeben" (btnFreigeben) - ersetzt durch Status-Dropdown
- Button "Rechnung anlegen" (btnRchAnlegen) - separate Funktion

### Hinzugefügt
- Mitarbeiter-Filter (alle/einzelner MA)
- Zeitraum-Presets (aktuell, vormonat, jahr, custom)
- "Aktualisieren"-Button für manuelles Reload
- CSV-Export mit Download-Link

### Verbessert
- Responsive Design
- Bessere Performance durch API-Caching
- Klare Trennung: HTML / CSS / Logic
- Event-Delegation für bessere Performance

## Performance

### Optimierungen
- API-Request-Caching via bridgeClient.js
- Event-Delegation auf Tabellen
- Lazy-Loading der Details (nur bei Auswahl)
- Cached DOM-Referenzen

### Empfohlene Einstellungen
```javascript
// In bridgeClient.js
CACHE_TTL: {
    '/auftrag_rechnung': 15000  // 15 Sekunden Cache
}
```

## TODO / Erweiterungen
- [ ] Spiegelrechnung-Funktion implementieren
- [ ] Rechnung-Anlegen-Dialog hinzufügen
- [ ] Batch-Edit für mehrere Aufträge
- [ ] PDF-Export der Abrechnungsdetails
- [ ] Filterspeicherung (LocalStorage)
- [ ] Sortierung der Tabellen-Spalten
- [ ] Echte Betragsberechnung (aktuell 0,00 EUR für SVS/NZ/SZ/FZ)

## Bekannte Einschränkungen
1. **Beträge-Berechnung:** SVS, NZ, SZ, FZ werden aktuell als 0,00 EUR angezeigt, da Stundensätze nicht verfügbar
2. **Status-Änderung:** Funktioniert nur wenn Rch_ID vorhanden
3. **Spiegelrechnung:** Noch nicht implementiert
4. **RechNr korrigieren:** ESC-Funktion noch nicht implementiert

## Fehlerbehandlung
- Try-Catch um alle API-Calls
- Fallback-UI bei Fehlern
- Logging in Console
- Status-Meldungen im Footer

## Browser-Kompatibilität
- Chrome/Edge: ✓
- Firefox: ✓
- Safari: ✓
- IE11: ✗ (ES6-Module nicht unterstützt)

## Version
- **Erstellt:** 2026-01-03
- **Basis:** Access-Export vom 2025-11-25
- **Status:** Funktionsfähig, Erweiterungen geplant
