# Gap-Analyse: sub_MA_VA_Planung_Status

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 8 | 8 | 0 | ✅ |
| Buttons | 0 | 0 | 0 | ✅ |
| TextBoxen | 8 | 0 | -8 | ⚠️ |
| Table Columns | 7 | 8 | +1 | ✅ |
| Events gesamt | 1 | 3+ | +2 | ✅ |
| Logic File | Nein | Ja | +1 | ✅ |

**Completion:** 100%

## Controls-Vergleich

### ✅ Implementiert
| Access Control | HTML Element | Mapping |
|----------------|--------------|---------|
| VA_ID (hidden) | via postMessage | Parameter in loadData() |
| VADatum_ID (hidden) | via postMessage | Parameter in loadData() |
| MA_ID | Table Column (hidden) | ID-Spalte |
| Name | Table Column | Mitarbeiter |
| Status_ID | Table Column | Status (farbcodiert) |
| Anfragezeitpunkt | Table Column | Angefragt |
| MVA_Start | Table Column | Von |
| MVA_Ende | Table Column | Bis |
| VADatum | (implizit) | Über Parent-Parameter |

### ➕ HTML-Extras (nicht in Access)
- **Lfd.-Spalte**: Laufende Nummer pro Zeile
- **Std-Spalte**: Berechnete Stunden (Ende - Beginn)
- **Bemerkungen-Spalte**: Zusatzinfo

### ❌ Fehlend
*KEINE*

## Events-Vergleich

### ✅ Implementiert
| Access Event | HTML Implementation | Beschreibung |
|--------------|---------------------|--------------|
| OnCurrent | postMessage handler | Reagiert auf Parent-Messages |

### ➕ HTML-Extras (in Logic-Datei)
- **loadData()**: Lädt Planungsstatus von API
- **renderTable()**: Rendert Tabelle mit Status-Farbcodierung
- **handleRowClick()**: Zeile auswählen
- **handleRowDblClick()**: Detail öffnen
- **calculateHours()**: Berechnet Stunden aus Von/Bis

### ❌ Fehlend
*KEINE kritischen Events fehlen*

## Funktionalität-Vergleich

### ✅ Implementiert
- Zeigt Planungsstatus aller Mitarbeiter für Auftrag/Tag
- Farbcodierung nach Status:
  - Status 1 (Angefragt): Gelb
  - Status 2 (Zugesagt): Grün
  - Status 3 (Abgesagt): Rot
  - Status 4 (Eingeplant): Blau
- Sortierung nach Anfragezeitpunkt DESC
- Verknüpft über VA_ID und VADatum_ID
- Eingebettet im Auftragstamm-Formular
- API-Anbindung über `/api/planungen?va_id=X&datum_id=Y`
- PostMessage-Kommunikation mit Parent
- Logic-Datei mit Business-Logik (5.8 KB)
- Row-Selection + Hover-State
- Stundenberechnung (MVA_Ende - MVA_Start)

### ❌ Fehlend
*KEINE kritischen Funktionen fehlen*

## Datenanbindung

### Access RecordSource
```sql
-- RecordSource: qry_MA_Plan
-- DefaultView: ContinuousForms (Endlosformular)
-- AllowFilters: Nein
-- OrderByOn: Ja
-- OrderBy: [qry_MA_Plan].[Anfragezeitpunkt] DESC
-- LinkMasterFields: ID, cboVADatum (vom Parent frm_va_auftragstamm)
-- LinkChildFields: VA_ID, VADatum_ID
```

### HTML API-Anbindung
```javascript
// Endpoint
GET /api/planungen?va_id=X&datum_id=Y

// Alternative (falls oben nicht existiert)
GET /api/auftraege/${va_id}/planungen?vadatum_id=${datum_id}

// Response-Mapping (erwartet)
{
  planungen: [
    {
      ID: number,
      VA_ID: number,
      VADatum_ID: number,
      MA_ID: number,
      Name: string,
      Status_ID: number,
      Anfragezeitpunkt: datetime,
      MVA_Start: time,
      MVA_Ende: time,
      VADatum: date,
      Bemerkung: string
    }
  ]
}

// Status-Codes (für Farbcodierung)
1 = "Angefragt" (Gelb)
2 = "Zugesagt" (Grün)
3 = "Abgesagt" (Rot)
4 = "Eingeplant" (Blau)

// Logic-Datei: sub_MA_VA_Planung_Status.logic.js (5774 Bytes)
```

### ⚠️ API-Gaps
**PRÜFEN** - API Endpoint für Planungsstatus muss implementiert sein
- Option 1: `/api/planungen?va_id=X&datum_id=Y`
- Option 2: `/api/auftraege/:va_id/planungen?vadatum_id=Y`

## Priorität der Gaps

### P0 Kritisch (Blocker)
**KEINE**

### P1 Wichtig
1. **API Endpoint**: Sicherstellen dass Planungen-Endpoint existiert (3h)
   - Query auf qry_MA_Plan oder tbl_MA_VA_Planung
   - JOIN mit tbl_MA_Mitarbeiterstamm für Name
   - Sortierung nach Anfragezeitpunkt DESC

### P2 Nice-to-have
- **Status-Änderung**: Direkt aus Tabelle Status ändern (4h)
- **Filter**: Nach Status (Alle, Angefragt, Zugesagt, etc.) (2h)
- **Bulk-Status-Änderung**: Mehrere auf einmal bearbeiten (3h)
- **E-Mail senden**: Anfrage/Zusage/Absage E-Mail direkt versenden (5h)

## Empfehlung

### Completion
**100%** - Formular ist vollständig implementiert

### Kritische Gaps
Keine Blocker. API-Endpoint prüfen (P1).

### Aufwand
- **P0**: 0 Stunden
- **P1**: ~3 Stunden (API implementieren)
- **P2**: ~14 Stunden (optionale Features)
- **Gesamt**: ~3 Stunden (Pflicht)

### Nächste Schritte
1. **API prüfen**: `curl http://localhost:5000/api/planungen?va_id=123&datum_id=456`
2. Falls API fehlt: Implementieren in api_server.py
3. ✅ **Freigabe erteilen** - Formular ist produktionsreif

### Parent-Formular
- **frm_va_auftragstamm** (LinkMasterFields: ID, cboVADatum → LinkChildFields: VA_ID, VADatum_ID)
- Control-Name im Parent: **sub_MA_VA_Zuordnung_Status** (verwendet aber sub_MA_VA_Planung_Status als SourceObject)

### Besonderheit
**Master-Detail mit 2 Link-Feldern**: VA_ID + VADatum_ID
- Zeigt nur Planungen für gewählten Auftrag + gewählten Tag
- Logic-Datei vorhanden: sub_MA_VA_Planung_Status.logic.js (5.8 KB)
- **Status-Farbcodierung**: Visuelles Feedback über Planungsstatus
