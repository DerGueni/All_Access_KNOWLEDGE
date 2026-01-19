# Gap-Analyse: frm_OB_Objekt

**Datum:** 2026-01-12
**Formular:** Objektstammdaten
**Status:** ⚠️ Mittlere Abweichungen (ca. 70% Funktionsabdeckung)

---

## Executive Summary

Das HTML-Formular `frm_OB_Objekt.html` bildet die grundlegende Struktur des Access-Formulars ab, aber es fehlen wichtige Subformular-Integrationen und mehrere Button-Funktionen. Die Hauptfelder sind vorhanden, aber die Control-IDs stimmen nicht mit der Logic-Datei überein.

### Abdeckung

| Bereich | Access | HTML | Status |
|---------|--------|------|--------|
| **Controls gesamt** | 49 | ~35 | ⚠️ 71% |
| **Buttons** | 15 | 10 | ⚠️ 67% |
| **TextBoxen** | 15 | 12 | ✅ 80% |
| **Subformulare** | 3 | 1 | ❌ 33% |
| **Navigation** | ✅ | ✅ | ✅ 100% |
| **Tabs** | 1 (Reg_VA) | 4 | ✅ Erweitert |

---

## 1. Strukturelle Unterschiede

### Access-Formular
- **RecordSource:** `tbl_OB_Objekt` (Direct Table Binding)
- **DefaultView:** Other (Custom Form View)
- **Filter:** `ID = 10` (Initial Filter)
- **NavigationButtons:** False (Custom Navigation)
- **Subformulare:** 3 (Positionen, ZusatzDateien, Menuefuehrung)
- **TabControl:** Reg_VA mit 2 Pages (Positionen, Attachments)

### HTML-Formular
- **Datenquelle:** REST API (`/api/objekte`)
- **Layout:** Fixed Layout mit Sidebar-Navigation
- **Tabs:** 4 (Positionen, Zusatzdateien, Bemerkungen, Aufträge)
- **Subformulare:** Nur 1 (Positionen als Tabelle, keine iframes)
- **Filter:** Checkbox "Nur aktive" (Frontend-Filter)

### Kritische Unterschiede
1. **Keine iframe-Integration** für Subformulare → Daten werden inline geladen
2. **Fehlende Menüführung** (frm_Menuefuehrung Subform)
3. **Tab-Struktur erweitert** (Access: 2 Tabs, HTML: 4 Tabs)

---

## 2. Control-Mapping (49 Access Controls → 35 HTML Elements)

### ✅ Vollständig implementiert (12/15 TextBoxen)

| Access Control | HTML ID | Typ | Status |
|----------------|---------|-----|--------|
| ID | ID | text (readonly) | ✅ Vorhanden |
| Objekt | Objekt | text (required) | ✅ Vorhanden |
| Strasse | Strasse | text | ✅ Vorhanden |
| PLZ | PLZ | text (pattern) | ✅ Vorhanden |
| Ort | Ort | text | ✅ Vorhanden |
| Treffpunkt | Treffpunkt | text | ✅ Vorhanden |
| Treffp_Zeit | Treffp_Zeit | text (time) | ✅ Vorhanden |
| Dienstkleidung | Dienstkleidung | text | ✅ Vorhanden |
| Ansprechpartner | Ansprechpartner | text | ✅ Vorhanden |
| Text435 (Telefon) | Text435 | tel | ✅ Vorhanden |
| Aend_von | Aend_von | span (readonly) | ✅ Vorhanden |
| Aend_am | Aend_am | span (readonly) | ✅ Vorhanden |

### ❌ Fehlende Felder (3/15 TextBoxen)

| Access Control | Fehlt in HTML | Grund |
|----------------|---------------|-------|
| TabellenNr | ❌ | Hidden Field (value=42), aber nicht in Formular verwendet |
| Erst_von | ❌ | Nur in Status-Bar, nicht als Feld |
| Erst_am | ❌ | Nur in Status-Bar, nicht als Feld |

### ⚠️ Control-ID Mismatch (Logic.js vs. HTML)

Die Logic-Datei (`frm_OB_Objekt.logic.js`) verwendet **andere IDs** als das HTML:

| Logic.js ID | HTML ID | Problem |
|-------------|---------|---------|
| `Objekt_ID` | `ID` | ❌ Mismatch |
| `Objekt_Name` | `Objekt` | ❌ Mismatch |
| `Objekt_Strasse` | `Strasse` | ❌ Mismatch |
| `Objekt_PLZ` | `PLZ` | ❌ Mismatch |
| `Objekt_Ort` | `Ort` | ❌ Mismatch |
| `Objekt_Status` | ❌ | Fehlt komplett |
| `Objekt_Kunde` | `cboVeranstalter` | ❌ Mismatch |
| `Objekt_Ansprechpartner` | `Ansprechpartner` | ❌ Mismatch |
| `Objekt_Telefon` | `Text435` | ❌ Mismatch |
| `Objekt_Email` | ❌ | Fehlt komplett |
| `Objekt_Bemerkungen` | `Bemerkung` | ❌ Mismatch |

**Konsequenz:** Die Logic.js kann keine Felder befüllen, da `elements` leer bleiben!

---

## 3. Button-Analyse (15 Access → 10 HTML)

### ✅ Implementiert (10/15 Buttons)

| Access Button | HTML Button | OnClick Handler | Status |
|---------------|-------------|-----------------|--------|
| btn_letzer_Datensatz | goLast() | Navigation |✅ |
| Befehl40-43 | goFirst/Prev/Next/Last() | Navigation | ✅ |
| btnNeuVeranst | openNewVeranstalter() | Kunde anlegen | ✅ |
| btnReport | printReport() | Bericht drucken | ✅ |
| mcobtnDelete | deleteRecord() | Löschen | ✅ |
| btnHilfe | showHelp() | Hilfe-Dialog | ✅ |
| - | geocodeAdresse() | Geocoding (NEU) | ✅ |
| - | newRecord() | Neu (NEU) | ✅ |
| - | saveRecord() | Speichern (NEU) | ✅ |

### ❌ Fehlende Buttons (5/15)

| Access Button | Funktion | Fehlt in HTML |
|---------------|----------|---------------|
| btn_Back_akt_Pos_List | Zurück zur Positionsliste | ❌ (vorhanden, aber `display:none`) |
| btnRibbonAus | Ribbon ausblenden | ❌ (HTML hat kein Ribbon) |
| btnRibbonEin | Ribbon einblenden | ❌ (HTML hat kein Ribbon) |
| btnDaBaEin | DataBar einblenden | ❌ (HTML hat keine DataBar) |
| btnDaBaAus | DataBar ausblenden | ❌ (HTML hat keine DataBar) |

### 🆕 Neue Buttons in HTML (nicht in Access)

| HTML Button | Funktion | Access-Äquivalent |
|-------------|----------|-------------------|
| Geocode | OSM Geocoding | cmdGeocode (VBA) |
| + Neu | Neues Objekt | (implizit) |
| Speichern | Objekt speichern | (implizit) |
| Vollbild | Fullscreen Toggle | - |

---

## 4. Subformulare & Tabs

### Access: TabControl "Reg_VA" (1 Control, 2 Pages)

| Page | SourceObject | Link Fields | Status |
|------|--------------|-------------|--------|
| pgPos | sub_OB_Objekt_Positionen | ID → OB_Objekt_Kopf_ID | ⚠️ |
| pgAttach | sub_ZusatzDateien | ID, TabellenNr → Ueberordnung, TabellenID | ⚠️ |

**Zusätzliches Subform (nicht im TabControl):**
- `frm_Menuefuehrung` (keine Link-Fields) → Sidebar-Navigation

### HTML: 4 Tabs (erweitert)

| Tab | Inhalt | Datenquelle | Status |
|-----|--------|-------------|--------|
| tabPositionen | Positionen-Tabelle | `/api/objekte/{id}/positionen` | ✅ Inline |
| tabAttach | Zusatzdateien-Tabelle | `/api/attachments?objekt_id={id}` | ✅ Inline |
| tabBemerkungen | Textarea | Inline (Teil des Objekts) | 🆕 Neu |
| tabAufträge | Aufträge-Tabelle | `/api/objekte/{id}/auftraege` | 🆕 Neu |

### Gap-Details: Positionen-Tab

