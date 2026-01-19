# Gap-Analyse: frm_Umsatzuebersicht_2

**Datum:** 2026-01-12
**Status:** HTML Placeholder vorhanden (nur Platzhalter)
**Priorität:** MITTEL (Statistik/Reporting)

---

## Zusammenfassung

Dieses Formular zeigt eine **Umsatzübersicht** mit folgenden Daten:
- Rechnungsdatum, Kunde, Veranstaltung
- PLZ, Ort, Auftrag
- Umsatz-Kategorien: Arbeit, Fahrtkosten, Bänder
- Rechnungsnummer, Summe Netto
- VA_ID und String-Referenz

**Besonderheit:** SplitForm-View (Formular + Tabelle gleichzeitig), ideal für Statistik-Auswertungen.

---

## 1. Datenquelle

### Access (Original)
- **Query:** `_Umsatz_Gesamt`
- **View:** SplitForm (Formular oben, Tabelle unten)
- **Felder:** 14 Spalten (siehe unten)

### HTML (Aktuell)
- **Status:** Nur Platzhalter ("HTML-Version in Entwicklung")
- **Gap:** Keine funktionale Implementierung

### Erforderlich
```javascript
// Endpoints
GET /api/umsatz/gesamt              // Alle Umsätze
GET /api/umsatz/gesamt?jahr=2026    // Gefiltert nach Jahr
GET /api/umsatz/gesamt?kunde=123    // Gefiltert nach Kunde
GET /api/umsatz/statistik           // Aggregierte Daten für Charts
```

**Query-Definition (angenommen):**
```sql
SELECT
    r.ID AS ID1,
    r.RechNr AS ID,
    r.ReDat AS ReDat,
    k.kun_Firma AS Kunde,
    k.ID AS kun_ID,
    k.PLZ,
    k.Ort AS ORT,
    va.Auftrag AS Veranstaltung,
    r.Arbeit,
    r.Fahrtkosten AS Fk,
    r.Baender,
    r.RchNr,
    r.Summe_Netto,
    r.VA_ID,
    va.Auftrag AS strVA
FROM tbl_RCH_Rechnung r
LEFT JOIN tbl_KD_Kundenstamm k ON r.kun_ID = k.ID
LEFT JOIN tbl_VA_Auftragstamm va ON r.VA_ID = va.ID
ORDER BY r.ReDat DESC
```

---

## 2. Controls / UI-Elemente

### Access-Controls (14 TextBoxen)

| Name | Control Source | Position | Größe | Funktion | Status HTML |
|------|----------------|----------|-------|----------|-------------|
| ID1 | ID1 | 5355, 390 | 4785 x 390 | Rechnung-ID (interne) | ❌ Fehlt |
| ID | ID | 5355, 375 | 4785 x 390 | Rechnung-Nummer | ❌ Fehlt |
| ReDat | ReDat | 5355, 945 | 4785 x 390 | Rechnungsdatum | ❌ Fehlt |
| Kunde | Kunde | 5355, 1515 | 4785 x 390 | Kundenname | ❌ Fehlt |
| kun_ID | kun_ID | 5355, 2085 | 4785 x 390 | Kunden-ID | ❌ Fehlt |
| PLZ | PLZ | 5355, 2655 | 4785 x 390 | Postleitzahl | ❌ Fehlt |
| ORT | ORT | 5355, 3225 | 4785 x 390 | Ort | ❌ Fehlt |
| Veranstaltung | Veranstaltung | 5355, 3795 | 4785 x 390 | Auftrag/Event | ❌ Fehlt |
| Arbeit | Arbeit | 5355, 4365 | 4785 x 390 | Arbeitsumsatz | ❌ Fehlt |
| Fk | Fk | 5355, 4935 | 4785 x 390 | Fahrtkosten | ❌ Fehlt |
| Bänder | Bänder | 5355, 5505 | 4785 x 390 | Bänder-Umsatz | ❌ Fehlt |
| RchNr | RchNr | 5355, 6075 | 4785 x 390 | Rechnungsnummer | ❌ Fehlt |
| Summe_Netto | Summe_Netto | 5355, 6645 | 4785 x 390 | Gesamt-Netto | ❌ Fehlt |
| VA_ID | VA_ID | 5355, 7215 | 4785 x 390 | Auftrags-ID | ❌ Fehlt |
| strVA | strVA | 5355, 7785 | 4785 x 390 | Auftrag-String | ❌ Fehlt |

