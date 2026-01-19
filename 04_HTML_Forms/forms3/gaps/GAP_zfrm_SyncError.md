# Gap-Analyse: zfrm_SyncError (Synchronisations-Fehler)

**Formular-Typ:** Z-Formular (Zusatz/Fehler-Verwaltung)
**Priorität:** Niedrig (Support/Diagnostics)
**Access-Name:** `zfrm_Syncerror`
**HTML-Name:** `zfrm_SyncError.html`

---

## Executive Summary

Das SyncError-Formular zeigt **Synchronisationsfehler** an, die bei der Datensynchronisation mit externen Systemen (z.B. Löwensaal) aufgetreten sind. Die HTML-Version ist ein **Platzhalter** ohne Funktionalität.

**Gesamtbewertung:** 10% umgesetzt (nur Platzhalter-Seite)

---

## 1. Struktureller Vergleich

### Access-Original

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| **Label** | 1 | Titel (Bezeichnungsfeld10) |
| **CommandButton** | 1 | Befehl29 (Aktion/Löschen) |
| **Subformular** | 1 | Untergeordnet19 (Sync-Error-Liste) |

**Gesamt:** 3 Controls

**Datensatzquelle:** `ztbl_sync` (Tabelle)

**Funktionalität:**
- Zeigt Sync-Fehler in Subformular an (zsub_syncerror)
- Button Befehl29: Eingebettetes Makro (Löschen/Aktualisieren?)
- Kein VBA-Code (nur Makro)

### HTML-Version

**Datei:** `zfrm_SyncError.html`

```html
<div class="placeholder">
    <h1>Synchronisations-Fehler</h1>
    <p>Dieses Formular zeigt Fehler bei der Datensynchronisation an.</p>
    <p><em>HTML-Version in Entwicklung</em></p>
    <button onclick="history.back()">Zurueck</button>
    <button onclick="Bridge.close()">Schliessen</button>
</div>
```

**Funktionalität:** ❌ Keine

---

## 2. Access-Struktur (Details)