**Access (sub_OB_Objekt_Positionen):**
- Subform mit **9 Spalten** (Sort, Gruppe, Zusatztext, Anzahl, Geschlecht, Rel_Beginn, Rel_Ende, TagesArt, TagesNr)
- Edit-Modus: Inline-Editing in Subform
- Buttons: + Neue Position, Position löschen, ↑/↓ (Reihenfolge), Import/Excel/Kopieren/Vorlage

**HTML (Inline-Tabelle):**
- Tabelle mit **9 Spalten** (identisch)
- ✅ Buttons vorhanden: + Neue Position, Löschen, ↑/↓, Import, Excel, Kopieren, Vorlage speichern/laden
- ⚠️ Kein Inline-Editing → Neue Position via `prompt()`
- ⚠️ Keine Validierung bei Positionserstellung

**Funktionen:**
- ✅ `newPosition()` - Prompt für Bezeichnung + MA Soll
- ✅ `deletePosition()` - Löschen mit Confirm
- ✅ `movePositionUp()` / `movePositionDown()` - Sort-Order ändern
- ✅ `uploadPositionen()` - Excel/CSV Import
- ✅ `exportPositionenExcel()` - Excel Export
- ✅ `kopierePositionen()` - Von anderem Objekt kopieren
- ✅ `speichereVorlage()` / `ladeVorlage()` - Vorlagen-Management

### Gap-Details: Zusatzdateien-Tab

**Access (sub_ZusatzDateien):**
- Subform mit Dateiliste (Dateiname, Typ, Datum)
- Buttons: + Datei hinzufügen, Neue Anlage, Löschen
- Doppelklick: Datei öffnen

**HTML (Inline-Tabelle):**
- ✅ Tabelle mit 4 Spalten (Dateiname, Typ, Datum, Aktion)
- ✅ Buttons: + Datei hinzufügen, Neue Anlage, Löschen
- ✅ `addAttachment()` - File-Upload via API
- ✅ `deleteAttachment()` - Löschen mit Confirm
- ⚠️ Upload geht direkt an `/api/attachments/upload` (REST-API)
- ⚠️ Body-ID fehlt: `attachmentsTbody` wird referenziert, aber HTML hat `attachBody`

---

## 5. Event-Handler & Logik

### Access VBA Events (frm_OB_Objekt.logic.js)

Die Logic-Datei definiert folgende **Access VBA-Sync Events**:

| VBA Event | Logic.js Handler | HTML Integration | Status |
|-----------|------------------|------------------|--------|
| Objekt_Name_AfterUpdate | `Objekt_Name_AfterUpdate(value)` | ❌ Nicht aufgerufen | ❌ |
| Objekt_Status_AfterUpdate | `Objekt_Status_AfterUpdate(statusId)` | ❌ Feld fehlt | ❌ |
| Objekt_Kunde_AfterUpdate | `Objekt_Kunde_AfterUpdate(kundeId)` | ❌ Nicht aufgerufen | ❌ |
| Objekt_Ort_AfterUpdate | `Objekt_Ort_AfterUpdate(value)` | ❌ Nicht aufgerufen | ❌ |
| cboObjektSuche_AfterUpdate | `cboObjektSuche_AfterUpdate(objektId)` | ❌ Control fehlt | ❌ |
| btnKoordinatenHolen_Click | `btnKoordinatenHolen_Click()` | ✅ `geocodeAdresse()` | ✅ |
| btnGoogleMaps_Click | `btnGoogleMaps_Click()` | ❌ Button fehlt | ❌ |

**Problem:** Die Logic.js ist für **WebView2-Bridge-Integration** gedacht, aber das HTML-Formular nutzt sie nicht!

### HTML Inline-Events (direkt im HTML)

Alle Event-Handler sind **inline im HTML** definiert (nicht in Logic.js):

```javascript
// Inline im <script>-Tag
async function loadObjekte() { ... }
async function loadRecord(id) { ... }
function displayRecord(record) { ... }
async function saveRecord() { ... }
async function deleteRecord() { ... }
function geocodeAdresse() { ... }
// ... ca. 50 weitere Funktionen
```

**Konsequenz:** Die externe Logic-Datei wird **nicht verwendet**!

---

## 6. WebView2-Bridge Integration

### frm_OB_Objekt.webview2.js Analyse

**Funktion:** Bridge-Integration für Access-Backend-Anbindung