**Hinweis:** Alle Controls sind TextBoxen (ReadOnly, da Query-basiert).

### HTML (Empfohlen)
Statt einzelner TextBoxen → **Tabelle mit Aggregation + Charts**

---

## 3. Layout und UI-Konzept

### Access-Layout (SplitForm)
```
+------------------------------------------------------------+
| Umsatzübersicht                                            |
+------------------------------------------------------------+
| FORMULAR-VIEW (Detail-Ansicht eines Datensatzes)           |
| ID: [123]          ReDat: [14.01.2026]                     |
| Kunde: [Musterfirma GmbH]    kun_ID: [456]                |
| PLZ: [60000]       ORT: [Frankfurt]                        |
| Veranstaltung: [Eventname 2026]                            |
| Arbeit: [5.432,00 €]   Fk: [234,00 €]  Bänder: [123,00 €] |
| RchNr: [RE-2026-123]   Summe Netto: [5.789,00 €]          |
| VA_ID: [789]       strVA: [Eventname]                      |
+------------------------------------------------------------+
| DATASHEET-VIEW (Tabellen-Ansicht)                          |
| ReDat      | Kunde         | Veranstaltung  | Summe       |
|------------|---------------|----------------|-------------|
| 14.01.2026 | Musterfirma   | Event A        | 5.789,00 €  |
| 13.01.2026 | Beispiel AG   | Event B        | 3.456,00 €  |
| ...        | ...           | ...            | ...         |
+------------------------------------------------------------+
```

### HTML-Layout (Empfohlen: Dashboard-Style)
```html
<div class="umsatz-dashboard">
  <!-- KPIs (Key Performance Indicators) -->
  <div class="kpi-cards">
    <div class="kpi-card">
      <h3>Gesamt-Umsatz</h3>
      <div class="kpi-value">245.678,00 €</div>
      <div class="kpi-change">+12,5% ↗</div>
    </div>
    <div class="kpi-card">
      <h3>Ø pro Auftrag</h3>
      <div class="kpi-value">4.523,00 €</div>
    </div>
    <div class="kpi-card">
      <h3>Anzahl Rechnungen</h3>
      <div class="kpi-value">54</div>
    </div>
  </div>

  <!-- Filter -->
  <div class="filter-bar">
    <select id="jahrFilter">
      <option>2026</option>
      <option>2025</option>
    </select>
    <select id="kundeFilter">
      <option value="">Alle Kunden</option>
      <!-- Dynamisch gefüllt -->
    </select>
    <button onclick="applyFilter()">Filtern</button>
    <button onclick="exportExcel()">Excel-Export</button>
  </div>

  <!-- Chart -->
  <div class="chart-container">
    <canvas id="umsatzChart"></canvas>
  </div>

  <!-- Detailtabelle -->
  <table class="umsatz-table">
    <thead>
      <tr>
        <th>Datum</th>
        <th>Kunde</th>
        <th>Veranstaltung</th>
        <th>Arbeit</th>
        <th>Fahrtkosten</th>
        <th>Bänder</th>
        <th>Summe Netto</th>
        <th>Rechnung</th>
      </tr>
    </thead>
    <tbody id="umsatzRows">
      <!-- Dynamisch gefüllt -->
    </tbody>
    <tfoot>
      <tr>
        <th colspan="3">Gesamt:</th>
        <th id="sumArbeit">0,00 €</th>
        <th id="sumFk">0,00 €</th>
        <th id="sumBaender">0,00 €</th>
        <th id="sumGesamt">0,00 €</th>
        <th></th>
      </tr>
    </tfoot>
  </table>
</div>
```

---

## 4. Funktionale Gaps

### ❌ FEHLT: Daten-Tabelle
- **Access:** SplitForm mit Formular + Datasheet
- **HTML:** Nur Platzhalter, keine Tabelle
- **Lösung:** DataGrid mit Paginierung

### ❌ FEHLT: Aggregation/Summen
- **Access:** Implizit durch Form-Footer möglich
- **HTML:** Muss explizit berechnet werden
```javascript
function calculateTotals(data) {
    return {
        arbeit: data.reduce((sum, row) => sum + row.Arbeit, 0),
        fk: data.reduce((sum, row) => sum + row.Fk, 0),
        baender: data.reduce((sum, row) => sum + row.Baender, 0),
        gesamt: data.reduce((sum, row) => sum + row.Summe_Netto, 0)
    };
}
```

