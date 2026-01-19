# Gap-Analyse: sub_DP_Grund_MA

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 5 | 8 | +3 | ✅ |
| Buttons | 0 | 1 | +1 | ✅ |
| TextBoxen | 5 | 3 (Spalten) | -2 | ⚠️ |
| ComboBoxen | 0 | 1 | +1 | ✅ |
| Events gesamt | 4 | 6 | +2 | ✅ |

**Completion:** 85%

## Controls-Vergleich

### ✅ Implementiert in HTML (5 von 5)
| Control | Access-Name | HTML-ID | Status |
|---------|-------------|---------|--------|
| MA_ID | MA_ID | state.MA_ID | ✅ (versteckt) |
| Datum | Datum | thead th (Spalte 1) | ✅ |
| Grund | Grund | thead th (Spalte 2) | ✅ |
| Bemerkung | Bemerkung | thead th (Spalte 3) | ✅ |
| Tag1_Name | Tag1_Name | - | ❌ (fehlt) |

### ❌ Fehlend in HTML (1 Control)
| Control | Access-Name | Typ | Funktion | Priorität |
|---------|-------------|-----|----------|-----------|
| Tag1_Name | Tag1_Name | TextBox | Tagesname (Mo, Di, ...) anzeigen | P1 |

### ➕ Zusätzliche Controls in HTML (3)
| Control | HTML-ID | Typ | Funktion |
|---------|---------|-----|----------|
| Filter-Button | btnFilter | Button | Filter-Toolbar ein/ausblenden |
| Filter-Dropdown | cboGrund | ComboBox | Nach Grund-Typ filtern |
| Toolbar | .subform-toolbar | Container | Filter-Bereich |

## Events-Vergleich

### ✅ Implementierte Events (4 von 4)
| Event | Access-Handler | HTML-Handler | Status |
|-------|----------------|--------------|--------|
| OnCurrent | Auto | selectRow() | ✅ |
| Row Click | - | addEventListener('click') | ✅ |
| Row DblClick | - | addEventListener('dblclick') | ✅ |
| AfterUpdate | - | postMessage('subform_selection') | ✅ |

### ➕ Zusätzliche Events in HTML (2)
| Event | HTML-Handler | Funktion |
|-------|--------------|----------|
| cboGrund.change | handleFilterChange() | Filter anwenden |
| btnFilter.click | toggleFilter() | Filter-Toolbar togglen |

### ❌ Fehlende Events (0 Events)
*Alle Access-Events implementiert + 2 zusätzliche*

## Funktionalität-Vergleich

### ✅ Implementierte Funktionen
- [x] MA-ID-basierte Filterung
- [x] Zeilen-Selektion (OnCurrent)
- [x] Doppelklick auf Zeile (Parent informieren)
- [x] Anzahl-Anzeige (lblAnzahl)
- [x] PostMessage-Kommunikation mit Parent
- [x] WebView2-Bridge Integration
- [x] Filter-Dropdown (Bonus-Feature)
- [x] Filter-Button (Bonus-Feature)

### ❌ Fehlende Funktionen
- [ ] Tagesname-Anzeige (Tag1_Name) (P1, 1h)
- [ ] API-Datenladen funktional (P0, 2-3h)
- [ ] Avatar/Card-Layout (aktuell ungenutzt) (P2, 1h)

## Datenanbindung

### Access
- **RecordSource:** qry_DP_Grund_MA
- **Master/Child Fields:** MA_ID (gefiltert)

### HTML
- **API-Endpoints:**
  - GET /api/dienstplan/gruende?ma_id=X (geplant)
- **PostMessage:** Parent ↔ Subform (implementiert)
- **WebView2 Bridge:** Bridge.sendEvent('loadSubformData', ...) (implementiert)

### ❌ Fehlende APIs
- [ ] GET /api/dienstplan/gruende?ma_id=X - Gefilterte Liste nach MA_ID (2h)

## Daten-Mapping (Access ↔ HTML)

### ✅ Korrekt gemappt
| Access-Feld | HTML-Feld | Typ | Status |
|-------------|-----------|-----|--------|
| MA_ID | state.MA_ID | Integer | ✅ |
| Datum | rec.Datum | Date | ✅ |
| Grund | rec.Grund_Bez | String | ✅ |
| Bemerkung | rec.Bemerkung | String | ✅ |

### ❌ Fehlende Felder
| Access-Feld | Typ | Status | Priorität |
|-------------|-----|--------|-----------|
| Tag1_Name | String | ❌ Nicht in Logic | P1 |

**SOLL-Code (Zeile 135-145 erweitern):**
```javascript
tbody.innerHTML = displayRecords.map((rec, idx) => {
    const datum = rec.Datum ? new Date(rec.Datum).toLocaleDateString('de-DE') : '';
    const tagesname = rec.Tag1_Name || '';  // ← NEU
    const selectedClass = idx === state.selectedIndex ? ' selected' : '';
    return `
        <tr data-id="${rec.ID}" data-index="${idx}" class="${selectedClass}">
            <td>${datum} <span style="color:#666;font-size:8px;">${tagesname}</span></td>
            <td>${rec.Grund_Bez || ''}</td>
            <td>${rec.Bemerkung || ''}</td>
        </tr>
    `;
}).join('');
```

## Layout-Diskrepanz

### HTML hat 2 Layout-Varianten:
1. **Tabellen-Layout** (aktuell verwendet, Zeile 119-131)
   - Passt zu Access Endlosformular
   - ✅ Funktional

2. **Card-Layout** (CSS vorhanden, aber ungenutzt, Zeile 42-88)
   - .ma-grund-item, .ma-avatar, .ma-info
   - Schöneres Design, aber nicht Access-konform
   - ⚠️ Nicht verwendet

**Empfehlung:** Tabellen-Layout beibehalten (Access-konform)

## Priorität der Gaps

### 🔴 Kritisch (P0) - Blocker
- [ ] API-Endpoint /api/dienstplan/gruende?ma_id=X implementieren (2h)

### 🟡 Wichtig (P1) - Core-Feature
- [ ] Tagesname (Tag1_Name) im Datum-Feld anzeigen (1h)
- [ ] Datum-Formatierung vollständig testen (0.5h)

### 🟢 Nice-to-have (P2)
- [ ] Card-Layout entfernen (ungenutzter CSS-Code) (0.5h)
- [ ] Avatar-Bereich entfernen (ungenutzter CSS-Code) (0.5h)
- [ ] Export-Funktion (1h)
- [ ] Sortierung nach Datum (0.5h)

## Empfehlung

**Completion:** 85%
**Kritische Gaps:** 1 (P0)
**Aufwand-Schätzung:** 3-4 Stunden

**Nächste Schritte:**
1. **API-Endpoint erstellen** (2h): /api/dienstplan/gruende?ma_id=X in api_server.py
2. **Tagesname hinzufügen** (1h): Tag1_Name im Datum-Feld anzeigen
3. **Ungenutzten CSS entfernen** (0.5h): Card-Layout und Avatar-Bereich (Optional)

**Bemerkung:**
Das Formular ist sehr gut umgesetzt und hat sogar **Bonus-Features** (Filter-Dropdown, Filter-Button). Die Haupt-Gaps sind:
1. API fehlt (Backend-Arbeit)
2. Tag1_Name fehlt in der Anzeige (kleine Logic-Änderung)

Die Filter-Funktionalität ist ein **Mehrwert** gegenüber Access und zeigt proaktives Design-Denken.
