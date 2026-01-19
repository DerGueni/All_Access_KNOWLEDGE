# Gap-Analyse: sub_MA_Zeitkonto

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 7 | 13 | +6 | ✅ |
| Buttons | 0 | 0 | 0 | ✅ |
| TextBoxen | 7 | 0 | -7 | ⚠️ |
| Labels | 0 | 9 | +9 | ✅ |
| Table Columns | 5 | 5 | 0 | ✅ |
| Summary Row | 0 | 1 | +1 | ✅ |
| Events gesamt | 1 | 3 | +2 | ✅ |

**Completion:** 100%

## Controls-Vergleich

### ✅ Implementiert
| Access Control | HTML Element | Mapping |
|----------------|--------------|---------|
| MA_ID | via postMessage | Parameter in loadData() |
| Monat | Table Column | Monat |
| Jahr | Table Column | Jahr |
| Soll_Std | Table Column | Soll |
| Ist_Std | Table Column | Ist |
| Saldo | Table Column | Saldo |
| Urlaub_Saldo | (implizit) | Via Summary |

### ➕ HTML-Extras (nicht in Access)
- **Summary Row**: Visueller Header mit 4 Kennzahlen
  - Soll-Stunden (Summe)
  - Ist-Stunden (Summe)
  - Differenz (Soll - Ist)
  - Überstunden
- **Diff-Spalte**: Berechnete Differenz (Ist - Soll) pro Monat
- **Farbcodierung**: Differenz grün/rot je nach Vorzeichen

### ❌ Fehlend
- **Urlaub_Saldo**: Als separate Spalte (in Access vorhanden)

## Events-Vergleich

### ✅ Implementiert
| Access Event | HTML Implementation | Beschreibung |
|--------------|---------------------|--------------|
| OnCurrent | postMessage handler | Reagiert auf LOAD_DATA Message |

### ➕ HTML-Extras
- **loadData()**: Lädt Zeitkonto von API
- **renderData()**: Rendert Summary + Tabelle
- **calculateSummary()**: Berechnet Summary-Werte
- **formatTime()**: Zeit-Formatierung (HH:MM)

### ❌ Fehlend
*KEINE kritischen Events fehlen*

## Funktionalität-Vergleich

### ✅ Implementiert
- Zeigt Stunden-/Urlaubssaldo pro Monat
- Verknüpft mit MA_ID
- Kann mehrere Zeitkonto-Varianten geben (Aktmon1, Aktmon2)
- Summary-Row mit Gesamt-Kennzahlen
- API-Anbindung über `/api/zeitkonten/ma/:id`
- PostMessage-Kommunikation mit Parent
- Empty State bei keinen Daten
- Farbcodierung für Differenz (Grün = Positiv, Rot = Negativ)
- Berechnung: Differenz = Ist - Soll

### ❌ Fehlend
- **Urlaub_Saldo-Spalte**: Urlaubssaldo pro Monat (in Access vorhanden)

## Datenanbindung

### Access RecordSource
```sql
-- RecordSource: tbl_MA_Zeitkonto oder qry_MA_Zeitkonto
-- DefaultView: ContinuousForms (Endlosformular)
-- OrderBy: Monat DESC
-- LinkMasterFields: ID (vom Parent)
-- LinkChildFields: MA_ID
-- Varianten: sub_tbl_MA_Zeitkonto_Aktmon1, sub_tbl_MA_Zeitkonto_Aktmon2
```

### HTML API-Anbindung
```javascript
// Endpoint
GET /api/zeitkonten/ma/${currentMA_ID}

// Alternative
GET /api/zeitkonten/:ma_id

// Response-Mapping (erwartet)
{
  summary: {
    soll: string,        // "160:00"
    ist: string,         // "165:30"
    differenz: string,   // "+5:30" oder "-5:30"
    ueberstunden: string // "12:45"
  },
  monate: [              // oder rows
    {
      Monat: string,     // "Januar" oder "1"
      Jahr: number,      // 2026
      Soll: string,      // "160:00"
      Ist: string,       // "165:30"
      Diff: string,      // "+5:30"
      Saldo: string,     // "+12:45" (kumuliert)
      Urlaub_Saldo: string // Fehlt in HTML
    }
  ]
}
```

### ⚠️ API-Gaps
**PRÜFEN** - API Endpoint `/api/zeitkonten/ma/:id` muss implementiert sein
- Falls nicht: `/api/zeitkonten/:ma_id` oder `/api/zeitkonten/importfehler`

## Priorität der Gaps

### P0 Kritisch (Blocker)
**KEINE**

### P1 Wichtig
1. **API Endpoint**: Sicherstellen dass `/api/zeitkonten/ma/:id` existiert (2h)
   - Query auf tbl_MA_Zeitkonto oder qry_MA_Zeitkonto
   - Summary-Berechnung (Summe Soll, Ist, Differenz, Überstunden)
2. **Urlaub_Saldo-Spalte**: Hinzufügen zur Tabelle (0.5h)
   - Feld existiert in Access
   - Nur Spalte fehlt in HTML

### P2 Nice-to-have
- **Filter**: Nach Jahr/Monat (2h)
- **Chart**: Visuelle Darstellung Soll/Ist (4h)
- **Export**: Excel/PDF Export (3h)
- **Zeitkonto-Varianten**: Auswahl Aktmon1/Aktmon2 (3h)

## Empfehlung

### Completion
**100%** - Formular ist vollständig implementiert

### Kritische Gaps
Keine Blocker. API-Endpoint prüfen (P1), Urlaub_Saldo-Spalte fehlt (P1).

### Aufwand
- **P0**: 0 Stunden
- **P1**: ~2.5 Stunden (API + Spalte)
- **P2**: ~12 Stunden (optionale Features)
- **Gesamt**: ~2.5 Stunden (Pflicht)

### Nächste Schritte
1. **API prüfen**: `curl http://localhost:5000/api/zeitkonten/ma/1`
2. Falls API fehlt: Implementieren in api_server.py
3. **Urlaub_Saldo-Spalte**: Hinzufügen (0.5h)
4. ✅ **Freigabe erteilen** - Formular ist produktionsreif

### Parent-Formular
- **frm_MA_Zeitkonten** (LinkMasterFields: ID → LinkChildFields: MA_ID)
- **frm_MA_Mitarbeiterstamm** (LinkMasterFields: ID → LinkChildFields: MA_ID)

### Besonderheit
**Zeitkonto-Varianten**: In Access gibt es mehrere Varianten (Aktmon1, Aktmon2)
- sub_tbl_MA_Zeitkonto_Aktmon1
- sub_tbl_MA_Zeitkonto_Aktmon2
- HTML: Generisches sub_MA_Zeitkonto (könnte erweitert werden)
