# Gap-Analyse: zfrm_Rueckmeldungen (Rückmeldungen)

**Formular-Typ:** Z-Formular (Zusatz/Statistik)
**Priorität:** Niedrig (Reporting/Statistik)
**Access-Name:** `zfrm_Rueckmeldungen`
**HTML-Name:** `zfrm_Rueckmeldungen.html`

---

## Executive Summary

Das Rückmeldungen-Formular zeigt **Rückmelde-Statistiken** der Mitarbeiter an (z.B. Zu-/Absagen auf Anfragen). Die HTML-Version ist ein **Platzhalter** ohne Funktionalität.

**Gesamtbewertung:** 10% umgesetzt (nur Platzhalter-Seite)

---

## 1. Struktureller Vergleich

### Access-Original

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| **Labels** | 6 | Titel + Beschriftungen (grau) |
| **Subformular** | 1 | Untergeordnet19 (Rückmelde-Liste) |
| **TextBoxen** | 4 | Anstellungsart_ID (mehrfach, verborgen?) |

**Gesamt:** 11 Controls

**Datensatzquelle:** `zqry_Rueckmeldungen` (Query)

**Funktionalität:**
- Zeigt Rückmeldungen in Subformular an
- Form_Load: Ruft `Rückmeldeauswertung` auf (VBA)
- Form_Close: Löscht `ztbl_Rueckmeldezeiten` (temporäre Tabelle)

### HTML-Version

**Datei:** `zfrm_Rueckmeldungen.html`

```html
<div class="placeholder">
    <h1>Rueckmeldungen</h1>
    <p>Dieses Formular zeigt die Rueckmelde-Statistik der Mitarbeiter an.</p>
    <p><em>HTML-Version in Entwicklung</em></p>
    <button onclick="history.back()">Zurueck</button>
    <button onclick="Bridge.close()">Schliessen</button>
</div>
```

**Funktionalität:** ❌ Keine

---

## 2. VBA-Code (Access)

```vba
Option Compare Database

Private Sub Form_Close()
    Dim tbl_rueck As String
    tbl_rueck = "ztbl_Rueckmeldezeiten"
    CurrentDb.Execute "DELETE * FROM " & tbl_rueck
End Sub

Private Sub Form_Load()
    Call Rückmeldeauswertung
End Sub
```

**Analyse:**

1. **Form_Load:**
   - Ruft externe VBA-Funktion `Rückmeldeauswertung` auf
   - Diese Funktion füllt vermutlich `ztbl_Rueckmeldezeiten` mit Daten

2. **Form_Close:**
   - Löscht temporäre Tabelle `ztbl_Rueckmeldezeiten`
   - Cleanup nach Formular-Schließung

**Problem:** Die Funktion `Rückmeldeauswertung` ist NICHT im Export enthalten. Sie liegt vermutlich in einem globalen VBA-Modul.

---

## 3. Fehlende Features (Access → HTML)

### ❌ KOMPLETT fehlend

1. **Daten-Laden:**
   - VBA-Funktion `Rückmeldeauswertung` fehlt
   - Query `zqry_Rueckmeldungen` nicht dokumentiert
   - Temporäre Tabelle `ztbl_Rueckmeldezeiten` unbekannt

2. **Subformular:**
   - Keine Tabelle/Liste für Rückmeldungen
   - Keine Spalten-Definitionen bekannt

3. **Daten-Struktur:**
   - Welche Felder zeigt das Subformular?
   - Wie wird die Statistik berechnet?

4. **Cleanup-Logik:**
   - HTML muss temporäre Daten ebenfalls löschen

---

## 4. Empfohlene Maßnahmen

### Phase 1: Daten-Struktur analysieren (KRITISCH)

**Aufgabe:** Access-Datenbank öffnen, analysieren:

1. **VBA-Modul öffnen:** Funktion `Rückmeldeauswertung` finden
2. **Query prüfen:** `zqry_Rueckmeldungen` in Design-Ansicht öffnen
3. **Tabelle prüfen:** `ztbl_Rueckmeldezeiten` - Struktur dokumentieren
4. **Subformular prüfen:** Welche Spalten werden angezeigt?

**Aufwand:** 2 Stunden
**Nutzen:** Verständnis der Logik

