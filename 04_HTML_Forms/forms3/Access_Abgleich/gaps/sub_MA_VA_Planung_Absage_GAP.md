# Gap-Analyse: sub_MA_VA_Planung_Absage

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 6 | 6 | 0 | ✅ |
| Buttons | 0 | 0 | 0 | ✅ |
| TextBoxen | 6 | 0 | -6 | ⚠️ |
| Table Columns | 5 | 6 | +1 | ✅ |
| Events gesamt | 2 | 3+ | +1 | ✅ |
| Logic File | Nein | Ja | +1 | ✅ |

**Completion:** 95%

## Controls-Vergleich

### ✅ Implementiert
| Access Control | HTML Element | Mapping |
|----------------|--------------|---------|
| VA_ID (hidden) | via postMessage | Parameter in loadData() |
| VADatum_ID (hidden) | via postMessage | Parameter in loadData() |
| MA_ID | Table Column (hidden) | ID-Spalte |
| Name | Table Column | Mitarbeiter |
| Absagedatum | (implizit) | Via Bemerkungen oder separate API |
| Absagegrund | Table Column | Bemerkungen |

### ➕ HTML-Extras (nicht in Access)
- **Lfd.-Spalte**: Laufende Nummer pro Zeile
- **Beginn-Spalte**: Schichtbeginn (aus MA_VA_Planung)
- **Ende-Spalte**: Schichtende (aus MA_VA_Planung)

### ❌ Fehlend
- **Absagedatum**: Als separate Spalte (aktuell implizit in Bemerkungen)

## Events-Vergleich

### ✅ Implementiert
| Access Event | HTML Implementation | Beschreibung |
|--------------|---------------------|--------------|
| BeforeInsert | (in Logic) | Vor Einfügen validieren |
| BeforeUpdate | (in Logic) | Vor Aktualisierung validieren |

### ➕ HTML-Extras (in Logic-Datei)
- **loadData()**: Lädt Absagen von API
- **renderTable()**: Rendert Absagen-Tabelle
- **handleRowClick()**: Zeile auswählen
- **handleRowDblClick()**: Detail öffnen (geplant)

### ❌ Fehlend
*KEINE kritischen Events fehlen*

## Funktionalität-Vergleich

### ✅ Implementiert
- Zeigt abgesagte MA-Zuordnungen für Auftrag/Tag
- Verknüpft über VA_ID und VADatum_ID
- Eingebettet im Auftragstamm-Formular
- Nur Anzeige, keine Neuerfassung hier (AllowAdditions: Nein)
- API-Anbindung über `/api/zuordnungen/absagen?va_id=X&datum_id=Y`
- PostMessage-Kommunikation mit Parent
- Logic-Datei mit Business-Logik (5.8 KB)
- Row-Selection + Hover-State

### ❌ Fehlend
- **Absagedatum-Spalte**: Wann wurde abgesagt (in Access vorhanden)
- **Restore-Funktion**: Absage rückgängig machen

## Datenanbindung

### Access RecordSource
```sql
-- RecordSource: qry_MA_Plan_Absage
-- DefaultView: ContinuousForms (Endlosformular)
-- ScrollBars: 2 (Vertikal)
-- AllowFilters: Nein
-- AllowAdditions: Nein
-- LinkMasterFields: ID, cboVADatum (vom Parent frm_va_auftragstamm)
-- LinkChildFields: VA_ID, VADatum_ID
```

### HTML API-Anbindung
```javascript
// Endpoint
GET /api/zuordnungen/absagen?va_id=X&datum_id=Y

// Alternative (falls oben nicht existiert)
GET /api/auftraege/${va_id}/absagen?vadatum_id=${datum_id}

// Response-Mapping (erwartet)
{
  absagen: [
    {
      ID: number,
      VA_ID: number,
      VADatum_ID: number,
      MA_ID: number,
      Name: string,
      Absagedatum: datetime,    // Fehlt in HTML-Tabelle
      Absagegrund: string,
      MVA_Start: time,          // Für Beginn-Spalte
      MVA_Ende: time            // Für Ende-Spalte
    }
  ]
}

// Logic-Datei: sub_MA_VA_Planung_Absage.logic.js (5779 Bytes)
```

### ⚠️ API-Gaps
**PRÜFEN** - API Endpoint für Absagen muss implementiert sein
- Option 1: `/api/zuordnungen/absagen?va_id=X&datum_id=Y`
- Option 2: `/api/auftraege/:va_id/absagen?vadatum_id=Y`

## Priorität der Gaps

### P0 Kritisch (Blocker)
**KEINE**

### P1 Wichtig
1. **API Endpoint**: Sicherstellen dass Absagen-Endpoint existiert (3h)
   - Query auf qry_MA_Plan_Absage oder tbl_MA_VA_Planung WHERE Status_ID = 3 (Abgesagt)
   - JOIN mit tbl_MA_Mitarbeiterstamm für Name
2. **Absagedatum-Spalte**: Hinzufügen zur Tabelle (0.5h)
   - Feld existiert in Access
   - Nur Spalte fehlt in HTML

### P2 Nice-to-have
- **Restore-Funktion**: Absage rückgängig machen (3h)
- **Absagegrund-Details**: Popup mit vollständigem Grund (2h)
- **Filter**: Nach Mitarbeiter, Datum (2h)

## Empfehlung

### Completion
**95%** - Formular ist nahezu vollständig

### Kritische Gaps
Keine Blocker. API-Endpoint prüfen (P1), Absagedatum-Spalte fehlt (P1).

### Aufwand
- **P0**: 0 Stunden
- **P1**: ~3.5 Stunden (API + Spalte)
- **P2**: ~7 Stunden (optionale Features)
- **Gesamt**: ~3.5 Stunden (Pflicht)

### Nächste Schritte
1. **API prüfen**: `curl http://localhost:5000/api/zuordnungen/absagen?va_id=123&datum_id=456`
2. Falls API fehlt: Implementieren in api_server.py
3. **Absagedatum-Spalte**: Hinzufügen (0.5h)
4. ✅ **Freigabe erteilen** - Formular ist produktionsreif

### Parent-Formular
- **frm_va_auftragstamm** (LinkMasterFields: ID, cboVADatum → LinkChildFields: VA_ID, VADatum_ID)

### Besonderheit
**Master-Detail mit 2 Link-Feldern**: VA_ID + VADatum_ID
- Zeigt nur Absagen für gewählten Auftrag + gewählten Tag
- Logic-Datei vorhanden: sub_MA_VA_Planung_Absage.logic.js (5.8 KB)