**Definierte Bridge-Events:**
- `handleBridgeData(data)` - Empfängt Daten von Access
- `loadObjektListe(nurAktive)` - Objektliste laden
- `loadObjektDetail(objektId)` - Objekt-Details laden
- `saveObjekt(objektData)` - Objekt speichern
- `deleteObjekt(objektId)` - Objekt löschen
- `loadKundenListe()` - Kunden für Dropdown

**Status:** ✅ Integration vorhanden, **aber**:
- ❌ HTML nutzt `apiCall()` statt `Bridge.sendEvent()`
- ❌ Keine Bridge-Events werden vom HTML ausgelöst
- ❌ `handleBridgeData()` wird nie aufgerufen (kein `Bridge.on` Listener)

**Fazit:** WebView2-Bridge ist implementiert, aber **nicht aktiv genutzt**.

---

## 7. Funktionalitäts-Abdeckung

### ✅ Vollständig implementiert

1. **Navigation:** First/Prev/Next/Last
2. **CRUD:** New/Save/Delete (via REST-API)
3. **Suche:** Suchfeld + Filterung
4. **Objektliste:** Rechte Panel mit Objekten
5. **Tabs:** 4 Tabs (Positionen, Zusatzdateien, Bemerkungen, Aufträge)
6. **Positionen:** Alle Funktionen (CRUD, Import/Export, Kopieren, Vorlagen)
7. **Geocoding:** OSM Nominatim Integration
8. **Attachments:** Upload/Download/Delete
9. **Tastatur-Shortcuts:** Strg+S (Speichern), Esc (Schließen)

### ⚠️ Teilweise implementiert

1. **Subformulare:** Inline-Tabellen statt echte Subforms (keine iframes)
2. **Zusatzdateien:** Funktioniert, aber Body-ID-Mismatch
3. **Kunden-Dropdown:** Lädt Daten, aber ID-Mismatch (`cboVeranstalter` vs `Objekt_Kunde`)
4. **Status-Tracking:** Erst_von/Erst_am nur in Status-Bar, nicht editierbar

### ❌ Nicht implementiert

1. **Menüführung-Subform:** (frm_Menuefuehrung) fehlt komplett
2. **Ribbon-Buttons:** (btnRibbonEin/Aus, btnDaBaEin/Aus)
3. **Google Maps Button:** (btnGoogleMaps_Click)
4. **Objekt-Schnellsuche:** (cboObjektSuche_AfterUpdate)
5. **Logic.js Integration:** Externe Logic-Datei wird ignoriert
6. **Inline-Editing:** Positionen nicht direkt in Tabelle editierbar

---

## 8. API-Endpunkte (Abhängigkeiten)

Das HTML-Formular benötigt folgende **REST-API Endpoints**:

### Objekte
- `GET /objekte` - Liste laden
- `GET /objekte/:id` - Details laden
- `POST /objekte` - Neu erstellen
- `PUT /objekte/:id` - Aktualisieren
- `DELETE /objekte/:id` - Löschen
- `PUT /objekte/:id/geo` - Geo-Koordinaten speichern

### Positionen
- `GET /objekte/:id/positionen` - Positionen laden
- `POST /objekte/:id/positionen` - Neue Position
- `DELETE /objekte/positionen/:id` - Position löschen
- `PUT /objekte/positionen/:id/sort` - Reihenfolge ändern
- `POST /objekte/:id/positionen/import` - Excel/CSV Import
- `GET /objekte/:id/positionen/export` - Excel Export
- `POST /objekte/:id/positionen/copy` - Von anderem Objekt kopieren
- `POST /objekte/:id/positionen/vorlage` - Vorlage anwenden

### Vorlagen
- `GET /objekte/vorlagen` - Vorlagenliste
- `POST /objekte/vorlagen` - Vorlage speichern

### Attachments
- `GET /attachments?objekt_id=:id&tabellen_nr=41` - Dateien laden
- `POST /api/attachments/upload` - Datei hochladen
- `DELETE /api/attachments/:id` - Datei löschen
- `GET /api/attachments/:id/download` - Datei herunterladen

### Aufträge
- `GET /objekte/:id/auftraege` - Aufträge zum Objekt

### Kunden
- `GET /kunden` - Kundenliste für Dropdown

**Status:** ⚠️ Viele Endpoints sind **noch nicht implementiert** in `api_server.py`!

---