### ❌ FEHLT: Filter-Funktion
- **Access:** Access Filter-Leiste
- **HTML:** Benötigt eigene Filter-UI
```javascript
function applyFilter() {
    const jahr = document.getElementById('jahrFilter').value;
    const kunde = document.getElementById('kundeFilter').value;
    loadUmsatzData({ jahr, kunde });
}
```

### ❌ FEHLT: Charts/Visualisierung
- **Access:** Keine Charts
- **HTML:** Sollte Charts haben (Balken, Linien, Pie)
```javascript
// Chart.js Integration
const ctx = document.getElementById('umsatzChart').getContext('2d');
new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ['Jan', 'Feb', 'Mär', ...],
        datasets: [{
            label: 'Umsatz pro Monat',
            data: [12000, 15000, 18000, ...],
            backgroundColor: '#4CAF50'
        }]
    }
});
```

### ❌ FEHLT: Excel-Export
- **Access:** Kann direkt nach Excel exportieren
- **HTML:** Benötigt Export-Funktion
```javascript
function exportExcel() {
    const data = getCurrentData();
    const csv = convertToCSV(data);
    downloadCSV(csv, 'umsatz.csv');
}
```

### ❌ FEHLT: Währungsformatierung
- **Access:** Automatisch durch Currency-Format
- **HTML:** Manuell via Intl.NumberFormat
```javascript
function formatEuro(value) {
    return new Intl.NumberFormat('de-DE', {
        style: 'currency',
        currency: 'EUR'
    }).format(value);
}
```

---

## 5. API-Anforderungen

### Neue Endpoints (Backend)

```python
# api_server.py

@app.route('/api/umsatz/gesamt', methods=['GET'])
def get_umsatz_gesamt():
    """Umsatzübersicht mit Filter"""
    jahr = request.args.get('jahr')
    kunde = request.args.get('kunde')

    sql = """
        SELECT
            r.ID AS ID1,
            r.RchNr AS ID,
            r.ReDat,
            k.kun_Firma AS Kunde,
            k.ID AS kun_ID,
            k.PLZ,
            k.Ort AS ORT,
            va.Auftrag AS Veranstaltung,
            r.Arbeit,
            r.Fahrtkosten AS Fk,
            r.Baender,
            r.RchNr,
            r.Summe_Netto,
            r.VA_ID,
            va.Auftrag AS strVA
        FROM tbl_RCH_Rechnung r
        LEFT JOIN tbl_KD_Kundenstamm k ON r.kun_ID = k.ID
        LEFT JOIN tbl_VA_Auftragstamm va ON r.VA_ID = va.ID
        WHERE 1=1
    """
    params = []

    if jahr:
        sql += " AND strftime('%Y', r.ReDat) = ?"
        params.append(jahr)

    if kunde:
        sql += " AND r.kun_ID = ?"
        params.append(kunde)

    sql += " ORDER BY r.ReDat DESC"

    cursor.execute(sql, params)
    return jsonify(cursor.fetchall())

@app.route('/api/umsatz/statistik', methods=['GET'])
def get_umsatz_statistik():
    """Aggregierte Statistiken für Charts"""
    jahr = request.args.get('jahr', datetime.now().year)

    # Monatliche Aggregation
    cursor.execute("""
        SELECT
            strftime('%m', ReDat) AS Monat,
            SUM(Arbeit) AS Arbeit,
            SUM(Fahrtkosten) AS Fk,
            SUM(Baender) AS Baender,
            SUM(Summe_Netto) AS Gesamt,
            COUNT(*) AS Anzahl
        FROM tbl_RCH_Rechnung
        WHERE strftime('%Y', ReDat) = ?
        GROUP BY strftime('%m', ReDat)
        ORDER BY Monat
    """, (str(jahr),))
    monthly = cursor.fetchall()

    # Top-Kunden
    cursor.execute("""
        SELECT
            k.kun_Firma AS Kunde,
            SUM(r.Summe_Netto) AS Umsatz
        FROM tbl_RCH_Rechnung r
        LEFT JOIN tbl_KD_Kundenstamm k ON r.kun_ID = k.ID
        WHERE strftime('%Y', r.ReDat) = ?
        GROUP BY k.kun_Firma
        ORDER BY Umsatz DESC
        LIMIT 10
    """, (str(jahr),))
    top_kunden = cursor.fetchall()

    # KPIs
    cursor.execute("""
        SELECT
            SUM(Summe_Netto) AS Gesamt,
            AVG(Summe_Netto) AS Durchschnitt,
            COUNT(*) AS Anzahl,
            MIN(ReDat) AS ErsteRechnung,
            MAX(ReDat) AS LetzteRechnung
        FROM tbl_RCH_Rechnung
        WHERE strftime('%Y', ReDat) = ?
    """, (str(jahr),))
    kpis = cursor.fetchone()

    return jsonify({
        'monthly': monthly,
        'topKunden': top_kunden,
        'kpis': kpis
    })

@app.route('/api/umsatz/kunden-dropdown', methods=['GET'])
def get_kunden_dropdown():
    """Kunden für Filter-Dropdown"""
    cursor.execute("""
        SELECT DISTINCT k.ID, k.kun_Firma
        FROM tbl_KD_Kundenstamm k
        INNER JOIN tbl_RCH_Rechnung r ON k.ID = r.kun_ID
        WHERE k.kun_IstAktiv = 1
        ORDER BY k.kun_Firma
    """)
    return jsonify(cursor.fetchall())
```

