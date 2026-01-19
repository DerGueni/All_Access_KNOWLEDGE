# Gap-Analyse: sub_VA_Einsatztage

**Datum:** 2026-01-12
**Access-Formular:** sub_VA_Einsatztage (basierend auf tbl_VA_AnzTage)
**HTML-Datei:** sub_VA_Einsatztage.html
**Logic-Datei:** ❌ **FEHLT** (Logic ist inline im HTML)
**Parent-Formulare:** frm_va_auftragstamm, frm_Einsatzuebersicht

---

## Übersicht

| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 6 | 1 | -5 | ❌ |
| Buttons | 0 | 2 | +2 | ✅ |
| TextBoxen | 6 | 0 | -6 | ❌ |
| Labels (Day Items) | 0 | ∞ | +∞ | ✅ |
| Events gesamt | 2 | 4 | +2 | ✅ |

**Completion:** 60%

---

## Controls-Vergleich

### ✅ Implementiert (Konzeptionell)

| Access Control | HTML Äquivalent | Status |
|----------------|-----------------|--------|
| ID | data-attribute | ✅ Hidden |
| VA_ID | currentVA_ID (state) | ✅ Via JS |
| VADatum | day-item element | ✅ data-date |
| Wochentag | .day-weekday | ✅ Berechnet |
| Anzahl_Soll | .day-status | ✅ Angezeigt |
| Anzahl_Ist | .day-status | ✅ Angezeigt |
| Status | .day-status.incomplete | ✅ Via CSS-Klasse |

### ❌ Fehlend

| Access Control | Fehlt in HTML | Priorität |
|----------------|---------------|-----------|
| (Keine kritischen Felder fehlen) | - | - |

**Hinweis:** HTML zeigt alle wesentlichen Felder, jedoch in einer anderen Struktur (Liste statt Endlosformular).

---

## Feldnamen-Mapping

| Access-Feld | HTML-Element | Bemerkung |
|-------------|--------------|-----------|
| ID | data-date | ⚠️ Datum statt ID |
| VA_ID | currentVA_ID | ✅ State |
| VADatum | .day-date | ✅ |
| Wochentag | .day-weekday | ✅ Berechnet |
| Anzahl_Soll | .day-status | ✅ |
| Anzahl_Ist | .day-status | ✅ |
| Status | CSS-Klasse | ✅ incomplete/complete |

**PROBLEM:** HTML verwendet `data-date` statt `data-id`, was bei Mehrfach-Einsätzen am gleichen Datum zu Problemen führen kann.

---

## Events-Vergleich

### ✅ Implementiert (HTML)

| Event | Access | HTML | Bemerkung |
|-------|--------|------|-----------|
| OnClick | ✅ | ✅ | selectDay() |
| OnDblClick | ✅ | - | ❌ Fehlt in HTML |
| postMessage (DAY_SELECTED) | - | ✅ | Sendet an Parent |
| postMessage (ADD_DAY) | - | ✅ | addDay() |
| postMessage (REMOVE_DAY) | - | ✅ | removeDay() |
| message (LOAD_DATA) | - | ✅ | Empfängt VA_ID |

### ❌ Fehlend

| Access Event | Fehlt in HTML | Priorität |
|--------------|---------------|-----------|
| OnDblClick | Tag-Details öffnen | P1 |

---

## Funktionalität-Vergleich

### ✅ Implementiert

- Anzeige aller Einsatztage für einen Auftrag
- Datumsformatierung (de-DE)
- Wochentag-Berechnung (Mo-So)
- Besetzungsstatus (Soll/Ist)
- Farbcodierung (grün=vollständig, rot=unterbesetzt)
- Tag auswählen (Klick)
- Auswahl markieren (active-Klasse)
- PostMessage an Parent bei Auswahl
- Empty-State bei leerer Liste
- Toolbar mit + Tag / - Tag Buttons
- Auto-Select ersten Tag

### ❌ Fehlend

- **Kein Doppelklick-Event:** Tag-Details öffnen fehlt
- **Keine separate Logic-Datei:** Code ist inline im HTML (Wartbarkeit)
- **ID wird nicht verwendet:** Stattdessen Datum als Identifier (Fehlerquelle!)
- **Keine REST-API:** Verwendet hardcoded localhost:5000
- **Keine Fehlerbehandlung:** Nur console.log bei Fehler
- **Keine Inline-Bearbeitung:** Access erlaubt direktes Ändern von Soll/Ist

