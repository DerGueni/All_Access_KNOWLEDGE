# Gap-Analyse: frm_Kundenpreise_gueni

**Datum:** 2026-01-12
**Status:** HTML teilweise implementiert (Grundgerüst vorhanden)
**Priorität:** MITTEL (spezialisiertes Verwaltungsformular)

---

## Zusammenfassung

Das Formular dient zur Verwaltung von kundenspezifischen Preisen für verschiedene Dienstleistungskategorien. Die HTML-Version enthält ein Grundgerüst mit Menü, aber keine funktionale Preismatrix.

**Besonderheit:** Matrix-artige Darstellung mit mehreren Preiskategorien pro Kunde. Ähnlich einer Kreuztabelle/Pivot-Ansicht.

---

## 1. Datenquelle

### Access (Original)
- **Query:** `qry_Kundenpreise_gueni2`
- **Felder:** kun_Firma, Sicherheitspersonal, Leitungspersonal, Nachtzuschlag, Sonntagszuschlag, Feiertagszuschlag, Fahrtkosten, Sonstiges

### HTML (Aktuell)
- **Status:** Keine Datenanbindung
- **Gap:** Vollständige API-Integration fehlt

### Erforderlich
```javascript
// Endpunkte
GET /api/kundenpreise              // Liste aller Kundenpreise
GET /api/kundenpreise/:kun_id      // Preise für einen Kunden
PUT /api/kundenpreise/:kun_id      // Preise aktualisieren
```

**Query-Definition:**
```sql
SELECT
    k.ID AS kun_Id,
    k.kun_Firma,
    p.Sicherheitspersonal,
    p.Leitungspersonal,
    p.Nachtzuschlag,
    p.Sonntagszuschlag,
    p.Feiertagszuschlag,
    p.Fahrtkosten,
    p.Sonstiges
FROM tbl_KD_Kundenstamm k
LEFT JOIN tbl_KD_Preise p ON k.ID = p.kun_Id
WHERE k.kun_IstAktiv = True
ORDER BY k.kun_Firma
```

---

## 2. Controls / UI-Elemente

### Access-Controls (8 Haupt-Elemente)

| Control | Typ | Access-Position | Größe | Status HTML |
|---------|-----|-----------------|-------|-------------|
| kun_Firma | TextBox | 113, 0 | 4374 x 315 | ❌ Fehlt |
| Sicherheitspersonal | TextBox (Editable) | 4425, 0 | 1035 x 315 | ❌ Fehlt |
| Leitungspersonal | TextBox (Editable) | 5470, 3 | 915 x 315 | ❌ Fehlt |
| Nachtzuschlag | TextBox (Editable) | 6395, 0 | 915 x 315 | ❌ Fehlt |
| Sonntagszuschlag | TextBox (Editable) | 7320, 0 | 915 x 315 | ❌ Fehlt |
| Feiertagszuschlag | TextBox (Editable) | 8245, 0 | 915 x 315 | ❌ Fehlt |
| Fahrtkosten | TextBox (ReadOnly) | 9170, 0 | 1254 x 315 | ❌ Fehlt |
| Sonstiges | TextBox (ReadOnly) | 10434, 0 | 915 x 315 | ❌ Fehlt |

**Labels (Header):**
- kun_Firma_Bezeichnungsfeld
- Sicherheitspersonal_Bezeichnungsfeld
- Leitungspersonal_Bezeichnungsfeld
- etc.

### HTML (Aktuell)
```html
<!-- Nur Menü vorhanden, keine Preismatrix -->
<div class="left-menu">...</div>
<div class="content-area">
    <!-- FEHLT: Preismatrix-Tabelle -->
</div>
```

---

## 3. Events und Interaktionen

### Access-Events

| Event | Control | Handler | Funktion |
|-------|---------|---------|----------|
| OnDblClick | Sicherheitspersonal | [Event Procedure] | Preis-Editor öffnen? |
| OnDblClick | Leitungspersonal | [Event Procedure] | Preis-Editor öffnen? |
| OnDblClick | Nachtzuschlag | [Event Procedure] | Preis-Editor öffnen? |
| OnDblClick | Sonntagszuschlag | [Event Procedure] | Preis-Editor öffnen? |
| OnDblClick | Feiertagszuschlag | [Event Procedure] | Preis-Editor öffnen? |
| OnDblClick | Fahrtkosten | [Event Procedure] | Preis-Editor öffnen? |
| OnDblClick | Sonstiges | [Event Procedure] | Preis-Editor öffnen? |

**Hinweis:** VBA-Code für DblClick-Events fehlt im Export → Funktion unklar.