---

## 6. Implementierungs-Roadmap

### Phase 1: Basis-Tabelle (2-3h)
- [ ] HTML-Struktur für Tabelle
- [ ] API-Endpoints (GET /api/umsatz/gesamt)
- [ ] Daten laden und rendern
- [ ] Währungsformatierung

### Phase 2: Filter & Aggregation (2-3h)
- [ ] Filter-UI (Jahr, Kunde)
- [ ] Summen-Zeile (Footer)
- [ ] Backend-Filter-Logik
- [ ] Export-Funktion (CSV/Excel)

### Phase 3: KPIs & Statistik (2-3h)
- [ ] KPI-Cards oben (Gesamt, Ø, Anzahl)
- [ ] API für Statistik-Daten
- [ ] Vergleich Vorjahr (Prozent-Änderung)

### Phase 4: Charts (3-4h)
- [ ] Chart.js Integration
- [ ] Balkendiagramm (Umsatz pro Monat)
- [ ] Tortendiagramm (Kategorien: Arbeit, Fk, Bänder)
- [ ] Balkendiagramm (Top-10-Kunden)

### Phase 5: UX-Features (1-2h)
- [ ] Paginierung (bei vielen Rechnungen)
- [ ] Sortierung (Spalten anklickbar)
- [ ] Detail-Modal (bei Klick auf Zeile)
- [ ] Drucken-Funktion (PDF)

**Gesamt-Aufwand:** 10-15 Stunden

---

## 7. Technische Herausforderungen

### Challenge 1: Große Datenmengen
- **Problem:** Viele Rechnungen pro Jahr (100-1000+)
- **Lösung:** Paginierung + Lazy Loading
```javascript
function loadPage(page = 1, pageSize = 50) {
    fetch(`/api/umsatz/gesamt?page=${page}&size=${pageSize}`)
        .then(r => r.json())
        .then(data => renderTable(data));
}
```

### Challenge 2: Chart-Performance
- **Problem:** Chart.js kann bei vielen Datenpunkten langsam werden
- **Lösung:** Daten aggregieren (z.B. nur Monate, nicht Tage)

### Challenge 3: Excel-Export mit Formatierung
- **Problem:** CSV verliert Formatierung
- **Lösung:** SheetJS (xlsx) für echte Excel-Dateien
```javascript
import * as XLSX from 'xlsx';

function exportExcel() {
    const data = getCurrentData();
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Umsatz');
    XLSX.writeFile(wb, 'umsatz.xlsx');
}
```

### Challenge 4: Responsive Charts
- **Problem:** Charts müssen auf verschiedenen Bildschirmen funktionieren
- **Lösung:** Chart.js Responsive-Optionen
```javascript
options: {
    responsive: true,
    maintainAspectRatio: false
}
```

---

## 8. Abhängigkeiten

### Backend-Tabellen
- `tbl_RCH_Rechnung` (Rechnungen)
- `tbl_KD_Kundenstamm` (Kunden)
- `tbl_VA_Auftragstamm` (Aufträge)

### Frontend-Libraries
- **Chart.js** (für Diagramme)
  ```html
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  ```
- **SheetJS** (für Excel-Export)
  ```html
  <script src="https://cdn.jsdelivr.net/npm/xlsx/dist/xlsx.full.min.js"></script>
  ```

