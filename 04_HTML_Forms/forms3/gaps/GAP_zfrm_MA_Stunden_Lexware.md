# Gap-Analyse: zfrm_MA_Stunden_Lexware (Lexware Stunden Import/Export)

**Formular-Typ:** Z-Formular (Spezial/Lohn)
**Priorität:** Hoch (Kritisch für Lohnabrechnung)
**Access-Name:** `zfrm_MA_Stunden_Lexware`
**HTML-Name:** `zfrm_MA_Stunden_Lexware.html`

---

## Executive Summary

Das Lexware-Formular ist zentral für die **Lohnabrechnung**: Es importiert Zeitkonto-Daten aus Excel, zeigt einen Abgleich mit Consys-Stunden und exportiert Lexware-Importdateien. Die HTML-Version zeigt nur die UI-Struktur (Toolbar, Tabs), aber **alle kritischen Backend-Prozesse fehlen** (Excel-Import, Zeitkonto-Fortschreibung, Lexware-Export).

**Gesamtbewertung:** 40% UI umgesetzt, aber 0% funktional

---

## 1. Struktureller Vergleich

### Access-Original

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| **Toolbar-Buttons** | 10 | Import, Export, ZK-Fortschreibung (FA/MJ), Abgleich |
| **ComboBoxen** | 3 | MA-Auswahl, Zeitraum, Anstellungsart |
| **TextBoxen (Filter)** | 2 | AU_von, AU_bis (Datumseingabe) |
| **Subformulare** | 3 | Sub_MA_Stunden, sub_Abgleich, sub_Importfehler |
| **Tabs** | 3 | Importierte Stunden, Abgleich, Importfehler |
| **Labels** | 10 | Beschriftungen für Filter |

**Gesamt:** 28 Controls

**Funktionalität:**
- Import von Excel-Zeitkonten
- Abgleich Consys ↔ Zeitkonto
- Export als Lexware-Importdatei (.txt)
- Zeitkonto-Fortschreibung (Einsätze → Excel)
- Differenzreport als Excel

### HTML-Version

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| **Toolbar-Buttons** | 10 | Identisch zu Access (UI only) |
| **ComboBoxen** | 3 | MA, Zeitraum, Anstellungsart |
| **TextBoxen (Filter)** | 2 | Datum von/bis |
| **Tabs** | 3 | Importierte Daten, Abgleich, Importfehler |
| **Subformulare** | 3 | Platzhalter (keine echten Daten) |

**Gesamt:** 18 Controls

**Funktionalität:**
- ❌ Import: Nicht funktional
- ❌ Export: Nicht funktional
- ❌ ZK-Fortschreibung: Nicht funktional
- ⚠️ Filter: UI vorhanden, aber keine API-Anbindung

---

## 2. Funktionale Gaps (Access → HTML)

### ❌ KRITISCH: Excel-Import fehlt komplett

| Feature | Access VBA | HTML-Lösung | Aufwand |
|---------|-----------|-------------|---------|
| **Zeitkonten importieren** | `import_Zeitkonten(Monat, Jahr)` | API-Endpoint `/api/lexware/import-zeitkonten` | Hoch (16h) |
| **Einzelnes ZK importieren** | `ZK_Import_einzel(xlWB, Jahr, Monat, MA_ID)` | API-Endpoint `/api/lexware/import-zeitkonto/:ma_id` | Hoch (12h) |

**Problem:** VBA öffnet Excel-Dateien direkt (`xlApp.Workbooks.Open`), liest Zellen aus und schreibt in `ztbl_Stunden_Lexware`.

**Lösung:**
1. Excel-Dateien auf Server-Seite bereitstellen (Netzwerk-Share)
2. Python-Script öffnet Excel (`openpyxl` oder `xlrd`)
3. Liest Zeitkonto-Daten
4. Schreibt in DB-Tabelle `ztbl_Stunden_Lexware`

