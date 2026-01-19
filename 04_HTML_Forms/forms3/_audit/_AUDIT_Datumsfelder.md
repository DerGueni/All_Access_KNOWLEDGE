# AUDIT: Datumsfelder in HTML-Formularen

**Erstellt:** 2026-01-05
**Geprueft:** 4 HTML-Formulare
**Status:** ABGESCHLOSSEN

---

## 1. UEBERSICHTSTABELLE

| Formular | Datumsfeld | onchange-Handler | API-Call | Status |
|----------|------------|------------------|----------|--------|
| **frm_va_Auftragstamm.html** | | | | |
| | `Auftraege_ab` | `onchange="filterAuftraege()"` | `Bridge.loadData('auftraege_liste', null, {ab: datumAb})` | OK |
| | `btnTgBack` | `onclick="tageZurueck()"` | Ruft `loadAuftraegeListe()` auf | OK |
| | `btnTgVor` | `onclick="tageVor()"` | Ruft `loadAuftraegeListe()` auf | OK |
| | `btnHeute` | `onclick="abHeute()"` | Ruft `loadAuftraegeListe()` auf | OK |
| | `Dat_VA_Von` | `onchange="datumChanged()"` | `saveField('Dat_VA_Von', datVon)` | OK |
| | `Dat_VA_Bis` | `onchange="datVABis_AfterUpdate()"` | `saveField('Dat_VA_Bis', datBis)` + Validierung | OK |
| **frm_MA_Mitarbeiterstamm.html** | | | | |
| | `Geb_Dat` | `data-field` (generisch) | Kein Filter, nur Stammdaten | OK (N/A) |
| | `Eintrittsdatum` | `data-field` (generisch) | Kein Filter, nur Stammdaten | OK (N/A) |
| | `Austrittsdatum` | `data-field` (generisch) | Kein Filter, nur Stammdaten | OK (N/A) |
| | `Letzte_Ueberpr_OA` | `data-field` (generisch) | Kein Filter, nur Stammdaten | OK (N/A) |
| | *Kein Filter-Datum* | - | - | HINWEIS |
| **frm_N_Dienstplanuebersicht.html** | | | | |
| | `dtStartdatum` | FEHLT `onchange` | `Bridge.sendEvent('loadDienstplan', {...})` | FEHLER |
| | `btnVor` | `onclick="btnVor_Click()"` | Ruft `btnStartdatum_Click()` auf | OK |
| | `btnrueck` | `onclick="btnrueck_Click()"` | Ruft `btnStartdatum_Click()` auf | OK |
| | `btn_Heute` | `onclick="btn_Heute_Click()"` | Ruft `btnStartdatum_Click()` auf | OK |
| | `btnStartdatum` | `onclick="btnStartdatum_Click()"` | Laedt Dienstplandaten | OK |
| | `NurAktiveMA` | `onchange="NurAktiveMA_AfterUpdate()"` | Ruft `btnStartdatum_Click()` auf | OK |
| **frm_VA_Planungsuebersicht.html** | | | | |
| | `dtStartdatum` | FEHLT `onchange` | `Bridge.sendEvent('loadPlanungen', {...})` | FEHLER |
| | `btnVor` | `onclick="btnVor_Click()"` | Ruft `btnStartdatum_Click()` auf | OK |
| | `btnrueck` | `onclick="btnrueck_Click()"` | Ruft `btnStartdatum_Click()` auf | OK |
| | `btn_Heute` | `onclick="btn_Heute_Click()"` | Ruft `btnStartdatum_Click()` auf | OK |
| | `btnStartdatum` | `onclick="btnStartdatum_Click()"` | Laedt Planungsdaten | OK |
| | `NurIstNichtZugeordnet` | `onchange="NurIstNichtZugeordnet_AfterUpdate()"` | Ruft `renderTable()` auf | OK |

---

## 2. DETAILANALYSE PRO FORMULAR

### 2.1 frm_va_Auftragstamm.html

**Datumsfelder fuer Filterung:**

1. **`Auftraege_ab`** (Zeile 1212)
   - HTML: `<input type="date" class="date-input" id="Auftraege_ab" onchange="filterAuftraege()">`
   - Handler: `filterAuftraege()` -> ruft `loadAuftraegeListe()` auf
   - API-Call: `Bridge.loadData('auftraege_liste', null, {ab: datumAb, limit: 100})`
   - **Status: KORREKT IMPLEMENTIERT**