---

## Datenanbindung

### Access RecordSource

```
tbl_VA_AnzTage
```
oder
```sql
SELECT * FROM qry_VA_Einsatztage WHERE VA_ID = X ORDER BY VADatum
```

**Tabelle:** `tbl_VA_AnzTage`

**Felder:**
- `ID` (PK)
- `VA_ID` (FK zu Auftrag)
- `VADatum` (Date)
- `Anzahl_Soll` (Integer)
- `Anzahl_Ist` (Integer)

**Master-Child:** `ID` (Auftrag) ↔ `VA_ID` (Einsatztag)

### HTML API

- **Endpoint (Used):** `http://localhost:5000/api/einsatztage/${currentVA_ID}`
- **Status:** ⚠️ Hardcoded URL, keine Fehlerbehandlung

### ❌ Fehlend

- REST-API Endpoint `/api/einsatztage/:va_id` nicht dokumentiert in api_server.py
- CRUD-Operationen fehlen (POST/PUT/DELETE)
- Keine Validierung
- Keine Fehlerbehandlung außer console.log

---

## Priorität der Gaps

### P0 - Kritisch (Blocker)

1. **ID statt Datum verwenden:** HTML verwendet `data-date` als Identifier, sollte aber `data-id` verwenden (eindeutige ID aus Datenbank). Bei mehreren Einsätzen am gleichen Datum gibt es Probleme.

**Aufwand P0:** 2-3 Stunden

### P1 - Wichtig

1. **Logic-Datei auslagern:** Code aus HTML in separate .logic.js Datei verschieben (Wartbarkeit, Konsistenz).
2. **Doppelklick-Event:** Tag-Details öffnen.
3. **REST-API dokumentieren/implementieren:** `/api/einsatztage/:va_id`.
4. **Fehlerbehandlung:** Proper Error-Handling statt nur console.log.

**Aufwand P1:** 4-6 Stunden

### P2 - Nice-to-have

1. **Inline-Bearbeitung:** Soll/Ist direkt ändern können.
2. **Datums-Validierung:** Keine Duplikate, Reihenfolge prüfen.

**Aufwand P2:** 2-3 Stunden

---

## Empfehlung

### Completion: 60%

**Status:** ⚠️ **FUNKTIONAL aber STRUKTURPROBLEME**

Das HTML-Formular zeigt die Einsatztage korrekt an und ist funktional. Allerdings gibt es strukturelle Probleme:
1. **Kein Logic-File:** Code ist inline im HTML.
2. **Datum statt ID:** Verwendet Datum als Identifier.
3. **Keine REST-API-Dokumentation.**

### Kritische Gaps

1. **ID als Identifier:** `data-date` → `data-id` ändern.
2. **Logic-File erstellen:** `logic/sub_VA_Einsatztage.logic.js` auslagern.
3. **REST-API dokumentieren:** Sicherstellen dass `/api/einsatztage/:va_id` existiert.

### Aufwand Gesamt

- **P0 (Kritisch):** 2-3 Stunden
- **P1 (Wichtig):** 4-6 Stunden
- **P2 (Nice-to-have):** 2-3 Stunden

**Gesamt:** 8-12 Stunden

### Nächste Schritte

1. **Logic-File erstellen:**
   ```javascript
   // logic/sub_VA_Einsatztage.logic.js
   // Code aus HTML verschieben
   ```

2. **ID statt Datum:**
   ```html
   <div class="day-item" data-id="${day.ID}" data-date="${day.VADatum}">
   ```

3. **REST-API prüfen:**
   - Endpoint in api_server.py suchen
   - Falls nicht vorhanden: implementieren

4. **Doppelklick-Event:**
   ```javascript
   element.addEventListener('dblclick', () => openDayDetails(day.ID));
   ```

5. **Fehlerbehandlung:**
   ```javascript
   try {
       const response = await fetch(...);
       if (!response.ok) throw new Error(`HTTP ${response.status}`);
       const data = await response.json();
       renderDays(data);
   } catch (error) {
       renderError(error.message);
       notifyParent({ type: 'error', message: error.message });
   }
   ```

---

**Fazit:** Das Subformular ist funktional, aber die Code-Struktur muss verbessert werden. Mit Logic-File und ID-basierten Identifiern ist es produktionsreif. Aufwand ist moderat.
