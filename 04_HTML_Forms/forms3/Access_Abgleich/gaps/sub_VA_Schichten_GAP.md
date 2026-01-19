# Gap-Analyse: sub_VA_Schichten

**Datum:** 2026-01-12
**Access-Formular:** sub_VA_Start
**HTML-Datei:** sub_VA_Schichten.html
**Logic-Datei:** ❌ **FEHLT** (Logic ist inline im HTML)
**Parent-Formular:** frm_va_auftragstamm

---

## Übersicht

| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 8 | 1 | -7 | ❌ |
| Buttons | 0 | 2 | +2 | ✅ |
| TextBoxen | 8 | 0 | -8 | ❌ |
| Labels (Schicht Items) | 0 | ∞ | +∞ | ✅ |
| Events gesamt | 2 | 5 | +3 | ✅ |

**Completion:** 70%

---

## Controls-Vergleich

### ✅ Implementiert (Konzeptionell)

| Access Control | HTML Äquivalent | Status |
|----------------|-----------------|--------|
| ID | data-id | ✅ |
| VA_ID | currentVA_ID (state) | ✅ Via JS |
| VADatum_ID | currentDate (state) | ✅ Via JS |
| VA_Start | .schicht-zeit | ✅ |
| VA_Ende | .schicht-zeit | ✅ |
| MA_Anzahl | .schicht-anzahl | ✅ Soll |
| MA_Anzahl_Ist | .schicht-anzahl | ✅ Ist |
| Bemerkung | - | ❌ Fehlt |

### ❌ Fehlend

| Access Control | Fehlt in HTML | Priorität |
|----------------|---------------|-----------|
| Bemerkung | Nicht angezeigt | P2 |

**Zusätzlich in HTML:**
- Position (nicht in Access-Tabelle)
- Stunden-Berechnung (calcDuration)

---

## Feldnamen-Mapping

| Access-Feld | HTML-Element | Bemerkung |
|-------------|--------------|-----------|
| ID | data-id | ✅ (VAStart_ID oder ID) |
| VA_ID | currentVA_ID | ✅ State |
| VADatum_ID | currentDate | ✅ State |
| VA_Start | .schicht-zeit | ✅ |
| VA_Ende | .schicht-zeit | ✅ |
| MA_Anzahl | .schicht-anzahl | ✅ Soll |
| MA_Anzahl_Ist | .schicht-anzahl | ✅ Ist |
| Bemerkung | - | ❌ Fehlt |

**ZUSÄTZLICH in HTML:**
- Position (s.Position) - nicht in tbl_VA_Start
- Dauer-Berechnung (calcDuration) - nicht in Access

---

## Events-Vergleich

### ✅ Implementiert (HTML)

| Event | Access | HTML | Bemerkung |
|-------|--------|------|-----------|
| OnCurrent | ✅ | ✅ | selectSchicht() |
| BeforeUpdate | ✅ | - | ❌ Validierung fehlt |
| postMessage (SCHICHT_SELECTED) | - | ✅ | Sendet an Parent |
| postMessage (ADD_SCHICHT) | - | ✅ | addSchicht() |
| postMessage (EDIT_SCHICHT) | - | ✅ | editSchicht() |
| message (LOAD_DATA) | - | ✅ | Empfängt VA_ID/Datum |
| message (DAY_SELECTED) | - | ✅ | Reagiert auf Tag-Wechsel |

### ❌ Fehlend

| Access Event | Fehlt in HTML | Priorität |
|--------------|---------------|-----------|
| BeforeUpdate | Validierung fehlt | P1 |
| OnDblClick | Schicht bearbeiten | P2 |

---

## Funktionalität-Vergleich

### ✅ Implementiert

- Anzeige aller Schichten für einen Einsatztag
- Zeitformatierung (HH:MM - HH:MM)
- Besetzungsstatus (Soll/Ist)
- Farbcodierung (grün=vollständig, rot=unterbesetzt)
- Schicht auswählen (Klick)
- Auswahl markieren (active-Klasse)
- PostMessage an Parent bei Auswahl
- Empty-State bei leerer Liste
- Toolbar mit + Schicht / Bearbeiten Buttons
- Auto-Select erste Schicht
- Dauer-Berechnung in Stunden
- Reagiert auf Tag-Wechsel (DAY_SELECTED)

### ❌ Fehlend

- **Keine separate Logic-Datei:** Code ist inline im HTML (Wartbarkeit)
- **Bemerkung wird nicht angezeigt:** Schicht-Kommentare fehlen
- **Position-Feld:** Stammt nicht aus tbl_VA_Start (falsches Feld?)
- **Keine REST-API:** Verwendet hardcoded localhost:5000
- **Keine Fehlerbehandlung:** Nur console.log bei Fehler
- **Keine Inline-Bearbeitung:** Access erlaubt direktes Ändern
- **Validierung fehlt:** BeforeUpdate-Event nicht implementiert

---

## Datenanbindung

### Access RecordSource

```sql
SELECT tbl_VA_Start.*
FROM tbl_VA_Start
ORDER BY tbl_VA_Start.[VA_ID], tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende;
```

**Tabelle:** `tbl_VA_Start`

**Felder:**
- `ID` (PK, auch VAStart_ID genannt)
- `VA_ID` (FK zu Auftrag)
- `VADatum_ID` (FK zu Einsatztag)
- `VA_Start` (Time)
- `VA_Ende` (Time)
- `MA_Anzahl` (Integer Soll)
- `MA_Anzahl_Ist` (Integer Ist)
- `Bemerkung` (Text)

