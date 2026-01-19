# Gap-Analyse: sub_MA_Offene_Anfragen

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 7 | 9 | +2 | ✅ |
| Buttons | 0 | 2 | +2 | ✅ |
| TextBoxen | 7 | 0 | -7 | ⚠️ |
| Labels | 0 | 1 | +1 | ✅ |
| Table Columns | 7 | 5 | -2 | ⚠️ |
| Events gesamt | 1 | 4+ | +3 | ✅ |
| Logic File | Nein | Ja | +1 | ✅ |

**Completion:** 90%

## Controls-Vergleich

### ✅ Implementiert
| Access Control | HTML Element | Mapping |
|----------------|--------------|---------|
| Name | Table Column | Mitarbeiter |
| Dat_VA_Von | Table Column | Datum |
| Auftrag | (implizit) | Via Objekt-Spalte |
| Ort | Table Column | Objekt |
| von | Table Column | Zeit (kombiniert) |
| bis | Table Column | Zeit (kombiniert) |
| Anfragezeitpunkt | (implizit) | Wird in Logic geladen |

### ➕ HTML-Extras (nicht in Access)
- **Action Buttons**: Zusagen/Absagen Buttons pro Zeile
- **Status-Indikator**: Farbdot für Dringlichkeit
- **Pulse Animation**: Bei dringenden Anfragen
- **lblAnzahl**: Live-Counter "X Anfragen"

### ❌ Fehlend
- **Auftrag-Spalte**: Nicht als separate Spalte sichtbar (nur via Objekt)
- **Anfragezeitpunkt-Spalte**: Fehlt in Tabelle (aber in Logic verfügbar)

## Events-Vergleich

### ✅ Implementiert
| Access Event | HTML Implementation | Beschreibung |
|--------------|---------------------|--------------|
| OnCurrent | postMessage handler | Reagiert auf Parent-Messages |

### ➕ HTML-Extras (in Logic-Datei)
- **loadData()**: Lädt Anfragen von API
- **renderData()**: Rendert Tabelle mit Action-Buttons
- **handleZusage()**: Zusage-Button Handler
- **handleAbsage()**: Absage-Button Handler
- **updateStatus()**: Status-Update nach Aktion
- **Event Delegation**: Effiziente Button-Handler

### ❌ Fehlend
*KEINE kritischen Events fehlen*

## Funktionalität-Vergleich

### ✅ Implementiert
- Anzeige aller offenen Planungsanfragen
- Sortiert nach Auftrag, Name, Datum
- Farbcodierung nach Dringlichkeit
- Action-Buttons für Zusage/Absage
- API-Anbindung über `/api/anfragen?status=offen`
- PostMessage-Kommunikation mit Parent
- Logic-Datei mit Business-Logik (6.7 KB)
- Empty State bei keinen Daten

### ❌ Fehlend
- **Auftrag-Spalte**: Als separate Spalte in Tabelle
- **Anfragezeitpunkt**: Sichtbar in Tabelle (nicht nur in Logic)
- **Filter**: Nach Status, Datum, Mitarbeiter

## Datenanbindung

### Access RecordSource
```sql
-- RecordSource: qry_MA_Offene_Anfragen
-- DefaultView: ContinuousForms (Endlosformular)
-- OrderBy: [Auftrag], [Name], [Dat_VA_Von]
-- Filter: ([Name]="...")
-- AllowEdits: Ja (für Status-Änderungen)
```

### HTML API-Anbindung
```javascript
// Endpoint
GET /api/anfragen?status=offen

// Response-Mapping (erwartet)
{
  anfragen: [
    {
      ID: number,
      Name: string,
      Dat_VA_Von: date,
      Auftrag: string,
      Ort: string,
      von: time,
      bis: time,
      Anfragezeitpunkt: datetime,
      Status_ID: number,
      Dringend: boolean
    }
  ]
}

// Logic-Datei: sub_MA_Offene_Anfragen.logic.js (6742 Bytes)
```

### ⚠️ API-Gaps
- **Auftrag-Feld**: Muss im Response enthalten sein
- **Dringend-Flag**: Für Pulsing-Animation

## Priorität der Gaps

### P0 Kritisch (Blocker)
**KEINE**

### P1 Wichtig
1. **Auftrag-Spalte**: Als separate Spalte hinzufügen (1h)
   - Aktuell nur via "Objekt" ersichtlich
   - Access hat separate Spalte
2. **Anfragezeitpunkt**: In Tabelle anzeigen (0.5h)
   - Feld existiert in API
   - Nur Spalte fehlt in HTML

### P2 Nice-to-have
- **Filter-Funktion**: Nach Status, Datum, MA (3h)
- **Bulk-Actions**: Mehrere Anfragen gleichzeitig bearbeiten (4h)
- **E-Mail-Preview**: Vorschau der Anfrage-E-Mail (3h)

## Empfehlung

### Completion
**90%** - Formular ist nahezu vollständig

### Kritische Gaps
Keine Blocker. Auftrag + Anfragezeitpunkt als Spalten fehlen (P1).

### Aufwand
- **P0**: 0 Stunden
- **P1**: ~1.5 Stunden (2 Spalten hinzufügen)
- **P2**: ~10 Stunden (optionale Features)
- **Gesamt**: ~1.5 Stunden (Pflicht)

### Nächste Schritte
1. **Spalten ergänzen**: Auftrag + Anfragezeitpunkt (1.5h)
2. ✅ **Freigabe erteilen** - Formular ist produktionsreif
3. Optional: Filter + Bulk-Actions (Backlog)

### Parent-Formular
- **frm_MA_Offene_Anfragen** (Standalone, keine Link-Felder)
- Eigenständige Liste aller offenen Anfragen im System

### Besonderheit
**Logic-Datei vorhanden**: sub_MA_Offene_Anfragen.logic.js (6.7 KB)
- Vollständige Business-Logik implementiert
- Zusage/Absage-Handler
- API-Integration
- Event-Handling