**Python-Beispiel:**
```python
import openpyxl

@app.route('/api/lexware/import-zeitkonten', methods=['POST'])
def import_zeitkonten():
    data = request.json
    monat = data['monat']
    jahr = data['jahr']

    # Excel-Dateien aus Netzwerk-Share lesen
    zk_pfad = r'\\server\Zeitkonten\{jahr}\{monat}\'

    mitarbeiter = db.execute('SELECT ID, Nachname FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = TRUE').fetchall()

    for ma in mitarbeiter:
        excel_file = f'{zk_pfad}ZK_{ma.Nachname}.xlsx'
        if os.path.exists(excel_file):
            wb = openpyxl.load_workbook(excel_file)
            ws = wb.active

            # Zeitkonto-Daten auslesen (z.B. Zeile 10-50)
            for row in ws.iter_rows(min_row=10, max_row=50):
                datum = row[0].value
                stunden = row[5].value
                # In DB schreiben
                db.execute('INSERT INTO ztbl_Stunden_Lexware (...) VALUES (...)')

    return jsonify({'success': True, 'imported': len(mitarbeiter)})
```

### ❌ KRITISCH: Lexware-Export fehlt

| Feature | Access VBA | HTML-Lösung | Aufwand |
|---------|-----------|-------------|---------|
| **Lexware-Importdatei erstellen** | `DoCmd.TransferText` mit Custom-Spec | API-Endpoint `/api/lexware/export` | Mittel (8h) |
| **Export Differenzreport** | `DoCmd.OutputTo acFormatXLSX` | API-Endpoint `/api/lexware/export-differenzreport` | Mittel (6h) |

**Access-Code:**
```vba
SQL = "SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert_korr " & _
      "FROM [zqry_MA_Stunden] WHERE " & WHERE
DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE", QRY, fileName
```

**Python-Lösung:**
```python
@app.route('/api/lexware/export', methods=['GET'])
def export_lexware():
    von = request.args.get('von')
    bis = request.args.get('bis')

    # Daten aus zqry_MA_Stunden laden
    data = db.execute('''
        SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert_korr
        FROM zqry_MA_Stunden
        WHERE Datum BETWEEN ? AND ?
    ''', [von, bis]).fetchall()

    # Als Lexware-Format schreiben (TAB-delimited)
    output = StringIO()
    writer = csv.writer(output, delimiter='\t')
    for row in data:
        writer.writerow(row)

    # Als Download zurückgeben
    return send_file(output, as_attachment=True, download_name='Lexware_Import.txt')
```

### ❌ KRITISCH: Zeitkonto-Fortschreibung fehlt

| Feature | Access VBA | HTML-Lösung | Aufwand |
|---------|-----------|-------------|---------|
| **Einsätze in ZK übertragen (FA)** | `ZK_Daten_uebertragen(MA_ID, von, bis)` | API-Endpoint `/api/lexware/zk-fortschreiben-fa` | Sehr Hoch (20h) |
| **Einsätze in ZK übertragen (MJ)** | Gleiche Funktion | API-Endpoint `/api/lexware/zk-fortschreiben-mj` | Sehr Hoch (20h) |
| **Einzelner MA** | Gleiche Funktion | API-Endpoint `/api/lexware/zk-fortschreiben/:ma_id` | Hoch (12h) |

**Komplexität:** Diese Funktion öffnet Excel-Dateien, sucht die richtige Zeile, schreibt Stunden hinein und speichert.

**VBA-Pseudo-Code:**
```vba
Function ZK_Daten_uebertragen(MA_ID, von, bis) As String
    ' 1. Excel-Datei für MA ermitteln
    DateiZK = ZK_Datei_ermitteln(MA_ID)

    ' 2. Excel öffnen
    Set xlApp = CreateObject("Excel.Application")
    Set xlWB = xlApp.Workbooks.Open(DateiZK)

    ' 3. Einsätze aus Consys laden
    rs = db.Execute("SELECT Datum, Stunden FROM qry_MA_Einsätze WHERE MA_ID = " & MA_ID)

    ' 4. In Excel schreiben (Zeile für Zeile)
    For Each einsatz In rs
        row = FindRowByDate(xlWB, einsatz.Datum)
        xlWB.Cells(row, 5).Value = einsatz.Stunden
    Next

    ' 5. Excel speichern
    xlWB.Save
    xlWB.Close
End Function
```

