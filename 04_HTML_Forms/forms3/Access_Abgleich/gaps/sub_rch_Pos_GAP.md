# Gap-Analyse: sub_rch_Pos

**Datum:** 2026-01-12
**Access-Formular:** sub_rch_Pos (auch: sub_Rch_Pos_Auftrag, sub_tbl_Rch_Pos_Auftrag)
**HTML-Datei:** sub_rch_Pos.html
**Logic-Datei:** logic/sub_rch_Pos.logic.js
**Parent-Formulare:** frm_va_auftragstamm, frm_Rechnung

---

## Übersicht

| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 8 | 7 | -1 | ✅ |
| Buttons | 0 | 2 | +2 | ✅ |
| TextBoxen | 8 | 0 | -8 | ⚠️ |
| Labels (Header) | 0 | 7 | +7 | ✅ |
| Events gesamt | 1 | 7 | +6 | ✅ |

**Completion:** 85%

---

## Controls-Vergleich

### ✅ Implementiert

| Access Control | HTML Äquivalent | Status |
|----------------|-----------------|--------|
| Rechnungs_ID | Hidden (state.RCH_ID) | ✅ Via JS |
| VA_ID | Hidden (Link-Parameter) | ✅ Via JS |
| PosNr | Table Column (#) | ✅ |
| Bezeichnung | Table Column (Bezeichnung) | ✅ |
| Menge | Table Column (Menge) | ✅ |
| Einheit | Table Column (Einheit) | ✅ |
| Einzelpreis | Table Column (Einzelpreis) | ✅ |
| Gesamtpreis | Table Column (Gesamt) | ✅ Berechnet |

**Zusätzlich in HTML:**
- Art-Nr Spalte (nicht in Access)
- Footer mit Summe Netto, MwSt, Brutto (in Access nur Gesamtsumme)

### ❌ Fehlend

| Access Control | Fehlt in HTML | Priorität |
|----------------|---------------|-----------|
| MwSt_Satz | Nicht sichtbar | P1 |

**Hinweis:** MwSt_Satz existiert in Access, wird aber in HTML nur pauschal mit 19% berechnet (hardcoded im Footer).

---

## Feldnamen-Mapping

| Access-Feld | HTML-Spalte | Bemerkung |
|-------------|-------------|-----------|
| Rechnungs_ID | (state) | ✅ Hidden |
| VA_ID | (state) | ✅ Hidden |
| PosNr | # | ✅ Pos_Nr in Logic |
| Bezeichnung | Bezeichnung | ✅ |
| Menge | Menge | ✅ |
| Einheit | Einheit | ✅ |
| Einzelpreis | Einzelpreis | ✅ |
| Gesamtpreis | Gesamt | ✅ Berechnet |
| MwSt_Satz | - | ❌ Fehlt |

**ZUSÄTZLICH in HTML:**
- Art-Nr (nicht in Access-Tabelle)

---

## Events-Vergleich

### ✅ Implementiert (HTML)

| Event | Access | HTML | Bemerkung |
|-------|--------|------|-----------|
| Row Click | - | ✅ | selectRow() |
| Row DblClick | - | ✅ | Sendet 'row_dblclick' an Parent |
| AfterUpdate | ✅ | ✅ | notifyParentSum() bei Änderungen |
| postMessage (ready) | - | ✅ | subform_ready |
| postMessage (selection) | - | ✅ | subform_selection |
| postMessage (sum_changed) | - | ✅ | sum_changed |
| set_link_params | - | ✅ | Empfängt RCH_ID vom Parent |
| requery | - | ✅ | loadData() |

### ❌ Fehlend

| Access Event | Fehlt in HTML | Priorität |
|--------------|---------------|-----------|
| BeforeUpdate | Validierung fehlt | P1 |
| OnCurrent | ✅ Implementiert | - |

---

## Funktionalität-Vergleich

### ✅ Implementiert

- Anzeige von Rechnungspositionen in Tabellenform
- Auswahl einer Position (Klick)
- Doppelklick sendet Event an Parent (edit_position)
- Summenberechnung (Netto, MwSt, Brutto)
- Anzahl-Anzeige
- Parent-Kommunikation via postMessage
- WebView2-Bridge Integration
- Empty-State bei leerer Liste
- Currency-Formatierung (de-DE)
- Footer mit 3 Summenzeilen

### ❌ Fehlend

- **Neue Position anlegen** (btnNeu ist vorhanden, aber ohne Funktion)
- **Position löschen** (btnLöschen ist vorhanden, aber ohne Funktion)
- **Inline-Editing** (Access erlaubt direktes Bearbeiten)
- **MwSt-Satz pro Position** (statt pauschal 19%)
- **Validierung** vor dem Speichern (BeforeUpdate)
- **CRUD-Operationen** über REST-API

---

## Datenanbindung

### Access RecordSource

```
tbl_Rch_Pos
```
oder
```sql
SELECT * FROM qry_Rch_Pos_Auftrag ORDER BY PosNr
```

**Tabellen:**
- `tbl_Rch_Pos` (Primärtabelle)
- `qry_Rch_Pos_Auftrag` (Query für Auftragsbezug)

**Master-Child:**
- frm_Rechnung: `Rechnungs_ID` ↔ `Rechnungs_ID`
- frm_va_auftragstamm: `ID` ↔ `VA_ID`

### HTML API

- **Endpoint (Expected):** `/api/rechnungen/:id/positionen` (GET)
- **Methode:** `Bridge.sendEvent('loadSubformData', { type: 'rch_positionen', rch_id: ... })`
- **Status:** ⚠️ Verwendet WebView2-Bridge statt REST-API

### ❌ Fehlend

- REST-API Endpoint `/api/rechnungen/:id/positionen` nicht dokumentiert
- POST/PUT/DELETE für CRUD-Operationen fehlen
- Keine Validierung der Eingabedaten
- Keine Fehlerbehandlung bei API-Fehlern

---

## Priorität der Gaps

### P0 - Kritisch (Blocker)

(Keine kritischen Blocker vorhanden)

### P1 - Wichtig

1. **CRUD-Funktionen fehlen:** btnNeu und btnLöschen haben keine Implementierung.
2. **MwSt-Satz pro Position:** Statt pauschal 19% sollte der Satz aus dem Datensatz kommen.
3. **REST-API fehlt:** Endpoint `/api/rechnungen/:id/positionen` existiert nicht.
4. **Inline-Editing:** Direktes Bearbeiten in Tabelle (wie Access).

**Aufwand P1:** 6-8 Stunden

### P2 - Nice-to-have

1. **Validierung:** BeforeUpdate-Event für Datenprüfung.
2. **Art-Nr Feld entfernen:** Existiert nicht in Access-Tabelle.

**Aufwand P2:** 2-3 Stunden

---

## Empfehlung

### Completion: 85%

**Status:** ✅ **GUT - Grundfunktionen vorhanden, Detailverbesserungen nötig**

Das HTML-Formular zeigt die korrekten Felder aus der Access-Tabelle `tbl_Rch_Pos` und ist größtenteils funktional. Die Hauptfunktionalität (Anzeige, Auswahl, Summenberechnung) ist implementiert.

### Kritische Gaps

1. **CRUD-Funktionen implementieren:** Neue Position anlegen, Position löschen.
2. **REST-API erstellen:** Endpoint für Rechnungspositionen.
3. **MwSt-Satz dynamisch:** Aus Datensatz lesen statt hardcoded 19%.

### Aufwand Gesamt

- **P0 (Kritisch):** 0 Stunden
- **P1 (Wichtig):** 6-8 Stunden
- **P2 (Nice-to-have):** 2-3 Stunden

**Gesamt:** 8-11 Stunden

### Nächste Schritte

1. **REST-API implementieren:** `/api/rechnungen/:id/positionen` in api_server.py.
2. **CRUD-Logic hinzufügen:**
   - `neuePosition()` implementieren
   - `loeschePosition()` implementieren
   - Inline-Editing für Menge, Einzelpreis
3. **MwSt-Satz dynamisch:**
   - Feld aus Datensatz lesen
   - In Footer-Berechnung verwenden
4. **Validierung:**
   - Pflichtfelder prüfen (Bezeichnung, Menge, Einzelpreis)
   - Positive Zahlen erzwingen
5. **Art-Nr Spalte prüfen:** Ist das Feld tatsächlich benötigt?

---

**Fazit:** Das Subformular ist gut implementiert und zeigt die richtigen Daten. Mit CRUD-Funktionen und REST-API ist es vollständig einsatzbereit. Aufwand ist überschaubar.