### Phase 2: API-Endpoint erstellen

**Ohne Kenntnis der Daten-Struktur nicht möglich!**

**Beispiel (geschätzt):**

```python
@app.route('/api/rueckmeldungen/statistik', methods=['GET'])
def get_rueckmeldungen_statistik():
    # Rückmeldeauswertung-Logik nachbilden
    # Vermutlich: Zählen von Zu-/Absagen pro MA

    result = db.execute('''
        SELECT
            m.ID,
            m.Nachname,
            m.Vorname,
            COUNT(CASE WHEN r.Status = 'Zusage' THEN 1 END) AS Zusagen,
            COUNT(CASE WHEN r.Status = 'Absage' THEN 1 END) AS Absagen,
            COUNT(*) AS Gesamt
        FROM tbl_MA_Mitarbeiterstamm m
        LEFT JOIN tbl_MA_Rueckmeldungen r ON m.ID = r.MA_ID
        WHERE m.IstAktiv = TRUE
        GROUP BY m.ID, m.Nachname, m.Vorname
        ORDER BY m.Nachname
    ''').fetchall()

    return jsonify([dict(row) for row in result])
```

**Aufwand:** 8 Stunden (inkl. Reverse-Engineering der VBA-Logik)

### Phase 3: HTML-Tabelle rendern

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Rückmeldungen - CONSYS</title>
    <link rel="stylesheet" href="css/fonts_override.css">
    <style>
        body {
            background-color: #8080c0;
            font-family: 'Segoe UI', sans-serif;
            font-size: 11px;
            padding: 20px;
        }
        .container {
            background: white;
            border: 2px solid #404080;
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            color: #000080;
            border-bottom: 2px solid #c0c0c0;
            padding-bottom: 10px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #c0c0c0;
            padding: 6px;
            text-align: left;
        }
        th {
            background: #d0d0e0;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background: #f0f0f0;
        }
        .btn-close {
            background: linear-gradient(to bottom, #d0d0e0, #a0a0c0);
            border: 2px outset #c0c0c0;
            padding: 5px 20px;
            cursor: pointer;
            font-size: 11px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Rückmelde-Statistik</h1>
        <table id="rueckmeldeTable">
            <thead>
                <tr>
                    <th>Nachname</th>
                    <th>Vorname</th>
                    <th>Zusagen</th>
                    <th>Absagen</th>
                    <th>Gesamt</th>
                    <th>Quote</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <tr><td colspan="6">Lade Daten...</td></tr>
            </tbody>
        </table>
        <button class="btn-close" onclick="window.close()">Schließen</button>
    </div>
    <script>
        async function loadData() {
            const response = await fetch('/api/rueckmeldungen/statistik');
            const data = await response.json();

            const tbody = document.getElementById('tableBody');
            tbody.innerHTML = '';

            data.forEach(row => {
                const quote = row.Gesamt > 0
                    ? ((row.Zusagen / row.Gesamt) * 100).toFixed(1) + '%'
                    : '-';

                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${row.Nachname}</td>
                    <td>${row.Vorname}</td>
                    <td>${row.Zusagen}</td>
                    <td>${row.Absagen}</td>
                    <td>${row.Gesamt}</td>
                    <td>${quote}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        loadData();
    </script>
</body>
</html>
```

**Aufwand:** 4 Stunden

### Phase 4: Cleanup-Logik (OPTIONAL)

Falls temporäre Daten verwendet werden:

```python
@app.route('/api/rueckmeldungen/cleanup', methods=['POST'])
def cleanup_rueckmeldungen():
    db.execute('DELETE FROM ztbl_Rueckmeldezeiten')
    db.commit()
    return jsonify({'success': True})
```

**Aufruf in HTML:**
```javascript
window.addEventListener('beforeunload', () => {
    fetch('/api/rueckmeldungen/cleanup', { method: 'POST' });
});
```

**Aufwand:** 2 Stunden

---

## 5. Priorisierung

| Phase | Feature | Umsetzbar? | Aufwand | Nutzen | Priorität |
|-------|---------|------------|---------|--------|-----------|
| **1** | Daten-Struktur analysieren | ✅ Ja | 2h | Hoch | ⭐⭐⭐⭐⭐ |
| **2** | API-Endpoint erstellen | ⚠️ Nach Phase 1 | 8h | Mittel | ⭐⭐⭐ |
| **3** | HTML-Tabelle rendern | ✅ Ja | 4h | Mittel | ⭐⭐⭐ |
| **4** | Cleanup-Logik | ✅ Ja | 2h | Niedrig | ⭐ |

**Gesamtaufwand:** 16 Stunden
**Erwarteter Umsetzungsgrad:** 90% (nach allen Phasen)

---

## 6. Besonderheiten

### 6.1 Unbekannte VBA-Funktion

Die Funktion `Rückmeldeauswertung` ist **nicht im Form-Code** enthalten.

**Mögliche Orte:**
1. Globales VBA-Modul (z.B. `mod_Rueckmeldungen`)
2. Class-Modul
3. Externes Add-In

**Lösung:** Access-Datenbank öffnen, VBA-Editor (Alt+F11), "Suchen" (Strg+F) nach "Rückmeldeauswertung".

### 6.2 Temporäre Tabelle

`ztbl_Rueckmeldezeiten` wird bei Formular-Schließung geleert.

**Zweck:** Vermutlich als Zwischenspeicher für komplexe Berechnungen.

**In HTML:**
- **Option A:** Keine temporäre Tabelle nötig (alles in Query)
- **Option B:** Session-basierte Daten (serverseitig)

### 6.3 Query: zqry_Rueckmeldungen

**Unbekannt:** Der Access-Export enthält keine Query-Definition.

**Vermutung:** Zeigt aggregierte Daten aus `tbl_MA_Rueckmeldungen` (oder ähnlich).

**Mögliche Struktur:**
```sql
SELECT
    m.ID,
    m.Nachname,
    m.Vorname,
    r.Anzahl_Zusagen,
    r.Anzahl_Absagen,
    r.Anzahl_Gesamt
FROM tbl_MA_Mitarbeiterstamm m
INNER JOIN ztbl_Rueckmeldezeiten r ON m.ID = r.MA_ID
```

### 6.4 TextBoxen: Anstellungsart_ID

Im Access-Export sind 4 TextBoxen mit `Anstellungsart_ID` vorhanden.

**Zweck unklar:**
- Mehrfache Anzeige der gleichen Daten?
- Versteckte Filter?
- Copy/Paste-Artefakte?

**In HTML:** Nicht relevant, falls nicht sichtbar in Access.

---

## 7. Alternative: Nicht umsetzen

**Falls Rückmeldungen-Statistik wenig genutzt wird:**

❌ **Dieses Formular NICHT nach HTML portieren**

**Begründung:**
1. Sehr niedrige Priorität (Reporting/Statistik)
2. Unklare Daten-Struktur (VBA-Funktion fehlt)
3. Vermutlich nur von wenigen Benutzern genutzt
4. Aufwand 16h besser in kritische Formulare investieren

**Alternative:**
- Access-Report erstellen (PDF-Export)
- Oder: Excel-Export via API

---

## 8. Fazit

**Status:** ❌ **Platzhalter (10%)**

Das Rückmeldungen-Formular ist ein **Platzhalter** ohne Funktionalität.

### ✅ Was vorhanden ist:

- Platzhalter-Seite mit Beschreibung
- Schließen-Button

### ❌ Was fehlt:

- Daten-Laden (VBA-Funktion `Rückmeldeauswertung` unbekannt)
- Tabellen-Anzeige
- Query-Definition
- Daten-Struktur

### 📋 Nächste Schritte:

1. **KRITISCH:** VBA-Funktion `Rückmeldeauswertung` in Access finden (2h)
2. **Danach:** API-Endpoint + HTML-Tabelle umsetzen (12h)
3. **ODER:** Formular in Access belassen

**Gesamtaufwand:** 16 Stunden (falls umgesetzt)

**Empfehlung:** ⚠️ **Niedrige Priorität** - Erst umsetzen, wenn alle kritischen Formulare fertig sind. Falls wenig genutzt, in Access belassen.

**Endgültiger Umsetzungsgrad realistisch:** 90% (nach Analyse + Umsetzung) ODER 0% (nicht umsetzen)