**Master-Child:**
- `ID` (Auftrag) ↔ `VA_ID` (Schicht)
- `cboVADatum` (Datum-ComboBox) ↔ `VADatum_ID` (Schicht)

### HTML API

- **Endpoint (Used):** `http://localhost:5000/api/schichten/${currentVA_ID}?datum=${currentDate}`
- **Status:** ⚠️ Hardcoded URL, keine Dokumentation

### ❌ Fehlend

- REST-API Endpoint `/api/schichten/:va_id` nicht dokumentiert in api_server.py
- Alternative: `/api/dienstplan/schichten` (aus Access-Export-Doku)
- CRUD-Operationen fehlen (POST/PUT/DELETE)
- Keine Validierung
- Keine Fehlerbehandlung außer console.log

---

## Priorität der Gaps

### P0 - Kritisch (Blocker)

(Keine kritischen Blocker vorhanden - Grundfunktionalität ist gegeben)

### P1 - Wichtig

1. **Logic-Datei auslagern:** Code aus HTML in `logic/sub_VA_Schichten.logic.js` verschieben.
2. **REST-API klären:** Ist es `/api/schichten/:va_id` oder `/api/dienstplan/schichten`?
3. **Bemerkung anzeigen:** Schicht-Kommentar fehlt in UI.
4. **Validierung:** BeforeUpdate-Event für Zeitprüfung (Start < Ende).
5. **Fehlerbehandlung:** Proper Error-Handling.

**Aufwand P1:** 4-6 Stunden

### P2 - Nice-to-have

1. **Position-Feld prüfen:** Existiert `Position` in tbl_VA_Start? Falls nein: entfernen.
2. **Doppelklick-Event:** Schicht-Details bearbeiten.
3. **Inline-Bearbeitung:** Start/Ende direkt ändern.

**Aufwand P2:** 2-3 Stunden

---

## Empfehlung

### Completion: 90%

**Status:** ✅ **SEHR GUT - Vollständige Stundenberechnung implementiert**

Das HTML-Formular zeigt Schichten korrekt an und ist funktional. Die Stundenberechnung wurde vollständig implementiert (calc_ZUO_Stunden, calc_ZUO_Stunden_all). Separate Logic-Datei erstellt.

### Kritische Gaps (ERLEDIGT 2026-01-17)

1. ✅ **Logic-File erstellt:** `logic/sub_VA_Schichten.logic.js`
2. ✅ **Stundenberechnung:** `calc_ZUO_Stunden()` und `calc_ZUO_Stunden_all()` implementiert
3. ✅ **Bemerkung anzeigen:** Schicht-Kommentar wird jetzt angezeigt
4. ✅ **Validierung:** `validateSchichtTime()` für Zeit-Format-Prüfung (HH:MM)
5. ✅ **Fehlerbehandlung:** `renderSchichtenError()` für Fehleranzeige
6. ✅ **Inline-Bearbeitung:** Doppelklick auf Zeit öffnet Bearbeitungs-Dialog
7. ✅ **Parent-Kommunikation:** `notifySchichtenChanged()`, `notifySchichtenRecalc()`

### Aufwand Gesamt

- **P0 (Kritisch):** 0 Stunden (erledigt)
- **P1 (Wichtig):** 0 Stunden (erledigt)
- **P2 (Nice-to-have):** 1-2 Stunden (API-Endpoint für recalc_hours)

**Gesamt:** 0-2 Stunden

### Nächste Schritte

1. **Logic-File erstellen:**
   ```javascript
   // logic/sub_VA_Schichten.logic.js
   // Code aus HTML verschieben
   // Struktur analog zu sub_VA_Einsatztage.logic.js
   ```

2. **Bemerkung anzeigen:**
   ```html
   <div class="schicht-details">
       ${s.Position || 'Standard'} | ${calcDuration(s.VA_Start, s.VA_Ende)} Std
       ${s.Bemerkung ? '<br><em>' + s.Bemerkung + '</em>' : ''}
   </div>
   ```

3. **REST-API prüfen:**
   - In api_server.py nach `/api/schichten` oder `/api/dienstplan/schichten` suchen
   - Falls nicht vorhanden: implementieren
   - Dokumentation aktualisieren

4. **Validierung:**
   ```javascript
   function validateSchicht(start, ende) {
       const [sh, sm] = start.split(':').map(Number);
       const [eh, em] = ende.split(':').map(Number);
       const startMin = sh * 60 + sm;
       const endMin = eh * 60 + em;

       if (endMin <= startMin && endMin !== 0) {
           throw new Error('Schichtende muss nach Schichtbeginn liegen');
       }
       return true;
   }
   ```

5. **Fehlerbehandlung:**
   ```javascript
   try {
       const response = await fetch(url);
       if (!response.ok) throw new Error(`HTTP ${response.status}`);
       const data = await response.json();
       renderSchichten(data);
   } catch (error) {
       renderError(error.message);
       notifyParent({ type: 'error', message: error.message });
   }
   ```

6. **Position-Feld prüfen:**
   - Datenbank-Schema prüfen: Hat `tbl_VA_Start` ein `Position`-Feld?
   - Falls nein: `s.Position || 'Standard'` durch andere Logik ersetzen
   - Alternative: Position aus verknüpfter Tabelle laden

---

**Fazit:** Das Subformular ist gut implementiert und funktional. Mit Logic-File, API-Dokumentation und Bemerkung-Anzeige ist es vollständig. Aufwand ist gering bis moderat.
