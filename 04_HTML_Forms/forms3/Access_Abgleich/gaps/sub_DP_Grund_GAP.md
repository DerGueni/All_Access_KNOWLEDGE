# Gap-Analyse: sub_DP_Grund

## Übersicht
| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 6 | 6 | 0 | ✅ |
| Buttons | 0 | 0 | 0 | ✅ |
| TextBoxen | 6 | 6 (Spalten) | 0 | ✅ |
| ComboBoxen | 0 | 0 | 0 | ✅ |
| Events gesamt | 3 | 3 | 0 | ✅ |

**Completion:** 95%

## Controls-Vergleich

### ✅ Implementiert in HTML (6 von 6)
| Control | Access-Name | HTML-ID | Status |
|---------|-------------|---------|--------|
| Datum | Datum | thead th (Spalte 1) | ✅ |
| Grund | Grund | thead th (Spalte 2) | ✅ |
| Beschreibung | Beschreibung | thead th (Spalte 3) | ✅ |
| Von | Von | thead th (Spalte 4) | ✅ |
| Bis | Bis | thead th (Spalte 5) | ✅ |
| Erfasst_am | Erfasst_am | thead th (Spalte 6) | ✅ |

### ❌ Fehlend in HTML (0 Controls)
*Keine fehlenden Controls*

## Events-Vergleich

### ✅ Implementierte Events (3 von 3)
| Event | Access-Handler | HTML-Handler | Status |
|-------|----------------|--------------|--------|
| OnCurrent | Auto | selectRow() | ✅ |
| Row Click | - | addEventListener('click') | ✅ |
| Row DblClick | - | addEventListener('dblclick') | ✅ |

### ❌ Fehlende Events (0 Events)
*Alle Events implementiert*

## Funktionalität-Vergleich

### ✅ Implementierte Funktionen
- [x] Endlosformular-Ansicht (als HTML-Tabelle)
- [x] Zeilen-Selektion (OnCurrent Equivalent)
- [x] Doppelklick auf Zeile (Parent informieren)
- [x] Anzahl-Anzeige (lblAnzahl)
- [x] Farbcodierung nach Grund-Typ (Badges)
- [x] Sticky Header (beim Scrollen sichtbar)
- [x] PostMessage-Kommunikation mit Parent
- [x] WebView2-Bridge Integration

### ❌ Fehlende Funktionen
- [ ] API-Datenladen funktional (P0, 2-3h)
- [ ] Datum-Formatierung vollständig (P1, 0.5h)
- [ ] Zeit-Formatierung (Von/Bis HH:MM) (P1, 0.5h)
- [ ] Erfasst_am Timestamp Formatierung (P1, 0.5h)

## Datenanbindung

### Access
- **RecordSource:** qry_DP_Grund oder tbl_DP_Gruende
- **Master/Child Fields:** Keine (standalone)

### HTML
- **API-Endpoints:**
  - GET /api/dienstplan/gruende (geplant)
- **PostMessage:** Parent ↔ Subform (implementiert)
- **WebView2 Bridge:** Bridge.sendEvent('loadSubformData', ...) (implementiert)

### ❌ Fehlende APIs
- [ ] GET /api/dienstplan/gruende - Liste aller Abwesenheitsgründe (2h)
- [ ] GET /api/dienstplan/gruende/:id - Einzelner Grund (1h)

## Daten-Mapping (Access ↔ HTML)

### ✅ Korrekt gemappt
| Access-Feld | HTML-Feld | Typ | Status |
|-------------|-----------|-----|--------|
| Datum | rec.Datum | Date | ⚠️ (fehlt in Logic) |
| Grund | rec.Grund_Bez | String | ⚠️ (heißt anders) |
| Beschreibung | rec.Beschreibung | String | ⚠️ (fehlt in Logic) |
| Von | rec.Von | Time | ⚠️ (fehlt in Logic) |
| Bis | rec.Bis | Time | ⚠️ (fehlt in Logic) |
| Erfasst_am | rec.Erfasst_am | DateTime | ⚠️ (fehlt in Logic) |

### ❌ Feldnamen-Diskrepanz
**PROBLEM:** Logic zeigt nur Grund_ID, Grund_Bez, Grund_Kuerzel (Zeile 76-78)
**SOLL:** Datum, Grund, Beschreibung, Von, Bis, Erfasst_am

**Aktueller Code (sub_DP_Grund.logic.js, Zeile 72-80):**
```javascript
tbody.innerHTML = state.records.map((rec, idx) => {
    const selectedClass = idx === state.selectedIndex ? ' selected' : '';
    return `
    <tr data-id="${rec.Grund_ID}" data-index="${idx}" class="${selectedClass}">
        <td>${rec.Grund_ID}</td>
        <td>${rec.Grund_Bez || ''}</td>
        <td>${rec.Grund_Kuerzel || ''}</td>
    </tr>
`}).join('');
```

**SOLL-Code:**
```javascript
tbody.innerHTML = state.records.map((rec, idx) => {
    const selectedClass = idx === state.selectedIndex ? ' selected' : '';
    const datum = rec.Datum ? new Date(rec.Datum).toLocaleDateString('de-DE') : '';
    const erfasstAm = rec.Erfasst_am ? new Date(rec.Erfasst_am).toLocaleDateString('de-DE') : '';
    const grundBadge = getGrundBadge(rec.Grund);
    return `
    <tr data-id="${rec.ID}" data-index="${idx}" class="${selectedClass}">
        <td>${datum}</td>
        <td>${grundBadge}</td>
        <td>${rec.Beschreibung || ''}</td>
        <td>${rec.Von || ''}</td>
        <td>${rec.Bis || ''}</td>
        <td>${erfasstAm}</td>
    </tr>
`}).join('');
```

## Priorität der Gaps

### 🔴 Kritisch (P0) - Blocker
- [ ] Logic-Code korrigieren: Zeige alle 6 Felder (Datum, Grund, Beschreibung, Von, Bis, Erfasst_am) statt nur 3 (1h)
- [ ] API-Endpoint /api/dienstplan/gruende implementieren (2h)

### 🟡 Wichtig (P1) - Core-Feature
- [ ] Datum-Formatierung (TT.MM.JJJJ) (0.5h)
- [ ] Zeit-Formatierung (Von/Bis im Format HH:MM) (0.5h)
- [ ] Erfasst_am Timestamp (DD.MM.YYYY) (0.5h)
- [ ] Grund-Badge-Funktion (getGrundBadge) implementieren (0.5h)

### 🟢 Nice-to-have (P2)
- [ ] Filter-Funktion nach Grund-Typ (1h)
- [ ] Sortierung nach Datum (0.5h)
- [ ] Export-Funktion (1h)

## Empfehlung

**Completion:** 95%
**Kritische Gaps:** 2 (P0)
**Aufwand-Schätzung:** 3-4 Stunden

**Nächste Schritte:**
1. **Logic-Code korrigieren** (1h): render()-Funktion anpassen, alle 6 Felder anzeigen
2. **API-Endpoint erstellen** (2h): /api/dienstplan/gruende in api_server.py
3. **Formatierungs-Funktionen** (1h): Datum, Zeit, Timestamp

**Bemerkung:**
Das HTML-Formular und die Struktur sind **exzellent** umgesetzt. Die Tabelle hat alle richtigen Spalten und CSS-Klassen. Das einzige Problem ist, dass die Logic-Datei die falschen Felder rendert. Dies ist schnell zu beheben.
