# Gap-Analyse: frm_Rueckmeldestatistik

**Analysiert am:** 2026-01-12
**Access-Export:** forms3/Access_Abgleich/forms/zfrm_Rueckmeldungen.md
**HTML-Formular:** forms3/frm_Rueckmeldestatistik.html
**Logic-JS:** Keine separate Logic-Datei (inline)

---

## Executive Summary

### Formular-Umfang
- **Access Controls:** 11
  - 1 Subform (zsub_Rueckmeldungen) - Hauptkomponente
  - 4 TextBoxen (Filter nach Anstellungsart)
  - 6 Labels
  - Keine Buttons (nur Navigation)

### Implementierungsstatus
- **HTML-Struktur:** ✅ **Gut implementiert** (80%)
- **Statistik-Anzeige:** ✅ **Vollständig** (100%)
- **Tabellen-Darstellung:** ✅ **Gut** (85%)
- **API-Integration:** ⚠️ **Teilweise** (50%)
- **Filter-Funktionen:** ❌ **Fehlen komplett** (0%)

### Kritische Gaps
1. **Subform zsub_Rueckmeldungen** nicht als eigenständige Komponente implementiert
2. **Filter nach Anstellungsart** fehlt komplett
3. **API-Endpoint `/api/rueckmeldungen`** existiert nicht in api_server.py
4. **Export-Funktionen** (Excel, PDF) fehlen
5. **Drill-Down** zu einzelnen Mitarbeitern fehlt

---

## 1. FORMULAR-EIGENSCHAFTEN

### Access
```
Name: zfrm_Rueckmeldungen (z = Zusatz/Statistik)
RecordSource: zqry_Rueckmeldungen
AllowEdits: True
AllowAdditions: True
AllowDeletions: True
DataEntry: False
DefaultView: Other (Dashboard-Style)
NavigationButtons: False
Zweck: Statistik-Übersicht über Rückmeldungen von Mitarbeitern zu Anfragen
```

### HTML
```html
<!-- Kompakte Statistik-Ansicht -->
<div class="stat-grid">
    <div class="stat-card">Gesamt Anfragen</div>
    <div class="stat-card green">Zugesagt</div>
    <div class="stat-card red">Abgesagt</div>
    <div class="stat-card yellow">Offen</div>
</div>

<table class="data-table">
    <thead>
        <tr>
            <th>Mitarbeiter</th>
            <th>Angefragt am</th>
            <th>Rückmeldung</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody id="tableBody">...</tbody>
</table>
```

### Status: ✅ Struktur gut, aber vereinfacht
- HTML zeigt kompakte KPI-Karten + Tabelle
- Access verwendet großes Subform (22686 x 11406 Twips)
- HTML ist responsiver und übersichtlicher

---

## 2. HAUPTKOMPONENTE: SUBFORM

### Access: zsub_Rueckmeldungen

| Eigenschaft | Wert |
|-------------|------|
| **Name** | Untergeordnet19 (Source: zsub_Rueckmeldungen) |
| **Position** | 0 / 0 |
| **Größe** | 22686 x 11406 Twips (ca. 40cm x 20cm) |
| **Zweck** | Hauptdaten-Anzeige |

**Vermutliche Struktur (nicht exportiert):**
- Tabellarische Ansicht mit Spalten:
  - MA_ID, Nachname, Vorname
  - Angefragt_am (Datum)
  - Rueckmeldung_am (Datum)
  - Status (Zugesagt/Abgesagt/Offen)
  - Bemerkungen

### HTML: Inline Table

```html
<!-- ✅ VORHANDEN: Einfache Tabelle -->
<table class="data-table">
    <thead>
        <tr>
            <th>Mitarbeiter</th>
            <th>Angefragt am</th>
            <th>Rückmeldung</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody id="tableBody">
        <!-- Dynamisch gefüllt via API -->
    </tbody>
</table>
```

**Gap:** Subform als eigenständige Komponente fehlt