### Bestehende Dateien
- `frm_KD_Umsatzauswertung.html` (existiert als Placeholder)
- Wird umbenannt/ersetzt durch `frm_Umsatzuebersicht_2.html`

---

## 9. UI-Mockup (Detailliert)

### Desktop-Ansicht (>1200px)
```
+-------------------------------------------------------------------------+
| CONSYS - Umsatzübersicht 2026                                           |
+-------------------------------------------------------------------------+
| [📊 Gesamt: 245.678 €] [📈 Ø: 4.523 €] [📄 Anz: 54] [↗ +12,5%]         |
+-------------------------------------------------------------------------+
| Filter: [2026 ▼] [Alle Kunden ▼] [Anwenden] [Excel-Export] [Drucken]  |
+-------------------------------------------------------------------------+
| +---------------------------------------------------------------------+ |
| |                  Umsatz pro Monat (Balkendiagramm)                  | |
| |  €15k                                                               | |
| |  €10k    ████        ████  ████                                     | |
| |   €5k    ████  ████  ████  ████  ████                               | |
| |    0k    Jan   Feb   Mär   Apr   Mai   Jun   ...                   | |
| +---------------------------------------------------------------------+ |
+-------------------------------------------------------------------------+
| Datum      | Kunde      | Veranstaltung | Arbeit    | Fk     | Summe   |
|------------|------------|---------------|-----------|--------|---------|
| 14.01.2026 | Muster AG  | Event A       | 5.432 €   | 234 €  | 5.789 € |
| 13.01.2026 | Beispiel   | Event B       | 3.200 €   | 156 €  | 3.456 € |
| ...        | ...        | ...           | ...       | ...    | ...     |
|------------|------------|---------------|-----------|--------|---------|
| GESAMT:                                  | 245.678 € | 4.567€ | 267.890€|
+-------------------------------------------------------------------------+
| [< Vorherige] Seite 1 von 3 [Nächste >]                                |
+-------------------------------------------------------------------------+
```

### Tablet-Ansicht (768-1200px)
- KPIs in 2x2 Grid
- Chart volle Breite
- Tabelle horizontal scrollbar
- Filter-Bar zusammengeklappt (Hamburger-Menü)

### Mobile-Ansicht (<768px)
- KPIs gestapelt
- Chart volle Breite
- Tabelle: Nur wichtigste Spalten (Datum, Kunde, Summe)
- Detail-Modal bei Klick

---

## 10. Offene Fragen

1. **Welche Zeiträume sind relevant?**
   - Aktuelles Jahr? Letztes Jahr? Mehrere Jahre?
   - **Action:** Standard-Zeitraum definieren

2. **Welche Charts sind gewünscht?**
   - Monatlicher Verlauf? Kunden-Vergleich? Kategorien?
   - **Action:** User-Feedback zu gewünschten Visualisierungen

3. **Export-Formate?**
   - CSV? Excel? PDF?
   - **Action:** Anforderungen klären

4. **Zugriffs-Berechtigung?**
   - Nur Geschäftsführung? Auch Buchhalter?
   - **Action:** Rollen-Konzept prüfen

5. **Detail-Ansicht bei Klick?**
   - Soll Klick auf Zeile Detail-Modal öffnen?
   - Mit Link zur Rechnung?
   - **Action:** UX-Flow definieren

---

## Priorität: MITTEL

**Begründung:**
- **Reporting/Statistik** (nicht täglich kritisch)
- Kann zunächst über Access-Reports bedient werden
- HTML-Version bietet Mehrwert durch Charts + interaktive Filter
- Erst nach Hauptformularen (Mitarbeiter, Aufträge, Dienstplan)

**Empfehlung:**
1. Basis-Tabelle zuerst (Phase 1-2)
2. Charts später als "Nice-to-have" (Phase 4)
3. KPIs für Management-Dashboard wichtig (Phase 3)
4. Excel-Export für Buchhalter wichtig (Phase 2)

**Quick-Win:**
- Phase 1+2 (Tabelle + Filter) bereits großer Mehrwert
- Kann ohne Charts produktiv genutzt werden
- Charts später nachrüsten

**Alternative:**
- Statt eigenständigem Formular: Integration in Dashboard
- Umsatz-KPIs auf Hauptseite (frm_Menuefuehrung1)
- Detail-Tabelle als Sub-Ansicht