### HTML (Benötigt)
```javascript
// Inline-Editing für Preisfelder
function enableInlineEdit(field, kunId) {
    // Click → Input-Feld
    // Blur → Speichern via API
    // Enter → Nächstes Feld
}

// Navigation zwischen Kunden
function navigateCustomer(direction) {
    // Previous/Next Kunde laden
}
```

---

## 4. Layout-Unterschiede

### Access-Layout
- **View:** SingleForm (ein Kunde auf einmal)
- **Navigation:** Navigation Buttons aktiviert
- **Layout:** Horizontal angeordnete Preisfelder (Matrix-Style)
- **Breite:** Sehr breit (~11.300 Twips = ~770px)

### HTML-Layout (Erforderlich)
```
+------------------+----------------------------------------------+
| Menü             | Kundenpreise Matrix                          |
| (185px)          |                                              |
|                  | [Kunde] [Sicher.] [Leitung] [Nacht] [Sonnt..|
|                  | Kunde A   45,00€    50,00€   15,00€  25,00€ |
|                  | Kunde B   42,00€    48,00€   12,00€  20,00€ |
|                  | ...                                          |
+------------------+----------------------------------------------+
```

**Empfohlene Struktur:**
```html
<table class="price-matrix">
  <thead>
    <tr>
      <th>Kunde</th>
      <th>Sicherheit</th>
      <th>Leitung</th>
      <th>Nacht</th>
      <th>Sonntag</th>
      <th>Feiertag</th>
      <th>Fahrt</th>
      <th>Sonstiges</th>
    </tr>
  </thead>
  <tbody id="priceRows">
    <!-- Dynamisch gefüllt -->
  </tbody>
</table>
```

---

## 5. Funktionale Gaps

### ❌ FEHLT: Preismatrix-Tabelle
- **Access:** Einzelner Kunde mit Navigation
- **HTML:** Sollte Tabelle mit allen Kunden zeigen (effizienter)
- **Lösung:** DataGrid mit Inline-Editing

### ❌ FEHLT: Inline-Editing
- **Access:** Direkte Bearbeitung in TextBox
- **HTML:** Benötigt ContentEditable oder Input-Felder
- **Events:** Blur → Auto-Save, Enter → Nächstes Feld

### ❌ FEHLT: Währungsformatierung
- **Access:** Automatisch durch Number Format
- **HTML:** Manuell via JavaScript
```javascript
function formatEuro(value) {
    return new Intl.NumberFormat('de-DE', {
        style: 'currency',
        currency: 'EUR'
    }).format(value);
}
```

### ❌ FEHLT: Validierung
- **Access:** Implizit durch Number-Typ
- **HTML:** Benötigt explizite Validierung
```javascript
function validatePrice(value) {
    const num = parseFloat(value);
    return !isNaN(num) && num >= 0;
}
```

### ❌ FEHLT: DblClick-Funktionalität
- **Access:** 7 Controls mit DblClick-Events
- **Funktion:** Unklar (kein VBA-Code im Export)
- **Vermutung:** Preis-Historie oder Detail-Editor?

---

## 6. API-Anforderungen

### Neue Endpoints (Backend)

```python
# api_server.py

@app.route('/api/kundenpreise', methods=['GET'])
def get_kundenpreise():
    """Liste aller Kundenpreise"""
    cursor.execute("""
        SELECT
            k.ID AS kun_Id,
            k.kun_Firma,
            p.Sicherheitspersonal,
            p.Leitungspersonal,
            p.Nachtzuschlag,
            p.Sonntagszuschlag,
            p.Feiertagszuschlag,
            p.Fahrtkosten,
            p.Sonstiges
        FROM tbl_KD_Kundenstamm k
        LEFT JOIN tbl_KD_Preise p ON k.ID = p.kun_Id
        WHERE k.kun_IstAktiv = True
        ORDER BY k.kun_Firma
    """)
    return jsonify(cursor.fetchall())

@app.route('/api/kundenpreise/<int:kun_id>', methods=['GET'])
def get_kundenpreis(kun_id):
    """Preise für einen Kunden"""
    cursor.execute("""
        SELECT * FROM tbl_KD_Preise WHERE kun_Id = ?
    """, (kun_id,))
    return jsonify(cursor.fetchone() or {})

@app.route('/api/kundenpreise/<int:kun_id>', methods=['PUT'])
def update_kundenpreis(kun_id):
    """Preis aktualisieren"""
    data = request.json
    field = data['field']  # z.B. 'Sicherheitspersonal'
    value = data['value']

    cursor.execute(f"""
        UPDATE tbl_KD_Preise
        SET {field} = ?
        WHERE kun_Id = ?
    """, (value, kun_id))
    conn.commit()
    return jsonify({'success': True})
```