**Python-Lösung:**
```python
@app.route('/api/lexware/zk-fortschreiben-fa', methods=['POST'])
def fortschreiben_fa():
    data = request.json
    von = data['von']
    bis = data['bis']

    # Alle Festangestellten laden
    mitarbeiter = db.execute('''
        SELECT ID FROM tbl_MA_Mitarbeiterstamm
        WHERE IstAktiv = TRUE AND Anstellungsart_ID IN (3, 4)
    ''').fetchall()

    results = []
    for ma in mitarbeiter:
        # Excel-Datei öffnen
        excel_file = ermittle_zeitkonto_datei(ma.ID)
        if not excel_file:
            continue

        wb = openpyxl.load_workbook(excel_file)
        ws = wb.active

        # Einsätze aus Consys laden
        einsaetze = db.execute('''
            SELECT Datum, Stunden FROM qry_MA_Einsaetze
            WHERE MA_ID = ? AND Datum BETWEEN ? AND ?
        ''', [ma.ID, von, bis]).fetchall()

        # In Excel schreiben
        for einsatz in einsaetze:
            row = finde_zeile_nach_datum(ws, einsatz.Datum)
            ws.cell(row, 5).value = einsatz.Stunden

        wb.save(excel_file)
        results.append({'ma_id': ma.ID, 'success': True})

    return jsonify({'results': results})
```

**Aufwand:** 20h pro Anstellungsart (FA/MJ) wegen:
- Excel-Datei-Ermittlung (Netzwerk-Pfade)
- Zell-Suche nach Datum
- Schreibgeschützte Excel-Dateien (Locking)
- Fehlerbehandlung (Datei nicht gefunden, etc.)

### ⚠️ TEILWEISE: Abgleich/Filter

| Feature | Access | HTML | Status |
|---------|--------|------|--------|
| **Filter-UI** | ✅ Ja | ✅ Ja | UI vorhanden |
| **Daten laden** | `zqry_MA_Stunden_Abgleich` | ❌ Keine API-Anbindung | Fehlt |
| **Filter anwenden** | VBA: `Me.filter = ...` | ❌ Nicht implementiert | Fehlt |

**Benötigt:**
- API-Endpoint `/api/lexware/abgleich?von=...&bis=...&ma_id=...`
- JavaScript: Daten laden, Tabelle rendern
- Filter-Logik: Bei Änderung von ComboBox → API neu aufrufen

---

## 3. UI/UX Unterschiede

### Access-Original