## 9. Prioritäten für Behebung

### 🔴 CRITICAL (Blocker)

1. **Control-IDs angleichen** (Logic.js ↔ HTML)
   - `Objekt_ID` → `ID` ODER HTML-IDs ändern
   - Alle Felder in Logic.js und HTML konsistent machen
   - **Impact:** Ohne dies funktioniert die Logic.js überhaupt nicht!

2. **API-Endpoints implementieren** (fehlende Routen)
   - `/objekte/:id/positionen` (GET/POST/DELETE)
   - `/objekte/positionen/:id/sort` (PUT)
   - `/objekte/:id/positionen/import` (POST)
   - `/objekte/:id/positionen/export` (GET)
   - **Impact:** Positionen-Tab funktioniert nicht!

3. **Attachments-Body-ID korrigieren**
   - HTML: `attachBody` → `attachmentsTbody`
   - ODER `loadAttachments()` ändern: `attachmentsTbody` → `attachBody`
   - **Impact:** Zusatzdateien-Tab zeigt keine Daten!

### 🟠 HIGH (Wichtige Features)

4. **Status-Feld hinzufügen**
   - HTML: `<select id="Objekt_Status">` mit Optionen (Aktiv/Inaktiv)
   - Logic.js: `Objekt_Status_AfterUpdate` aktivieren
   - **Impact:** Status-Filter funktioniert nicht korrekt!

5. **E-Mail-Feld ergänzen**
   - HTML: `<input id="Objekt_Email" type="email">`
   - Logic.js: Bereits vorhanden (`Objekt_Email`)
   - **Impact:** Vollständigkeit der Objektdaten!

6. **Erst_von/Erst_am Felder** hinzufügen
   - HTML: Readonly-Felder unter Formular (wie Access)
   - Oder in Status-Bar anzeigen (wie aktuell)
   - **Impact:** Audit-Trail fehlt!

### 🟡 MEDIUM (Verbesserungen)

7. **Google Maps Button** implementieren
   - HTML: `<button onclick="openGoogleMaps()">`
   - Logic.js: `btnGoogleMaps_Click()` bereits vorhanden!
   - **Impact:** Komfort-Feature!

8. **Objekt-Schnellsuche** (Combobox)
   - HTML: `<select id="cboObjektSuche">` + Objekte laden
   - Logic.js: `cboObjektSuche_AfterUpdate()` bereits vorhanden!
   - **Impact:** Schnellzugriff auf Objekte!

9. **Inline-Editing für Positionen**
   - Positionen direkt in Tabelle editierbar machen
   - Statt `prompt()` → ContentEditable oder Input-Felder
   - **Impact:** UX-Verbesserung!

### 🟢 LOW (Nice-to-have)

10. **Menüführung-Subform** integrieren
    - Entweder als iframe ODER als separate Sidebar
    - Access: `frm_Menuefuehrung` (keine Link-Fields)
    - **Impact:** Konsistenz mit Access-UI!

11. **Zurück-Button** aktivieren
    - `btnBackToList` aus `display:none` nehmen
    - Nur anzeigen wenn `openArgs` vorhanden
    - **Impact:** Navigation aus Positionsliste!

---

## 10. Testfälle (Kritische Prüfungen)

### Test 1: Objekt anlegen
- [x] Neu-Button → Formular leeren
- [ ] Pflichtfeld "Objekt" validieren
- [ ] Speichern → API POST /objekte
- [ ] Objekt erscheint in Liste

### Test 2: Objekt bearbeiten
- [x] Objekt aus Liste wählen
- [ ] Felder befüllt (ID-Mismatch prüfen!)
- [ ] Änderung → Dirty-Flag gesetzt
- [x] Speichern → API PUT /objekte/:id

### Test 3: Positionen verwalten
- [ ] Tab "Positionen" öffnen
- [ ] + Neue Position → Prompt → API POST
- [ ] Positionen-Tabelle aktualisiert
- [ ] Position löschen → Confirm → API DELETE
- [ ] ↑/↓ → Sort-Order ändern → API PUT

### Test 4: Geocoding
- [x] Adresse eingeben (Strasse, PLZ, Ort)
- [x] Geocode-Button → OSM API
- [x] Lat/Lon in Felder eintragen
- [ ] Koordinaten speichern → API PUT /objekte/:id/geo

