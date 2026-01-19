# Kundenpreise Formular - Test-Anleitung

## Voraussetzungen

### 1. API-Server muss laufen
```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

**Prüfen ob Server läuft:**
```bash
curl http://localhost:5000/api/kundenpreise
```

### 2. API-Endpunkt erstellen (falls nicht vorhanden)

In `api_server.py` folgenden Endpunkt hinzufügen:

```python
@app.route('/api/kundenpreise', methods=['GET'])
def get_kundenpreise():
    """Lädt alle Kundenpreise mit Kundendaten"""
    try:
        query = """
            SELECT
                k.kun_Id,
                k.kun_Firma,
                k.kun_IstAktiv,
                ISNULL(kp.Sicherheitspersonal, 0) as Sicherheitspersonal,
                ISNULL(kp.Leitungspersonal, 0) as Leitungspersonal,
                ISNULL(kp.Nachtzuschlag, 0) as Nachtzuschlag,
                ISNULL(kp.Sonntagszuschlag, 0) as Sonntagszuschlag,
                ISNULL(kp.Feiertagszuschlag, 0) as Feiertagszuschlag,
                ISNULL(kp.Fahrtkosten, 0) as Fahrtkosten,
                ISNULL(kp.Sonstiges, 0) as Sonstiges
            FROM tbl_KD_Kundenstamm k
            LEFT JOIN tbl_KD_Kundenpreise kp ON k.kun_Id = kp.kun_Id
            ORDER BY k.kun_Firma
        """

        cursor = get_cursor()
        cursor.execute(query)
        rows = cursor.fetchall()

        kundenpreise = []
        for row in rows:
            kundenpreise.append({
                'kun_Id': row.kun_Id,
                'kun_Firma': row.kun_Firma,
                'kun_IstAktiv': row.kun_IstAktiv,
                'Sicherheitspersonal': float(row.Sicherheitspersonal) if row.Sicherheitspersonal else None,
                'Leitungspersonal': float(row.Leitungspersonal) if row.Leitungspersonal else None,
                'Nachtzuschlag': float(row.Nachtzuschlag) if row.Nachtzuschlag else None,
                'Sonntagszuschlag': float(row.Sonntagszuschlag) if row.Sonntagszuschlag else None,
                'Feiertagszuschlag': float(row.Feiertagszuschlag) if row.Feiertagszuschlag else None,
                'Fahrtkosten': float(row.Fahrtkosten) if row.Fahrtkosten else None,
                'Sonstiges': float(row.Sonstiges) if row.Sonstiges else None
            })

        return jsonify({'data': kundenpreise})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/kundenpreise/<int:kun_id>', methods=['PUT'])