```javascript
// ❌ EMPFOHLEN: Eigenständiges Subform
// File: sub_Rueckmeldungen.html
<iframe src="sub_Rueckmeldungen.html?va_id=12345"></iframe>

// Mit Features:
// - Sortierung nach Spalten
// - Filter nach Status
// - Export als Excel/CSV
// - Drill-Down zu MA-Details
```

---

## 3. STATISTIK-KARTEN

### HTML (Gut implementiert ✅)

| Karte | Access | HTML | Status |
|-------|--------|------|--------|
| **Gesamt** | - | ✅ `#statGesamt` | ✅ Implementiert |
| **Zugesagt** | - | ✅ `#statZugesagt` (grün) | ✅ Implementiert |
| **Abgesagt** | - | ✅ `#statAbgesagt` (rot) | ✅ Implementiert |
| **Offen** | - | ✅ `#statOffen` (gelb) | ✅ Implementiert |

**Berechnung (korrekt):**
```javascript
const zugesagt = items.filter(i => i.status === 'zugesagt').length;
const abgesagt = items.filter(i => i.status === 'abgesagt').length;
const offen = items.filter(i => !i.status || i.status === 'offen').length;
```

**Farben:**
- Grün (#208020): Zugesagt ✅
- Rot (#c04040): Abgesagt ✅
- Gelb (#c0a000): Offen ✅

---

## 4. FILTER (4 TextBoxen)

### Access

| Control | ControlSource | Zweck |
|---------|---------------|-------|
| **Anstellungsart_ID** | Anstellungsart_ID | Filter nach Anstellungsart |
| **Text23** | Anstellungsart_ID | Filter nach Anstellungsart |
| **Text25** | Anstellungsart_ID | Filter nach Anstellungsart |
| **Text27** | Anstellungsart_ID | Filter nach Anstellungsart |

**Vermutung:** 4 identische Filter-Felder für verschiedene Tabs/Bereiche

### HTML

```html
<!-- ❌ FEHLT KOMPLETT: Kein Filter vorhanden -->

<!-- EMPFOHLEN: Filter-Toolbar -->
<div class="toolbar">
    <span>Auftrag-ID: <strong id="va_id_display">-</strong></span>

    <!-- NEU: Filter -->
    <label>Status:</label>
    <select id="filterStatus">
        <option value="">Alle</option>
        <option value="zugesagt">Zugesagt</option>
        <option value="abgesagt">Abgesagt</option>
        <option value="offen">Offen</option>
    </select>

    <label>Anstellungsart:</label>
    <select id="filterAnstellungsart">
        <option value="">Alle</option>
        <option value="3">Freie MA</option>
        <option value="5">Honorarkräfte</option>
        <option value="1">Festangestellte</option>
    </select>

    <button onclick="loadStatistik()">Aktualisieren</button>
    <button onclick="exportExcel()">Excel Export</button>
</div>
```

---

## 5. API-INTEGRATION

### API-Endpoint (❌ FEHLT in api_server.py)

```python
# ❌ FEHLT: /api/rueckmeldungen Endpoint

@app.route('/api/rueckmeldungen', methods=['GET'])
def get_rueckmeldungen():
    """
    Rückmeldungen zu Anfragen abrufen

    Parameter:
        va_id (int): Auftrags-ID (optional)
        vadatum_id (int): Einsatztag-ID (optional)
        vastart_id (int): Schicht-ID (optional)
        status (str): Filter nach Status (zugesagt/abgesagt/offen)
        anstellungsart (int): Filter nach Anstellungsart
    """
    va_id = request.args.get('va_id', type=int)
    vadatum_id = request.args.get('vadatum_id', type=int)
    vastart_id = request.args.get('vastart_id', type=int)
    status = request.args.get('status', '')
    anstellungsart = request.args.get('anstellungsart', type=int)

    # SQL Query
    sql = """
        SELECT
            a.ID,
            a.VA_ID,
            a.VADatum_ID,
            a.VAStart_ID,
            a.MA_ID,
            m.Nachname,
            m.Vorname,
            m.Anstellungsart_ID,
            a.Angefragt_am,
            a.Rueckmeldung_am,
            a.Status,
            a.Bemerkungen
        FROM tbl_MA_Anfragen a
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON a.MA_ID = m.ID
        WHERE 1=1
    """

    params = []

    if va_id:
        sql += " AND a.VA_ID = ?"
        params.append(va_id)

    if vadatum_id:
        sql += " AND a.VADatum_ID = ?"
        params.append(vadatum_id)

    if vastart_id:
        sql += " AND a.VAStart_ID = ?"
        params.append(vastart_id)

    if status:
        if status == 'offen':
            sql += " AND (a.Status IS NULL OR a.Status = '')"
        else:
            sql += " AND a.Status = ?"
            params.append(status)

    if anstellungsart:
        sql += " AND m.Anstellungsart_ID = ?"
        params.append(anstellungsart)

    sql += " ORDER BY a.Angefragt_am DESC, m.Nachname, m.Vorname"

    cursor = get_db_cursor()
    cursor.execute(sql, params)

    rows = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]

    data = []
    for row in rows:
        item = dict(zip(columns, row))
        # Formatierung
        item['mitarbeiter'] = f"{item['Nachname']}, {item['Vorname']}"
        item['angefragt_am'] = format_date(item['Angefragt_am'])
        item['rueckmeldung_am'] = format_date(item['Rueckmeldung_am'])
        item['status'] = item['Status'] or 'offen'
        data.append(item)

    return jsonify({'data': data, 'count': len(data)})
```

### HTML API-Call (aktuell)

```javascript
// ⚠️ VORHANDEN: Aber API existiert nicht
async function loadStatistik() {
    const response = await fetch(`${API}/rueckmeldungen?va_id=${va_id}`);
    const data = await response.json();
    const items = data.data || data || [];

    // Statistik berechnen
    const zugesagt = items.filter(i => i.status === 'zugesagt').length;
    const abgesagt = items.filter(i => i.status === 'abgesagt').length;
    const offen = items.filter(i => !i.status || i.status === 'offen').length;

    // KPIs aktualisieren
    document.getElementById('statGesamt').textContent = items.length;
    document.getElementById('statZugesagt').textContent = zugesagt;
    document.getElementById('statAbgesagt').textContent = abgesagt;
    document.getElementById('statOffen').textContent = offen;

    // Tabelle füllen
    renderTable(items);
}
```

---

## 6. EVENTS

### Formular-Events

| Event | Access | HTML | Status |
|-------|--------|------|--------|
| **OnLoad** | Procedure | DOMContentLoaded | ✅ Implementiert |
| **OnClose** | Procedure | - | N/A (Web-Kontext) |

**Access OnLoad/OnClose:**
Vermutlich Initialisierung der Subform und Filter-Einstellungen

### HTML (inline Script)

```javascript
// ✅ VORHANDEN: Auto-Load bei DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    const va_id = params.get('va_id');
    document.getElementById('va_id_display').textContent = va_id || '-';
    loadStatistik();
});
```

---

## 7. ZUSÄTZLICHE FEATURES (fehlen)

### Export-Funktionen

```javascript
// ❌ FEHLT: Excel-Export
function exportExcel() {
    const table = document.querySelector('.data-table');
    const workbook = XLSX.utils.table_to_book(table, { sheet: "Rückmeldungen" });
    XLSX.writeFile(workbook, `Rueckmeldungen_${va_id}_${Date.now()}.xlsx`);
}

// ❌ FEHLT: PDF-Export
function exportPDF() {
    window.print(); // Vereinfachte Version
}
```

### Drill-Down

```javascript
// ❌ FEHLT: Klick auf Mitarbeiter -> MA-Stamm öffnen
document.querySelector('.data-table tbody').addEventListener('click', (e) => {
    const row = e.target.closest('tr');
    if (row) {
        const ma_id = row.dataset.maId;
        if (ma_id) {
            window.parent.postMessage({
                type: 'OPEN_FORM',
                form: 'frm_MA_Mitarbeiterstamm',
                id: ma_id
            }, '*');
        }
    }
});
```

### Sortierung

```javascript
// ❌ FEHLT: Spalten-Sortierung
document.querySelectorAll('.data-table th').forEach((th, index) => {
    th.style.cursor = 'pointer';
    th.addEventListener('click', () => {
        sortTableByColumn(index);
    });
});
```

---

## 8. FARBEN & STYLING

### Access
- Labels: 8355711 (Grau)
- TextBoxen: 4210752 (Dunkelgrau)
- BackColor: 16777215 (Weiß)
- BorderColor: 10921638 (Hellgrau)

### HTML
- Stat-Cards:
  - Standard: #000080 (Blau)
  - Grün (Zugesagt): #208020 ✅
  - Rot (Abgesagt): #c04040 ✅
  - Gelb (Offen): #c0a000 ✅
- Background: #8080c0 (Access-Style Lila) ✅
- Toolbar: #c0c0c0 (Access-Grau) ✅

**Status:** ✅ Farben korrekt übernommen

---

## 9. COMPLETION-ANALYSE

### Controls (11 gesamt)

| Typ | Access | HTML | Implementiert | Prozent |
|-----|--------|------|---------------|---------|
| Subform | 1 | 0 (Inline Table) | Vereinfacht | 70% |
| TextBox (Filter) | 4 | 0 | ❌ Fehlt | 0% |
| Labels | 6 | 2 (Stat-Cards) | ✅ Besser | 100% |
| **GESAMT** | **11** | **2 + Table** | **Vereinfacht** | **60%** |

### Funktionalität

| Feature | Status | Prozent |
|---------|--------|---------|
| Statistik-KPIs | ✅ Vollständig | 100% |
| Tabellen-Darstellung | ✅ Gut (ohne Sortierung) | 85% |
| API-Integration | ❌ Endpoint fehlt | 0% |
| Filter (Anstellungsart) | ❌ Fehlt komplett | 0% |
| Filter (Status) | ❌ Fehlt komplett | 0% |
| Export (Excel) | ❌ Fehlt komplett | 0% |
| Export (PDF) | ❌ Fehlt komplett | 0% |
| Drill-Down zu MA | ❌ Fehlt komplett | 0% |
| Sortierung | ❌ Fehlt komplett | 0% |
| **GESAMT** | | **21%** |

**Hinweis:** HTML zeigt bessere UX (KPI-Karten), aber weniger Funktionalität als Access.

---

## 10. AUFWAND-SCHÄTZUNG

### Quick Wins (2-4 Stunden)
1. **API-Endpoint `/api/rueckmeldungen`** implementieren - 3h
2. **Filter Status** hinzufügen (Dropdown) - 1h

### Medium Effort (4-8 Stunden)
3. **Filter Anstellungsart** hinzufügen - 1h
4. **Spalten-Sortierung** implementieren - 3h
5. **Excel-Export** mit XLSX.js - 2h

### Low Priority (4-8 Stunden)
6. **Drill-Down zu MA-Stamm** - 2h
7. **PDF-Export** (Print-Funktion) - 1h
8. **Subform als eigenständige Komponente** - 4h

**Gesamt-Aufwand:** 17 Stunden

---

## 11. PRIORITÄTEN

### P1 - Kritisch (Blockiert Produktivbetrieb)
1. ❌ API-Endpoint `/api/rueckmeldungen` implementieren
2. ✅ Statistik-KPIs (ERLEDIGT)
3. ✅ Tabellen-Darstellung (ERLEDIGT)

### P2 - Wichtig (Workflow-Verbesserung)
4. ❌ Filter nach Status
5. ❌ Filter nach Anstellungsart
6. ❌ Spalten-Sortierung

### P3 - Nice-to-Have
7. ❌ Excel-Export
8. ❌ Drill-Down zu MA
9. ❌ Subform-Komponente

---

## 12. DATENMODELL

### Vermutete Tabellen (nicht im Export)

```sql
-- tbl_MA_Anfragen (vermutlich)
CREATE TABLE tbl_MA_Anfragen (
    ID INTEGER PRIMARY KEY,
    VA_ID INTEGER,           -- Auftrags-ID
    VADatum_ID INTEGER,      -- Einsatztag-ID
    VAStart_ID INTEGER,      -- Schicht-ID
    MA_ID INTEGER,           -- Mitarbeiter-ID
    Angefragt_am DATETIME,   -- Wann wurde angefragt?
    Rueckmeldung_am DATETIME,-- Wann kam Rückmeldung?
    Status TEXT,             -- 'zugesagt', 'abgesagt', NULL/'' = offen
    Bemerkungen TEXT
);

-- zqry_Rueckmeldungen (vermutlich)
SELECT
    a.*,
    m.Nachname,
    m.Vorname,
    m.Anstellungsart_ID,
    v.Auftrag AS Auftragsname,
    vd.VADatum AS Einsatzdatum,
    vs.VA_Start AS Schichtbeginn
FROM tbl_MA_Anfragen a
INNER JOIN tbl_MA_Mitarbeiterstamm m ON a.MA_ID = m.ID
LEFT JOIN tbl_VA_Auftragstamm v ON a.VA_ID = v.ID
LEFT JOIN tbl_VA_AnzTage vd ON a.VADatum_ID = vd.ID
LEFT JOIN tbl_VA_Start vs ON a.VAStart_ID = vs.ID
WHERE a.VA_ID = ?
ORDER BY a.Angefragt_am DESC, m.Nachname;
```

---

## 13. TESTDATEN

### Beispiel-Response (wenn API implementiert)

```json
{
    "data": [
        {
            "ID": 1001,
            "VA_ID": 12345,
            "VADatum_ID": 67890,
            "VAStart_ID": 111,
            "MA_ID": 234,
            "mitarbeiter": "Müller, Hans",
            "angefragt_am": "2026-01-10",
            "rueckmeldung_am": "2026-01-11",
            "status": "zugesagt",
            "bemerkungen": ""
        },
        {
            "ID": 1002,
            "VA_ID": 12345,
            "VADatum_ID": 67890,
            "VAStart_ID": 111,
            "MA_ID": 235,
            "mitarbeiter": "Schmidt, Anna",
            "angefragt_am": "2026-01-10",
            "rueckmeldung_am": "2026-01-10",
            "status": "abgesagt",
            "bemerkungen": "Urlaub"
        },
        {
            "ID": 1003,
            "VA_ID": 12345,
            "VADatum_ID": 67890,
            "VAStart_ID": 111,
            "MA_ID": 236,
            "mitarbeiter": "Weber, Lisa",
            "angefragt_am": "2026-01-10",
            "rueckmeldung_am": null,
            "status": "offen",
            "bemerkungen": ""
        }
    ],
    "count": 3
}
```

---

## 14. FAZIT

### Stärken
- ✅ **UX-Verbesserung:** KPI-Karten statt reiner Tabelle
- ✅ **Kompakte Darstellung:** Übersichtlicher als Access-Subform
- ✅ **Styling:** Korrekte Farben und Access-Look
- ✅ **Responsive:** Funktioniert auf verschiedenen Bildschirmgrößen

### Schwächen
- ❌ **Keine API:** Endpoint `/api/rueckmeldungen` fehlt komplett
- ❌ **Keine Filter:** Weder Status noch Anstellungsart
- ❌ **Keine Interaktivität:** Sortierung, Export, Drill-Down fehlen
- ❌ **Keine Subform-Komponente:** Alles inline, nicht wiederverwendbar

### Empfehlung
**Formular ist zu 60% funktionsfähig** als Statistik-Anzeige, aber **nicht production-ready** ohne API-Endpoint und Filter-Funktionen.

**Nächste Schritte:**
1. API-Endpoint `/api/rueckmeldungen` implementieren (3h) - KRITISCH
2. Filter Status + Anstellungsart hinzufügen (2h)
3. Spalten-Sortierung implementieren (3h)
4. Excel-Export hinzufügen (2h)

**Nach diesen Fixes:** 85% Completion, production-ready für Standard-Workflow.

**Design-Entscheidung:**
HTML-Version ist besser als Access (KPI-Karten), sollte beibehalten werden. Subform als separate Komponente ist optional (P3).