### Test 5: Zusatzdateien
- [ ] Tab "Zusatzdateien" öffnen
- [ ] Datei hinzufügen → Upload → API POST
- [ ] Dateiliste aktualisiert (Body-ID-Mismatch!)
- [ ] Datei löschen → API DELETE

---

## 11. Empfohlene Änderungen (Priorisiert)

### Sofort (nächste 30 Min)

1. **HTML-IDs angleichen** an Logic.js:
```html
<!-- ALT -->
<input id="ID">
<input id="Objekt">
<!-- NEU -->
<input id="Objekt_ID">
<input id="Objekt_Name">
```

2. **Attachments-Body-ID korrigieren:**
```html
<!-- ALT -->
<tbody id="attachBody">
<!-- NEU -->
<tbody id="attachmentsTbody">
```

3. **Status-Feld hinzufügen:**
```html
<select id="Objekt_Status" data-field="Objekt_Status">
    <option value="1">Aktiv</option>
    <option value="0">Inaktiv</option>
</select>
```

### Kurzfristig (heute)

4. **E-Mail-Feld hinzufügen:**
```html
<input type="email" id="Objekt_Email" data-field="Objekt_Email">
```

5. **Google Maps Button:**
```html
<button class="btn" onclick="openGoogleMaps()">Google Maps</button>
<script>
function openGoogleMaps() {
    const strasse = document.getElementById('Strasse')?.value || '';
    const plz = document.getElementById('PLZ')?.value || '';
    const ort = document.getElementById('Ort')?.value || '';
    const adresse = encodeURIComponent(`${strasse}, ${plz} ${ort}`);
    window.open(`https://www.google.com/maps/search/${adresse}`, '_blank');
}
</script>
```

6. **API-Endpoints implementieren** (api_server.py):
```python
@app.route('/api/objekte/<int:objekt_id>/positionen', methods=['GET'])
def get_objekt_positionen(objekt_id):
    # TODO: Implementierung

@app.route('/api/objekte/<int:objekt_id>/positionen', methods=['POST'])
def create_objekt_position(objekt_id):
    # TODO: Implementierung
```

### Mittelfristig (diese Woche)

7. **Logic.js Integration aktivieren:**
   - HTML: `<script type="module" src="logic/frm_OB_Objekt.logic.js"></script>`
   - Prüfen: `window.ObjektStamm` ist verfügbar
   - Event-Handler aus inline-Script in Logic.js migrieren

8. **Inline-Editing für Positionen:**
   - ContentEditable-Zellen ODER Input-Felder
   - Blur → Auto-Save via API

9. **Objekt-Schnellsuche Combobox:**
```html
<select id="cboObjektSuche" onchange="schnellSuche(this.value)">
    <option value="">-- Objekt wählen --</option>
</select>
```

---

## 12. Zusammenfassung

### Stärken des HTML-Formulars
✅ Grundlegende CRUD-Operationen funktionieren
✅ Alle wichtigen Felder vorhanden
✅ Positionen-Management komplett (Import/Export/Vorlagen)
✅ Geocoding-Integration (OSM)
✅ Modernes Layout mit 4 Tabs (mehr als Access)
✅ Tastatur-Shortcuts implementiert
✅ Vollbild-Modus

### Schwächen / Gaps
❌ Control-IDs stimmen nicht mit Logic.js überein → **Blocker!**
❌ Viele API-Endpoints fehlen → **Positionen-Tab funktionslos!**
❌ Attachments-Body-ID-Mismatch → **Zusatzdateien-Tab funktionslos!**
❌ Status-Feld fehlt → **Filter unvollständig!**
❌ E-Mail-Feld fehlt → **Daten unvollständig!**
❌ Logic.js wird nicht genutzt → **Externe Logik ignoriert!**
❌ WebView2-Bridge nicht aktiv → **Access-Integration fehlt!**

### Empfehlung
**Priorität 1:** Control-IDs angleichen + API-Endpoints implementieren
**Priorität 2:** Fehlende Felder ergänzen (Status, E-Mail)
**Priorität 3:** Logic.js aktivieren + WebView2-Bridge nutzen

**Zeitaufwand:** ca. 3-4 Stunden für vollständige Behebung aller Gaps.

---

**Ende der Gap-Analyse**