- **Toolbar:** 10 Buttons in 2 Reihen, kompakt
- **Filter:** ComboBoxen + TextBoxen in einer Zeile
- **Tabs:** 3 Tabs (RegLex) mit Subformularen
- **Subformulare:** Scrollbare Tabellen mit Daten
- **Farben:** Grau (#7F7F7F) für Labels, Standard-Buttons

### HTML-Version

- **Toolbar:** 10 Buttons in mehreren Zeilen (responsive)
- **Filter:** Toolbar-Gruppen mit Labels + Inputs
- **Tabs:** 3 Tabs mit Platzhalter-Content
- **Subformulare:** Leere Tab-Panels (keine Daten)
- **Farben:** Blauer Hintergrund (#8080c0), modernes Flat-Design

**Unterschied:** HTML hat modernere UI, aber keine Funktionalität.

---

## 4. Empfohlene Maßnahmen

### Phase 1: API-Endpoints erstellen (KRITISCH)

**1.1 Abgleich-Daten laden**

```python
@app.route('/api/lexware/abgleich', methods=['GET'])
def get_abgleich_daten():
    von = request.args.get('von')
    bis = request.args.get('bis')
    ma_id = request.args.get('ma_id', None)
    anstellungsart = request.args.get('anstellungsart', None)

    query = '''
        SELECT * FROM zqry_MA_Stunden_Abgleich
        WHERE Datum BETWEEN ? AND ?
    '''
    params = [von, bis]

    if ma_id:
        query += ' AND ID = ?'
        params.append(ma_id)
    if anstellungsart:
        query += ' AND Anstellungsart_ID = ?'
        params.append(anstellungsart)

    data = db.execute(query, params).fetchall()
    return jsonify([dict(row) for row in data])
```

**Aufwand:** 4 Stunden

**1.2 Importierte Stunden laden**

```python
@app.route('/api/lexware/stunden', methods=['GET'])
def get_importierte_stunden():
    von = request.args.get('von')
    bis = request.args.get('bis')

    data = db.execute('''
        SELECT * FROM ztbl_Stunden_Lexware
        WHERE Datum BETWEEN ? AND ?
    ''', [von, bis]).fetchall()

    return jsonify([dict(row) for row in data])
```

**Aufwand:** 2 Stunden

**1.3 Importfehler laden**

```python
@app.route('/api/lexware/importfehler', methods=['GET'])
def get_importfehler():
    data = db.execute('SELECT * FROM ztbl_ZK_Importfehler').fetchall()
    return jsonify([dict(row) for row in data])
```

**Aufwand:** 2 Stunden

### Phase 2: Filter-Funktionalität (WICHTIG)

**HTML/JavaScript:**

```javascript
// Filter-Logik
async function applyFilter() {
    const von = document.getElementById('AU_von').value;
    const bis = document.getElementById('AU_bis').value;
    const ma_id = document.getElementById('cboMA').value;
    const anstellungsart = document.getElementById('cboAnstArt').value;

    const params = new URLSearchParams({
        von, bis,
        ...(ma_id && { ma_id }),
        ...(anstellungsart && { anstellungsart })
    });

    const response = await fetch(`/api/lexware/abgleich?${params}`);
    const data = await response.json();

    renderTable('sub_Abgleich', data);
}

// Event-Listener
document.getElementById('AU_von').addEventListener('change', applyFilter);
document.getElementById('AU_bis').addEventListener('change', applyFilter);
document.getElementById('cboMA').addEventListener('change', applyFilter);
document.getElementById('cboAnstArt').addEventListener('change', applyFilter);
```

**Aufwand:** 6 Stunden

### Phase 3: Lexware-Export (KRITISCH)

**3.1 Export-Button**

```javascript
async function exportLexware() {
    const von = document.getElementById('AU_von').value;
    const bis = document.getElementById('AU_bis').value;

    if (!von || !bis) {
        alert('Bitte Zeitraum auswählen');
        return;
    }

    const response = await fetch(`/api/lexware/export?von=${von}&bis=${bis}`);
    const blob = await response.blob();

    // Download triggern
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'Lexware_Import.txt';
    a.click();
}
```

**API-Endpoint:** Siehe oben (Phase 1)

**Aufwand:** 8 Stunden (inkl. API + UI)

### Phase 4: Excel-Import (SEHR KRITISCH)

**4.1 Import-Button**

```javascript
async function importZeitkonten() {
    const von = document.getElementById('AU_von').value;
    const monat = new Date(von).getMonth() + 1;
    const jahr = new Date(von).getFullYear();

    // API aufrufen
    const response = await fetch('/api/lexware/import-zeitkonten', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ monat, jahr })
    });

    const result = await response.json();
    alert(`${result.imported} Zeitkonten importiert`);

    // Subformulare neu laden
    loadStundenData();
    loadAbgleichData();
    loadImportfehlerData();
}
```

**API-Endpoint:** Siehe oben (Funktionale Gaps)

**Aufwand:** 16 Stunden (API + Excel-Parsing + DB-Insert)

### Phase 5: Zeitkonto-Fortschreibung (LANGFRISTIG)

**Nur umsetzen, wenn wirklich benötigt!**

**Aufwand:** 52 Stunden (alle Varianten)
- ZK-Fortschreibung FA: 20h
- ZK-Fortschreibung MJ: 20h
- Einzelner MA: 12h

**Alternative:** Diese Funktion in Access VBA belassen (kein HTML-Port).

---

## 5. Priorisierung

| Phase | Feature | Umsetzbar? | Aufwand | Nutzen | Priorität |
|-------|---------|------------|---------|--------|-----------|
| **1** | API-Endpoints (Daten laden) | ✅ Ja | 8h | Hoch | ⭐⭐⭐⭐⭐ |
| **2** | Filter-Funktionalität | ✅ Ja | 6h | Hoch | ⭐⭐⭐⭐⭐ |
| **3** | Lexware-Export | ✅ Ja | 8h | Sehr Hoch | ⭐⭐⭐⭐⭐ |
| **4** | Excel-Import | ⚠️ Komplex | 16h | Sehr Hoch | ⭐⭐⭐⭐ |
| **5** | ZK-Fortschreibung | ⚠️ Sehr Komplex | 52h | Mittel | ⭐⭐ |

**Empfehlung:** Phase 1-4 umsetzen (38h), Phase 5 in Access belassen.

---

## 6. Besonderheiten

### 6.1 Excel-COM-Interop

Access nutzt `CreateObject("Excel.Application")` für direkten Excel-Zugriff.

**Problem:** In Python/Web nicht direkt möglich.

**Lösung:**
- `openpyxl` (Python) für .xlsx-Dateien
- Zeitkonto-Dateien müssen auf Server-Seite liegen (Netzwerk-Share)

### 6.2 Lexware-Importformat

Access nutzt `DoCmd.TransferText` mit Custom-Spezifikation "EXPORT_TXT_LEXWARE".

**Format:** TAB-delimited Text-Datei mit fixen Spalten:
- Jahr, Monat, Personalnummer, Lohnartnummer, Wert

**Wichtig:** Personalnummer = `LEXWare_ID` (nicht MA_ID!)

### 6.3 Abgleich-Logik

Vergleicht 3 Datenquellen:
1. **Consys-Stunden:** `qry_MA_VA_Zuordnung_Stunden_Monat`
2. **ZK-Gesamt:** `ztbl_Stunden_Lexware` (Lohnartnummer 99999)
3. **ZK-Abgerechnet:** `ztbl_Stunden_Lexware` (Lohnartnummer 88888)

**Differenz:** `ZK_abgerechnet - ZK_gesamt`

### 6.4 Zeitkonto-Log

Alle ZK-Fortschreibungen werden geloggt:
```vba
CurrentDb.Execute "INSERT INTO [ztbl_ZK_Log] VALUES (" & _
    DatumUhrzeitSQL(Now()) & ", '" & Environ("UserName") & "', '" & rc & "');"
```

**Wichtig:** Auch in HTML-Version implementieren!

---

## 7. Fazit

**Status:** ⚠️ **UI zu 40% umgesetzt, funktional 0%**

Das Lexware-Formular ist **geschäftskritisch** (Lohnabrechnung), aber **technisch sehr komplex** wegen Excel-Interop.

### ✅ Was vorhanden ist:

- UI-Layout (Toolbar, Tabs, Filter)
- Button-Struktur
- Tab-Navigation

### ❌ Was fehlt (KRITISCH):

- Daten-Laden (Abgleich, Stunden, Importfehler)
- Filter-Funktionalität
- Lexware-Export (.txt)
- Excel-Import (Zeitkonten)
- Zeitkonto-Fortschreibung (Excel schreiben)

### 📋 Nächste Schritte:

1. **Phase 1-3** SOFORT umsetzen (22h) → Abgleich + Export funktionsfähig
2. **Phase 4** (16h) → Excel-Import, falls kritisch benötigt
3. **Phase 5** (52h) → ZK-Fortschreibung nur bei Bedarf, sonst in Access belassen

**Gesamtaufwand für Kernfunktionen:** 38 Stunden (Phase 1-4)
**Gesamtaufwand für vollständige Funktionalität:** 90 Stunden (inkl. ZK-Fortschreibung)

**Endgültiger Umsetzungsgrad realistisch:** 80% (Phase 1-4, ohne ZK-Fortschreibung)

### Alternative:

❌ **Dieses Formular NICHT nach HTML portieren** und in Access belassen.

**Begründung:**
- Excel-Interop ist in Web sehr aufwändig
- Zeitkonto-Fortschreibung extrem komplex
- Access-Version funktioniert zuverlässig
- Nur von wenigen Benutzern genutzt (Lohnbuchhaltung)

**Empfehlung:** Hybrid-Ansatz - Lexware-Formular bleibt in Access, Rest in HTML.