2. **Navigation Buttons:**
   - `btnTgBack`: `onclick="tageZurueck()"` - Datum -7 Tage, dann `loadAuftraegeListe()`
   - `btnTgVor`: `onclick="tageVor()"` - Datum +7 Tage, dann `loadAuftraegeListe()`
   - `btnHeute`: `onclick="abHeute()"` - Setzt auf heute, dann `loadAuftraegeListe()`
   - **Status: KORREKT IMPLEMENTIERT**

**Datumsfelder fuer Auftragsdaten:**

3. **`Dat_VA_Von`** (Zeile 932)
   - HTML: `<input type="date" ... id="Dat_VA_Von" onchange="datumChanged()">`
   - Handler: `datumChanged()` -> `saveField('Dat_VA_Von', datVon)`
   - **Status: KORREKT IMPLEMENTIERT**

4. **`Dat_VA_Bis`** (Zeile 934)
   - HTML: `<input type="date" ... id="Dat_VA_Bis" onchange="datVABis_AfterUpdate()">`
   - Handler: `datVABis_AfterUpdate()` - Prueft Bis >= Von, dann speichert
   - **Status: KORREKT IMPLEMENTIERT mit Validierung**

---

### 2.2 frm_MA_Mitarbeiterstamm.html

**Datumsfelder (nur Stammdaten, keine Filter):**

1. **`Geb_Dat`** (Zeile 869)
   - HTML: `<input type="date" ... id="Geb_Dat" data-field="Geb_Dat">`
   - Kein onchange, verwendet generisches `data-field` System
   - **Status: OK (Stammdatenfeld, kein Filter)**

2. **`Eintrittsdatum`** (Zeile 885)
   - HTML: `<input type="date" ... id="Eintrittsdatum" data-field="Eintrittsdatum">`
   - **Status: OK (Stammdatenfeld)**

3. **`Austrittsdatum`** (Zeile 889)
   - HTML: `<input type="date" ... id="Austrittsdatum" data-field="Austrittsdatum">`
   - **Status: OK (Stammdatenfeld)**

4. **`Letzte_Ueberpr_OA`** (Zeile 930)
   - HTML: `<input type="date" ... id="Letzte_Ueberpr_OA" data-field="Letzte_Ueberpr_OA">`
   - **Status: OK (Stammdatenfeld)**

**HINWEIS:** Dieses Formular hat KEINE Datumsfilter fuer die Mitarbeiterliste. Die Liste wird nur nach aktiv/inaktiv gefiltert (`filterSelect`).

---

### 2.3 frm_N_Dienstplanuebersicht.html

**Datumsfelder:**

1. **`dtStartdatum`** (Zeile 699)
   - HTML: `<input type="date" id="dtStartdatum" ondblclick="dtStartdatum_DblClick()">`
   - **FEHLER: Kein `onchange` Handler!**
   - Daten werden NUR beim Klick auf "Aktualisieren" geladen
   - API-Call erfolgt in `btnStartdatum_Click()`: `Bridge.sendEvent('loadDienstplan', {...})`

2. **Navigation Buttons:**
   - `btnVor`: `onclick="btnVor_Click()"` -> +2 Tage, dann `btnStartdatum_Click()` -> OK
   - `btnrueck`: `onclick="btnrueck_Click()"` -> -2 Tage, dann `btnStartdatum_Click()` -> OK
   - `btn_Heute`: `onclick="btn_Heute_Click()"` -> Heute, dann `btnStartdatum_Click()` -> OK
   - `btnStartdatum`: `onclick="btnStartdatum_Click()"` -> Laedt Daten -> OK

3. **Filter:**
   - `NurAktiveMA`: `onchange="NurAktiveMA_AfterUpdate()"` -> ruft `btnStartdatum_Click()` -> OK

---

### 2.4 frm_VA_Planungsuebersicht.html

**Datumsfelder:**

1. **`dtStartdatum`** (Zeile 392)
   - HTML: `<input type="date" id="dtStartdatum" ondblclick="dtStartdatum_DblClick()">`
   - **FEHLER: Kein `onchange` Handler!**
   - Daten werden NUR beim Klick auf "Aktualisieren" geladen
   - API-Call erfolgt in `btnStartdatum_Click()`: `Bridge.sendEvent('loadPlanungen', {...})`

2. **Navigation Buttons:**
   - `btnVor`: `onclick="btnVor_Click()"` -> +3 Tage, dann `btnStartdatum_Click()` -> OK
   - `btnrueck`: `onclick="btnrueck_Click()"` -> -3 Tage, dann `btnStartdatum_Click()` -> OK
   - `btn_Heute`: `onclick="btn_Heute_Click()"` -> Heute, dann `btnStartdatum_Click()` -> OK
   - `btnStartdatum`: `onclick="btnStartdatum_Click()"` -> Laedt Daten -> OK