### 2.1 Label: Bezeichnungsfeld10 (Titel)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 60, Top: 60, Width: 11370, Height: 570 |
| **ForeColor** | 8355711 (#7F7F7F - grau) |
| **BackColor** | 16777215 (#FFFFFF - weiß) |

**Zweck:** Formular-Titel "Synchronisations-Fehler"

### 2.2 CommandButton: Befehl29

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 12812, Top: 226, Width: 576, Height: 576 |
| **BackColor** | 14136213 (#D7B5D5 - rosa/violett) |
| **ForeColor** | 4210752 (#404040 - dunkelgrau) |
| **Events** | OnClick: **Eingebettetes Makro** |

**Zweck:** Wahrscheinlich "Fehler löschen" oder "Formular aktualisieren"

**Problem:** Makro-Inhalt ist nicht im Export enthalten. Muss aus Access extrahiert werden.

### 2.3 Subformular: Untergeordnet19

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 0, Top: 0, Width: 22686, Height: 11406 |
| **Source Object** | `zsub_syncerror` |
| **Link Fields** | Keine (ungebunden) |

**Zweck:** Zeigt Sync-Fehler-Liste an (zsub_syncerror)

**Problem:** Struktur von `zsub_syncerror` ist nicht dokumentiert.

---

## 3. Datenbank-Tabelle: ztbl_sync

### Vermutete Struktur

| Feld | Datentyp | Beschreibung |
|------|----------|--------------|
| **ID** | AutoNumber | Primärschlüssel |
| **Datum** | DateTime | Zeitpunkt des Fehlers |
| **Quelle** | Text(50) | System (z.B. "Löwensaal", "Zeitkonto") |
| **Fehlertext** | Memo/Text | Fehlermeldung |
| **Datensatz_ID** | Long | Betroffener Datensatz (MA_ID, VA_ID, etc.) |
| **Status** | Text(20) | "Offen", "Behoben", "Ignoriert" |
| **Behoben_Am** | DateTime | Datum der Behebung |
| **Behoben_Von** | Text(50) | Benutzername |

**Hinweis:** Dies ist eine **Vermutung** basierend auf typischen Sync-Error-Tabellen. Die tatsächliche Struktur muss in Access geprüft werden.

---

## 4. Fehlende Features (Access → HTML)

### ❌ KOMPLETT fehlend

1. **Daten-Laden:**
   - Sync-Fehler aus `ztbl_sync` laden
   - Subformular `zsub_syncerror` nicht dokumentiert

2. **Fehler-Liste:**
   - Keine Tabelle/Liste für Fehler
   - Keine Spalten-Definitionen bekannt

3. **Button-Funktion:**
   - Makro-Inhalt unbekannt (Löschen? Aktualisieren?)

4. **Daten-Struktur:**
   - Welche Felder zeigt das Subformular?
   - Welche Filter/Sortierung?

---

## 5. Empfohlene Maßnahmen

### Phase 1: Daten-Struktur analysieren (KRITISCH)

**Aufgabe:** Access-Datenbank öffnen, analysieren:

1. **Tabelle prüfen:** `ztbl_sync` in Design-Ansicht öffnen
2. **Subformular prüfen:** `zsub_syncerror` - Welche Spalten werden angezeigt?
3. **Makro extrahieren:** Befehl29 → Rechtsklick → "Makro bearbeiten"
4. **Sync-Prozesse finden:** Wo werden Fehler in `ztbl_sync` geschrieben? (VBA-Module durchsuchen)

**Aufwand:** 2 Stunden
**Nutzen:** Verständnis der Logik

### Phase 2: API-Endpoint erstellen

```python
@app.route('/api/sync/errors', methods=['GET'])
def get_sync_errors():
    """
    Lädt alle Sync-Fehler aus ztbl_sync
    """
    status = request.args.get('status', None)  # Optional: Filter nach Status

    query = 'SELECT * FROM ztbl_sync'
    params = []

    if status:
        query += ' WHERE Status = ?'
        params.append(status)

    query += ' ORDER BY Datum DESC'

    errors = db.execute(query, params).fetchall()
    return jsonify([dict(row) for row in errors])


@app.route('/api/sync/errors/<int:error_id>', methods=['DELETE'])
def delete_sync_error(error_id):
    """
    Löscht einen Sync-Fehler
    """
    db.execute('DELETE FROM ztbl_sync WHERE ID = ?', [error_id])
    db.commit()
    return jsonify({'success': True})


@app.route('/api/sync/errors/<int:error_id>/resolve', methods=['POST'])
def resolve_sync_error(error_id):
    """
    Markiert einen Sync-Fehler als behoben
    """
    data = request.json
    benutzer = data.get('benutzer', 'System')

    db.execute('''
        UPDATE ztbl_sync
        SET Status = 'Behoben',
            Behoben_Am = ?,
            Behoben_Von = ?
        WHERE ID = ?
    ''', [datetime.now(), benutzer, error_id])
    db.commit()

    return jsonify({'success': True})
```

**Aufwand:** 6 Stunden

### Phase 3: HTML-UI mit Fehler-Tabelle

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Synchronisations-Fehler - CONSYS</title>
    <link rel="stylesheet" href="css/fonts_override.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', sans-serif; font-size: 11px; }
        body { background-color: #8080c0; padding: 20px; }
        .container {
            background: white;
            border: 2px solid #404080;
            padding: 20px;
            max-width: 1400px;
            margin: 0 auto;
        }
        h1 {
            color: #000080;
            border-bottom: 2px solid #c0c0c0;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .toolbar {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #c0c0c0;
        }
        .btn {
            background: linear-gradient(to bottom, #d0d0e0, #a0a0c0);
            border: 2px outset #c0c0c0;
            padding: 5px 15px;
            cursor: pointer;
            font-size: 11px;
        }
        .btn:hover { background: linear-gradient(to bottom, #e0e0f0, #b0b0d0); }
        .btn-delete { background: linear-gradient(to bottom, #e08080, #c06060); color: white; }
        .btn-delete:hover { background: linear-gradient(to bottom, #f09090, #d07070); }
        table {
            width: 100%;
            border-collapse: collapse;
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
            background: #f8f8f8;
        }
        tr.status-offen { background: #ffe0e0; }
        tr.status-behoben { background: #e0ffe0; }
        .actions {
            display: flex;
            gap: 5px;
        }
        .actions button {
            padding: 2px 8px;
            font-size: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Synchronisations-Fehler</h1>
        <div class="toolbar">
            <button class="btn" onclick="loadErrors()">🔄 Aktualisieren</button>
            <button class="btn" onclick="filterStatus('Offen')">⚠️ Nur Offene</button>
            <button class="btn" onclick="filterStatus('Behoben')">✅ Nur Behobene</button>
            <button class="btn" onclick="filterStatus(null)">📋 Alle</button>
            <button class="btn btn-delete" onclick="deleteAll()">🗑️ Alle löschen</button>
        </div>
        <table id="errorTable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Datum</th>
                    <th>Quelle</th>
                    <th>Fehlertext</th>
                    <th>Datensatz-ID</th>
                    <th>Status</th>
                    <th>Aktionen</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <tr><td colspan="7">Lade Daten...</td></tr>
            </tbody>
        </table>
    </div>
    <script>
        let currentFilter = null;

        async function loadErrors() {
            const url = currentFilter
                ? `/api/sync/errors?status=${currentFilter}`
                : '/api/sync/errors';

            const response = await fetch(url);
            const errors = await response.json();

            const tbody = document.getElementById('tableBody');
            tbody.innerHTML = '';

            if (errors.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7">Keine Fehler vorhanden</td></tr>';
                return;
            }

            errors.forEach(error => {
                const tr = document.createElement('tr');
                tr.className = `status-${error.Status.toLowerCase()}`;
                tr.innerHTML = `
                    <td>${error.ID}</td>
                    <td>${formatDate(error.Datum)}</td>
                    <td>${error.Quelle}</td>
                    <td>${error.Fehlertext}</td>
                    <td>${error.Datensatz_ID || '-'}</td>
                    <td>${error.Status}</td>
                    <td class="actions">
                        ${error.Status === 'Offen' ? `
                            <button class="btn" onclick="resolveError(${error.ID})">✅ Behoben</button>
                        ` : ''}
                        <button class="btn btn-delete" onclick="deleteError(${error.ID})">🗑️</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        async function deleteError(id) {
            if (!confirm('Fehler wirklich löschen?')) return;

            await fetch(`/api/sync/errors/${id}`, { method: 'DELETE' });
            loadErrors();
        }

        async function resolveError(id) {
            await fetch(`/api/sync/errors/${id}/resolve`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ benutzer: 'WebUser' })
            });
            loadErrors();
        }

        async function deleteAll() {
            if (!confirm('Alle Fehler löschen?')) return;

            const response = await fetch('/api/sync/errors');
            const errors = await response.json();

            for (const error of errors) {
                await fetch(`/api/sync/errors/${error.ID}`, { method: 'DELETE' });
            }

            loadErrors();
        }

        function filterStatus(status) {
            currentFilter = status;
            loadErrors();
        }

        function formatDate(dateStr) {
            const date = new Date(dateStr);
            return date.toLocaleString('de-DE');
        }

        // Initial laden
        loadErrors();
    </script>
</body>
</html>
```

**Aufwand:** 6 Stunden

---

## 6. Priorisierung

| Phase | Feature | Umsetzbar? | Aufwand | Nutzen | Priorität |
|-------|---------|------------|---------|--------|-----------|
| **1** | Daten-Struktur analysieren | ✅ Ja | 2h | Hoch | ⭐⭐⭐⭐⭐ |
| **2** | API-Endpoints erstellen | ✅ Ja | 6h | Mittel | ⭐⭐⭐ |
| **3** | HTML-UI mit Fehler-Tabelle | ✅ Ja | 6h | Mittel | ⭐⭐⭐ |

**Gesamtaufwand:** 14 Stunden
**Erwarteter Umsetzungsgrad:** 95% (nach allen Phasen)

---

## 7. Besonderheiten

### 7.1 Eingebettetes Makro

Button "Befehl29" hat ein **eingebettetes Makro** (kein VBA-Code).

**Mögliche Aktionen:**
1. `RunCommand: acCmdDeleteRecord` (Datensatz löschen)
2. `Requery` (Formular aktualisieren)
3. `MessageBox` (Bestätigung anzeigen)

**Lösung:** Access-Formular öffnen, Befehl29 → Eigenschaften → OnClick → Makro anzeigen.

### 7.2 Sync-Prozesse

Fehler werden vermutlich in Sync-Funktionen geschrieben:

**Mögliche VBA-Code-Stellen:**
- `btn_LoewensaalSync_Click()` (frm_Menuefuehrung1)
- `ZK_Daten_uebertragen()` (zfrm_MA_Stunden_Lexware)
- Andere Sync-Module

**Beispiel:**
```vba
On Error GoTo ErrHandler
    ' Sync-Logik...
    Exit Sub

ErrHandler:
    ' Fehler in ztbl_sync schreiben
    CurrentDb.Execute "INSERT INTO ztbl_sync (Datum, Quelle, Fehlertext, Status) " & _
        "VALUES (#" & Now() & "#, 'Löwensaal', '" & Err.Description & "', 'Offen');"
    Resume Next
```

**In HTML/Python:** Gleiche Logik in API-Endpoints implementieren.

### 7.3 Subformular: zsub_syncerror

**Unbekannt:** Die Struktur des Subformulars ist nicht dokumentiert.

**Vermutung:** Zeigt alle Felder von `ztbl_sync` als Tabelle an.

**In HTML:** Durch eigene Tabelle ersetzbar (siehe Phase 3).

### 7.4 Button-Farbe (Rosa/Violett)

**Access:** BackColor = 14136213 (#D7B5D5 - rosa/violett)

**Ungewöhnlich:** Typischerweise ist Rot für "Löschen"-Buttons.

**Vermutung:** Vielleicht kein Löschen-Button, sondern "Aktualisieren" oder "Ignorieren".

---

## 8. Alternative: Nicht umsetzen

**Falls Sync-Fehler-Verwaltung selten benötigt wird:**

❌ **Dieses Formular NICHT nach HTML portieren**

**Begründung:**
1. Niedrige Priorität (Support/Diagnostics)
2. Nur für Admins/Support relevant
3. Sync-Prozesse laufen evtl. nur in Access
4. Aufwand 14h besser in kritische Formulare investieren

**Alternative:**
- Sync-Fehler in Log-Datei schreiben (statt DB-Tabelle)
- Oder: Access-Formular für Support-Team beibehalten

---

## 9. Fazit

**Status:** ❌ **Platzhalter (10%)**

Das SyncError-Formular ist ein **Platzhalter** ohne Funktionalität.

### ✅ Was vorhanden ist:

- Platzhalter-Seite mit Beschreibung
- Schließen-Button

### ❌ Was fehlt:

- Daten-Laden (Sync-Fehler aus ztbl_sync)
- Fehler-Tabelle
- Button-Funktionen (Löschen, Behoben markieren)
- Makro-Inhalt unbekannt

### 📋 Nächste Schritte:

1. **KRITISCH:** Daten-Struktur in Access analysieren (2h)
2. **Danach:** API + HTML-UI umsetzen (12h)
3. **ODER:** Formular in Access belassen (falls selten genutzt)

**Gesamtaufwand:** 14 Stunden (falls umgesetzt)

**Empfehlung:** ⚠️ **Niedrige Priorität** - Erst umsetzen, wenn alle kritischen Formulare fertig sind. Falls nur von Admins genutzt, in Access belassen.

**Alternative Lösung:**
- Sync-Fehler in Log-Datei schreiben (z.B. `sync_errors.log`)
- Admins öffnen Log-Datei bei Problemen
- Kein Formular nötig

**Endgültiger Umsetzungsgrad realistisch:** 95% (nach Analyse + Umsetzung) ODER 0% (nicht umsetzen)
