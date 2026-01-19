# frm_MA_Offene_Anfragen - Dokumentation

## Übersicht
HTML-Version des Access-Formulars `frm_MA_Offene_Anfragen` zur Anzeige offener Mitarbeiter-Anfragen.

## Dateien
- **HTML:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_MA_Offene_Anfragen.html`
- **Logik:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\logic\frm_MA_Offene_Anfragen.logic.js`

## Formular-Struktur

### Layout
- **Sidebar:** CONSYS-Hauptmenü (linke Navigation)
- **Header:** Formulartitel "Offene MA-Anfragen" + Datum
- **Toolbar:** Buttons für Aktualisieren, Filter, Export + Dropdown-Filter
- **Content:** Datentabelle mit offenen Anfragen
- **Footer:** Statuszeile + letztes Update

### Datentabelle
Spalten:
1. **Mitarbeiter** - Name (Nachname Vorname)
2. **Datum** - Einsatzdatum (Dat_VA_Von)
3. **Auftrag** - Auftragsbezeichnung
4. **Ort** - Einsatzort
5. **Von** - Startzeit (MVA_Start)
6. **Bis** - Endzeit (MVA_Ende)
7. **Angefragt am** - Anfragezeitpunkt

## API-Anbindung

### Endpoint
```
GET http://localhost:5000/api/anfragen
```

### Datenfilter (entspricht Access-Abfrage)
Die Logic-Datei repliziert die SQL-Abfrage `qry_MA_Offene_Anfragen`:

```sql
WHERE
  Dat_VA_Von > Date()
  AND Anfragezeitpunkt > #1/1/2022#
  AND Rueckmeldezeitpunkt IS NULL
ORDER BY
  Dat_VA_Von, Anfragezeitpunkt DESC
```

JavaScript-Implementierung:
```javascript
.filter(item => {
    // Nur zukünftige Einsätze
    if (datVon <= today) return false;

    // Nur mit Anfragezeitpunkt nach 1.1.2022
    if (anfrageDat <= cutoffDate) return false;

    // Nur ohne Rückmeldung
    if (item.Rueckmeldezeitpunkt) return false;

    return true;
})
```

## Funktionalität

### Buttons
- **Aktualisieren (🔄):** Lädt Daten neu von API
- **Filter (🔍):** Öffnet Filter-Dialog (Platzhalter)
- **Export (📊):** Exportiert Daten als CSV

### Filter-Dropdown
- **Alle Anfragen:** Zeigt alle offenen Anfragen
- **Nur zukünftige:** Filtert auf Datum > heute
- **Nächste 7 Tage:** Zeigt Anfragen der nächsten Woche
- **Nächste 30 Tage:** Zeigt Anfragen des nächsten Monats

### Interaktion
- **Klick auf Zeile:** Zeile wird markiert, Details in Console
- **Hover:** Zeile wird hervorgehoben (hellblau)
- **Farbcodierung Datum:**
  - Grün (`.date-future`): > 7 Tage in Zukunft
  - Orange (`.date-soon`): 0-7 Tage in Zukunft
  - Rot (`.date-past`): Vergangenheit (sollte nicht vorkommen)

## Styling

### CSS-Dateien
```html
<link rel="stylesheet" href="../css/app-layout.css">
<link rel="stylesheet" href="../theme/consys_theme.css">
```

### Formular-spezifisches CSS
- `.anfragen-container` - Flex-Layout für Tabelle
- `.anfragen-table` - Tabellen-Styling mit Sticky Header
- `.loading` / `.spinner` - Loading-Animation
- `.no-results` - Keine-Daten-Anzeige

### Spaltenbreiten
```css
.col-name { width: 180px; }
.col-datum { width: 100px; }
.col-auftrag { width: 280px; }
.col-ort { width: 200px; }
.col-von { width: 80px; }
.col-bis { width: 80px; }
.col-anfragezeitpunkt { width: 120px; }
```

## Sidebar-Integration

Die Form ist im Sidebar-Menü verfügbar unter:
- **ID:** `offene_anfragen`
- **Label:** "Offene Anfragen"
- **Position:** Nach "Mitarbeiterverwaltung"

Aktiviert durch `data-active-menu="offene_anfragen"` im `<body>`-Tag.

## Datenfluss

```
1. Formular lädt
   ↓
2. init() wird aufgerufen
   ↓
3. loadAnfragen() fetcht API
   ↓
4. processAnfragenData() filtert Daten
   ↓
5. applyFilter() wendet Dropdown-Filter an
   ↓
6. renderTable() zeigt Daten in Tabelle
   ↓
7. User-Interaktion (Klick, Filter, Export)
```

## Performance-Optimierungen

1. **DocumentFragment:** Batch-Insert beim Rendern (alle Zeilen auf einmal)
2. **Event Delegation:** Ein Listener für alle Zeilen statt N Listener
3. **Cached DOM-Referenzen:** `tbody`, `recordCount`, etc. werden einmal gesucht
4. **CSS-Transitions:** Hardware-beschleunigtes Hover-Highlighting

## Error Handling

### API nicht erreichbar
```javascript
catch (error) {
    showError('Fehler beim Laden der Daten: ' + error.message);
    footerStatus.textContent = 'Fehler beim Laden';
}
```

### Keine Daten
```javascript
if (filteredAnfragen.length === 0) {
    tbody.innerHTML = 'Keine offenen Anfragen gefunden.';
}
```

## Zukünftige Erweiterungen

1. **Detail-Panel:** Rechte Sidebar mit erweiterten Infos bei Klick
2. **Erweiterte Filter:** Modal-Dialog mit Multi-Filter (MA, Auftrag, Zeitraum)
3. **Excel-Export:** Echtes XLSX statt CSV
4. **Inline-Bearbeitung:** Rückmeldung direkt in Tabelle setzen
5. **Auto-Refresh:** Periodisches Nachladen (z.B. alle 30 Sekunden)
6. **Sortierung:** Klick auf Spaltenheader zum Sortieren

## Abhängigkeiten

### JavaScript
- `sidebar.js` - Globale Sidebar-Navigation

### API
- `api_server.py` - Muss auf Port 5000 laufen

### Backend-Tabellen
- `tbl_MA_Mitarbeiterstamm`
- `tbl_VA_Auftragstamm`
- `tbl_MA_VA_Planung`

## Testen

### Manuell
1. API-Server starten:
   ```bash
   cd "C:\Users\guenther.siegert\Documents\Access Bridge"
   python api_server.py
   ```

2. Formular öffnen:
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_MA_Offene_Anfragen.html
   ```

3. Erwartetes Verhalten:
   - Tabelle lädt nach 1-2 Sekunden
   - Anzahl offener Anfragen wird angezeigt
   - Klick auf Zeile markiert diese
   - Filter-Dropdown ändert angezeigte Datenmenge

### Console-Logs
```
[Offene Anfragen] Initialisiere Formular...
[Offene Anfragen] Lade Daten von API...
[Offene Anfragen] API Response: {...}
[Offene Anfragen] Details: {...}
```

## Changelog

### Version 1.0 (2026-01-02)
- Initiale Erstellung basierend auf Access-Form
- Vollständige API-Anbindung
- Filter-Funktionalität
- CSV-Export
- Responsive Layout mit app-layout.css