3. **Filter:**
   - `NurIstNichtZugeordnet`: `onchange="NurIstNichtZugeordnet_AfterUpdate()"` -> `renderTable()` (nur clientseitig!)
   - `IstAuftrAusblend`: `onchange="IstAuftrAusblend_AfterUpdate()"` -> `renderTable()` (nur clientseitig!)

---

## 3. FEHLERHAFTE IMPLEMENTIERUNGEN

### 3.1 frm_N_Dienstplanuebersicht.html - `dtStartdatum`

**Problem:**
- Das Datumsfeld hat KEINEN `onchange`-Handler
- Benutzer muss nach Datumsaenderung den "Aktualisieren"-Button klicken
- Inkonsistent mit frm_va_Auftragstamm.html (dort funktioniert es automatisch)

**Aktueller Code (Zeile 699):**
```html
<input type="date" id="dtStartdatum" ondblclick="dtStartdatum_DblClick()">
```

**Korrektur:**
```html
<input type="date" id="dtStartdatum" onchange="btnStartdatum_Click()" ondblclick="dtStartdatum_DblClick()">
```

---

### 3.2 frm_VA_Planungsuebersicht.html - `dtStartdatum`

**Problem:**
- Identisches Problem wie oben
- Kein `onchange`-Handler auf dem Datumsfeld

**Aktueller Code (Zeile 392):**
```html
<input type="date" id="dtStartdatum" ondblclick="dtStartdatum_DblClick()">
```

**Korrektur:**
```html
<input type="date" id="dtStartdatum" onchange="btnStartdatum_Click()" ondblclick="dtStartdatum_DblClick()">
```

---

## 4. ZUSAMMENFASSUNG

| Status | Anzahl | Details |
|--------|--------|---------|
| OK | 16 | Korrekt implementierte Datumsfelder/Buttons |
| FEHLER | 2 | `dtStartdatum` ohne onchange in Dienstplan + Planung |
| N/A | 4 | Stammdatenfelder ohne Filter-Funktion |

### Priorisierung der Korrekturen:

1. **HOCH** - `frm_N_Dienstplanuebersicht.html`: `dtStartdatum` onchange hinzufuegen
2. **HOCH** - `frm_VA_Planungsuebersicht.html`: `dtStartdatum` onchange hinzufuegen

---

## 5. EMPFOHLENE KORREKTUREN

### Korrektur 1: frm_N_Dienstplanuebersicht.html

**Datei:** `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/frm_N_Dienstplanuebersicht.html`

**Zeile 699 aendern von:**
```html
<input type="date" id="dtStartdatum" ondblclick="dtStartdatum_DblClick()">
```

**zu:**
```html
<input type="date" id="dtStartdatum" onchange="btnStartdatum_Click()" ondblclick="dtStartdatum_DblClick()">
```

---

### Korrektur 2: frm_VA_Planungsuebersicht.html

**Datei:** `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/frm_VA_Planungsuebersicht.html`

**Zeile 392 aendern von:**
```html
<input type="date" id="dtStartdatum" ondblclick="dtStartdatum_DblClick()">
```

**zu:**
```html
<input type="date" id="dtStartdatum" onchange="btnStartdatum_Click()" ondblclick="dtStartdatum_DblClick()">
```

---

## 6. ZUSAETZLICHE EMPFEHLUNGEN

### 6.1 Konsistenz bei Filter-Checkboxen (Planungsuebersicht)

Die Checkboxen `NurIstNichtZugeordnet` und `IstAuftrAusblend` filtern nur clientseitig via `renderTable()`.

**Empfehlung:** Bei groesseren Datenmengen sollte der Filter serverseitig erfolgen:
```javascript
function NurIstNichtZugeordnet_AfterUpdate() {
    state.nurIstNichtZugeordnet = document.getElementById('NurIstNichtZugeordnet').checked;
    loadPlanungData();  // <-- Statt renderTable() -> Server-Filter
}
```

### 6.2 Mitarbeiterstamm - Datumsfilter hinzufuegen (optional)

Falls gewuenscht koennte ein Filter "Einsaetze ab Datum" hinzugefuegt werden, um nur Mitarbeiter mit Einsaetzen ab einem bestimmten Datum anzuzeigen.

---

**Ende des Audit-Berichts**