---

## 7. Implementierungs-Roadmap

### Phase 1: Basis-Darstellung (2-3h)
- [ ] HTML-Struktur für Preismatrix-Tabelle
- [ ] CSS für Tabellen-Layout (sticky header)
- [ ] API-Endpoints implementieren (Backend)
- [ ] Daten laden und rendern

### Phase 2: Inline-Editing (2-3h)
- [ ] ContentEditable oder Input-Felder
- [ ] Auto-Save on Blur
- [ ] Enter-Navigation zwischen Feldern
- [ ] Validierung (nur Zahlen, >= 0)

### Phase 3: UX-Features (1-2h)
- [ ] Währungsformatierung (€)
- [ ] Undo/Redo für Änderungen
- [ ] Highlight bei Änderung (visuelles Feedback)
- [ ] Suchfeld für Kunden-Filter

### Phase 4: DblClick-Funktion (1-2h)
- [ ] VBA-Code analysieren (was macht DblClick?)
- [ ] Funktion in HTML nachbauen
- [ ] Evtl. Preis-Historie-Dialog

**Gesamt-Aufwand:** 6-10 Stunden

---

## 8. Technische Herausforderungen

### Challenge 1: Matrix-Layout
- **Problem:** Viele Spalten (8) → Horizontal Scrolling?
- **Lösung:** Sticky erste Spalte (Kundenname), Rest scrollbar

### Challenge 2: Inline-Editing Performance
- **Problem:** Viele Kunden × 7 editierbare Felder
- **Lösung:** Lazy Loading + Virtual Scrolling (nur sichtbare Zeilen rendern)

### Challenge 3: Währungsformat bei Eingabe
- **Problem:** User tippt "45" → soll "45,00 €" werden
- **Lösung:** Input-Type="text" mit Custom Formatter
```javascript
input.addEventListener('blur', (e) => {
    const value = parseFloat(e.target.value.replace(',', '.'));
    e.target.value = formatEuro(value);
});
```

### Challenge 4: ReadOnly-Felder
- **Fahrtkosten** und **Sonstiges** sind in Access ReadOnly
- **Warum?** Evtl. berechnet oder geschützt
- **Lösung:** `<input disabled>` oder `contenteditable="false"`

---

## 9. Abhängigkeiten

### Backend-Tabellen
- `tbl_KD_Kundenstamm` (Kundeninfo)
- `tbl_KD_Preise` (Preistabelle)

**Schema (angenommen):**
```sql
CREATE TABLE tbl_KD_Preise (
    ID INT PRIMARY KEY,
    kun_Id INT,  -- FK zu tbl_KD_Kundenstamm
    Sicherheitspersonal DECIMAL(10,2),
    Leitungspersonal DECIMAL(10,2),
    Nachtzuschlag DECIMAL(10,2),
    Sonntagszuschlag DECIMAL(10,2),
    Feiertagszuschlag DECIMAL(10,2),
    Fahrtkosten DECIMAL(10,2),
    Sonstiges DECIMAL(10,2),
    FOREIGN KEY (kun_Id) REFERENCES tbl_KD_Kundenstamm(ID)
);
```

### Frontend-Dateien
- `frm_Kundenpreise_gueni.html` (existiert)
- `frm_Kundenpreise_gueni.logic.js` (fehlt → neu erstellen)

---

## 10. Offene Fragen

1. **DblClick-Funktionalität?**
   - Was passiert bei DblClick in Access?
   - Kein VBA-Code im Export → Funktion unklar
   - **Action:** Access-Original öffnen und testen

2. **Fahrtkosten/Sonstiges ReadOnly?**
   - Warum sind diese Felder schreibgeschützt?
   - Werden sie berechnet oder manuell gesetzt?
   - **Action:** Datenbanklogik prüfen

3. **Preis-Historie?**
   - Gibt es eine Historie alter Preise?
   - Tabelle `tbl_KD_Preise_Historie`?
   - **Action:** Datenbank-Schema prüfen

4. **Variante "gueni"?**
   - Es gibt auch `frm_Kundenpreise` (ohne _gueni)
   - Unterschied zwischen den beiden?
   - **Action:** Beide Formulare vergleichen

---

## Priorität: MITTEL

**Begründung:**
- Spezialisiertes Verwaltungsformular
- Nicht täglich verwendet
- Kann zunächst über Access bedient werden
- Erst implementieren wenn Hauptformulare fertig

**Empfehlung:**
1. Erst Hauptformulare fertigstellen (Mitarbeiter, Kunden, Aufträge)
2. Dann Kundenpreise als "Bonus"-Feature
3. Matrix-Layout gut für Demo-Zwecke (zeigt Kompetenz)