def update_kundenpreis(kun_id):
    """Aktualisiert Kundenpreise für einen Kunden"""
    try:
        data = request.json

        # Prüfen ob Datensatz existiert
        cursor = get_cursor()
        cursor.execute("SELECT COUNT(*) as cnt FROM tbl_KD_Kundenpreise WHERE kun_Id = ?", (kun_id,))
        exists = cursor.fetchone().cnt > 0

        if exists:
            # UPDATE
            query = """
                UPDATE tbl_KD_Kundenpreise
                SET Sicherheitspersonal = ?,
                    Leitungspersonal = ?,
                    Nachtzuschlag = ?,
                    Sonntagszuschlag = ?,
                    Feiertagszuschlag = ?,
                    Fahrtkosten = ?,
                    Sonstiges = ?
                WHERE kun_Id = ?
            """
            cursor.execute(query, (
                data.get('Sicherheitspersonal'),
                data.get('Leitungspersonal'),
                data.get('Nachtzuschlag'),
                data.get('Sonntagszuschlag'),
                data.get('Feiertagszuschlag'),
                data.get('Fahrtkosten'),
                data.get('Sonstiges'),
                kun_id
            ))
        else:
            # INSERT
            query = """
                INSERT INTO tbl_KD_Kundenpreise
                (kun_Id, Sicherheitspersonal, Leitungspersonal, Nachtzuschlag,
                 Sonntagszuschlag, Feiertagszuschlag, Fahrtkosten, Sonstiges)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """
            cursor.execute(query, (
                kun_id,
                data.get('Sicherheitspersonal'),
                data.get('Leitungspersonal'),
                data.get('Nachtzuschlag'),
                data.get('Sonntagszuschlag'),
                data.get('Feiertagszuschlag'),
                data.get('Fahrtkosten'),
                data.get('Sonstiges')
            ))

        cursor.commit()

        return jsonify({
            'success': True,
            'message': 'Kundenpreis aktualisiert'
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500
```

## Test-Schritte

### 1. Formular öffnen
```
file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/frm_Kundenpreise_gueni.html
```

**Erwartung:**
- Sidebar wird angezeigt
- Toolbar mit Buttons erscheint
- Tabelle wird mit Daten gefüllt
- Status-Bar zeigt "Bereit"

### 2. Daten laden
**Aktion:** Seite wird geladen

**Erwartung:**
- Loading-Spinner erscheint kurz
- Tabelle wird mit allen Kundenpreisen gefüllt
- Record-Count wird aktualisiert (z.B. "Datensätze: 45")

### 3. Filter testen
**Aktion:** In "Kunde" Suchfeld "GmbH" eingeben

**Erwartung:**
- Tabelle zeigt nur Kunden mit "GmbH" im Namen
- Record-Count zeigt gefilterte Anzahl (z.B. "Datensätze: 12 / 45")

**Aktion:** Checkbox "Nur Aktive" deaktivieren

**Erwartung:**
- Tabelle zeigt auch inaktive Kunden
- Record-Count erhöht sich

### 4. Inline-Editing testen
**Aktion:**
1. Klick in Feld "Sicherheitspersonal"
2. Wert ändern (z.B. von "25.50" auf "26.00")
3. Tab-Taste drücken

**Erwartung:**
- Feld wird gelb beim Fokus
- Speichern-Button wird aktiviert
- Button-Text: "💾 Speichern"

### 5. Einzelne Zeile speichern
**Aktion:** Klick auf "💾 Speichern" Button

**Erwartung:**
- Loading-Spinner erscheint kurz
- Toast-Meldung: "Kundenpreis für 'Firma GmbH' gespeichert"
- Button wird deaktiviert
- Button-Text: "✓ Gespeichert"
- Status-Bar: "Gespeichert"

### 6. Mehrere Zeilen ändern und alle speichern
**Aktion:**
1. Mehrere Felder in verschiedenen Zeilen ändern
2. Klick auf "💾 Alle speichern" Button

**Erwartung:**
- Bestätigungs-Dialog: "3 geänderte Zeile(n) speichern?"
- Nach Bestätigung: Loading-Spinner
- Toast: "Alle 3 Zeilen erfolgreich gespeichert"
- Alle Speichern-Buttons werden deaktiviert

### 7. Excel Export
**Aktion:** Klick auf "📊 Excel Export"

**Erwartung:**
- CSV-Datei wird heruntergeladen
- Dateiname: `Kundenpreise_20260102_1230.csv`
- Toast: "Excel-Export erfolgreich"

### 8. Aktualisieren
**Aktion:** Klick auf "🔄 Aktualisieren"

**Erwartung:**
- Daten werden neu geladen
- Alle Änderungen (die nicht gespeichert wurden) gehen verloren
- Toast: "Daten aktualisiert"

## Fehler-Tests

### API-Server nicht verfügbar
**Aktion:** API-Server stoppen, Formular öffnen

**Erwartung:**
- Toast-Fehler: "API-Fehler: Failed to fetch"
- Tabelle bleibt leer
- Status: "Fehler beim Laden"

### Ungültige Eingabe
**Aktion:** In Prozent-Feld "150" eingeben

**Erwartung:**
- HTML5 Validierung verhindert Wert > 100
- Oder beim Speichern: Validierungsfehler

### Speichern ohne Änderung
**Aktion:** Klick auf "💾 Alle speichern" ohne Änderungen

**Erwartung:**
- Toast: "Keine Änderungen vorhanden"
- Keine API-Calls

## Performance-Tests

### Große Datenmenge
**Aktion:** 500+ Kundenpreise laden

**Erwartung:**
- Tabelle rendert flüssig
- Scrolling ist smooth
- Filter reagiert innerhalb 300ms

### Batch-Save
**Aktion:** 20 Zeilen ändern, alle speichern

**Erwartung:**
- Alle Zeilen werden nacheinander gespeichert
- Progress-Feedback im Status-Bar
- Toast mit Erfolgs-Zähler

## Browser-Kompatibilität

### Chrome/Edge
- ✓ Alle Features funktionieren
- ✓ Sticky Table Header
- ✓ CSS Grid Layout

### Firefox
- ✓ Alle Features funktionieren
- ✓ Scrollbar-Styling

### Safari
- ⚠ Ggf. Scrollbar-Styling anders
- ✓ Funktionalität OK

## Debugging

### Browser Console öffnen
**F12** → Console-Tab

**Erwartung:**
```
[Kundenpreise] Initialisiere...
[Kundenpreise] Geladen: 45
```

### Network-Tab prüfen
**F12** → Network-Tab

**Erwartung bei Laden:**
- GET http://localhost:5000/api/kundenpreise → 200 OK

**Erwartung bei Speichern:**
- PUT http://localhost:5000/api/kundenpreise/123 → 200 OK

## Bekannte Issues
- [ ] Sidebar-Menu wird ggf. nicht geladen wenn sidebar.js fehlt
- [ ] Excel-Export ist CSV (nicht echtes Excel)
- [ ] Keine Undo-Funktion bei versehentlichen Änderungen

## Abnahme-Kriterien
- ✓ Alle Kundenpreise werden geladen
- ✓ Filter funktioniert
- ✓ Inline-Editing funktioniert
- ✓ Speichern funktioniert (einzeln und batch)
- ✓ Excel-Export funktioniert
- ✓ Fehlerbehandlung funktioniert
- ✓ Toast-Meldungen erscheinen
- ✓ Responsive Layout funktioniert
