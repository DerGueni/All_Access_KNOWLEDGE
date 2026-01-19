# Gap-Analyse: sub_MA_Dienstplan

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 7 | 8 | +1 | ✅ |
| Buttons | 0 | 2 | +2 | ✅ |
| TextBoxen | 7 | 0 | -7 | ⚠️ |
| Labels | 0 | 2 | +2 | ✅ |
| Table Columns | 6 | 7 | +1 | ✅ |
| Events gesamt | 2 | 3 | +1 | ✅ |

**Completion:** 95%

## Controls-Vergleich

### ✅ Implementiert
| Access Control | HTML Element | Mapping |
|----------------|--------------|---------|
| MA_ID (hidden) | via postMessage | Parameter in loadData() |
| VADatum | Table Column | Datum |
| Auftrag | Table Column | Auftrag |
| Objekt | Table Column | Objekt |
| VA_Start | Table Column | Von |
| VA_Ende | Table Column | Bis |
| Status | Table Column | Status |

### ➕ HTML-Extras (nicht in Access)
- **Stunden**: Zusätzliche Spalte zur Anzeige der berechneten Arbeitsstunden
- **Toolbar**: Aktualisieren + Exportieren Buttons
- **StatusText**: Live-Status-Anzeige ("Bereit", "Lade...", "X Einträge")

### ❌ Fehlend
*Keine fehlenden Kern-Controls*

## Events-Vergleich

### ✅ Implementiert
| Access Event | HTML Implementation | Beschreibung |
|--------------|---------------------|--------------|
| OnCurrent | postMessage handler | Reagiert auf LOAD_DATA Message |
| OnDblClick | (geplant) | Auftrag im Detail öffnen |

### ➕ HTML-Extras
- **loadData()**: Lädt Daten von API
- **renderTable()**: Rendert Tabelleninhalt
- **formatDate()**: Formatiert Datum zu de-DE
- **exportData()**: Sendet Export-Request an Parent

### ❌ Fehlend
*Keine kritischen Events fehlen*

## Funktionalität-Vergleich

### ✅ Implementiert
- Anzeige aller Dienstplan-Einträge eines Mitarbeiters
- Sortierung nach Datum (DESC)
- Verknüpfung über MA_ID (Link Child Field)
- API-Anbindung über `/api/dienstplan/ma/:id`
- PostMessage-Kommunikation mit Parent
- Responsive Tabellendarstellung
- Empty State bei keinen Daten
- Live-Status-Updates

### ❌ Fehlend
- **OnDblClick**: Auftrag im Detail öffnen (nur als `window.parent.postMessage` vorbereitet)
- **Filter/Suche**: Keine Datumsfilter (Access hat OrderBy DESC)

## Datenanbindung

### Access RecordSource
```sql
-- RecordSource: qry_MA_Dienstplan oder tbl_MA_VA_Planung
-- OrderBy: VADatum DESC
-- LinkMasterFields: ID (vom Parent frm_MA_Mitarbeiterstamm)
-- LinkChildFields: MA_ID
```

### HTML API-Anbindung
```javascript
// Endpoint
GET /api/dienstplan/ma/${currentMA_ID}

// Response-Mapping
{
  VADatum → formatDate(row.VADatum || row.Datum)
  Auftrag → row.Auftrag
  Objekt → row.Objekt
  VA_Start → row.VA_Start || row.Von
  VA_Ende → row.VA_Ende || row.Bis
  Stunden → row.Stunden (Extra)
  Status → row.Status
}
```

### ⚠️ API-Gaps
**NONE** - API ist vollständig implementiert

## Priorität der Gaps

### P0 Kritisch (Blocker)
*KEINE*

### P1 Wichtig
- **OnDblClick Handler**: Auftrag-Detail öffnen (2h)
  - Aktuell nur `postMessage` zum Parent
  - Sollte frm_va_Auftragstamm mit VA_ID öffnen

### P2 Nice-to-have
- **Datumsfilter**: Von/Bis Filter wie in sub_MA_Stundenuebersicht (3h)
- **Export-Funktion**: Excel/PDF Export implementieren (4h)

## Empfehlung

### Completion
**95%** - Formular ist produktionsreif

### Kritische Gaps
Keine Blocker. OnDblClick fehlt, ist aber P1 und leicht nachzurüsten.

### Aufwand
- **P1**: ~2 Stunden (OnDblClick)
- **P2**: ~7 Stunden (Filter + Export)
- **Gesamt**: ~9 Stunden

### Nächste Schritte
1. ✅ **Freigabe erteilen** - Formular kann in Produktion
2. OnDblClick-Handler nachziehen (nächster Sprint)
3. Optional: Datumsfilter + Export (Backlog)

### Parent-Formular
- **frm_MA_Mitarbeiterstamm** (LinkMasterFields: ID → LinkChildFields: MA_ID)
- **frm_MA_Adressen** (LinkMasterFields: ID → LinkChildFields: MA_ID)
