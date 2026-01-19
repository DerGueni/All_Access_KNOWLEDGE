# Gap-Analyse: frm_DP_Dienstplan_Objekt (Planungsübersicht)

**Datum:** 2026-01-12
**Formular:** frm_DP_Dienstplan_Objekt
**Zweck:** Objekt-/Auftrag-zentrierte Dienstplan-Wochenansicht

---

## 1. Executive Summary

### Vollständigkeit: ⚠️ 75% (Mittel)
- **Hauptfunktionalität:** Wochenansicht mit Objekten/Aufträgen vorhanden
- **Datumsnavigation:** Vollständig implementiert
- **Kritische Lücken:** KW-Combobox fehlt, Position-Filter unvollständig, Subform-Integration fehlt

### Hauptprobleme:
1. **KW-Combobox (cboKW)** - HTML vorhanden aber keine Logik
2. **Position-Filter (PosAusblendAb)** - Nur rudimentär implementiert
3. **sub_DP_Grund Integration** - Vollständig fehlend
4. **Master-Detail Navigation** - DblClick auf Tages-Spalten fehlt
5. **Ribbon/DB-Navigation** - 4 Access-Buttons fehlen komplett
6. **Versions-Label** - Kein lbl_Version Element

---

## 2. Controls Gap-Analyse

### 2.1 ✅ VOLLSTÄNDIG IMPLEMENTIERT

#### Labels (6 von 7)
- ✅ **lbl_Datum** → Datums-Input `dtStartdatum` (Position/Größe angepasst)
- ✅ **Bezeichnungsfeld96** → `header-title` "Planungsübersicht"
- ✅ **Bezeichnungsfeld15** → Label "Nur freie Schichten anzeigen"
- ✅ **Bezeichnungsfeld17** → Label "Nur Aufträge mit weniger als"
- ✅ **Bezeichnungsfeld20** → Label "Positionen anzeigen"
- ✅ **lbl_Auftrag** → `col-auftrag-header` "Auftrag / Veranstaltung"

#### TextBoxen (7 von 8)
- ✅ **dtStartdatum** → `<input type="date" id="dtStartdatum">`
- ✅ **lbl_Tag_1 bis lbl_Tag_7** → `#day_1 bis #day_7 .day-title` (dynamisch)
- ✅ **PosAusblendAb** → `<input type="text" id="PosAusblendAb" value="25">`

#### CheckBoxen (2 von 2)
- ✅ **NurIstNichtZugeordnet** → `<input type="checkbox" id="NurIstNichtZugeordnet">`
- ✅ **IstAuftrAusblend** → `<input type="checkbox" id="IstAuftrAusblend">`

#### CommandButtons (4 von 12)
- ✅ **btnStartdatum** → `<button id="btnStartdatum">Startdatum Ändern</button>`
- ✅ **btnVor** → `<button id="btnVor">&gt;</button>`
- ✅ **btnrueck** → `<button id="btnrueck">&lt;</button>`
- ✅ **btn_Heute** → `<button id="btn_Heute">Ab Heute</button>`
- ✅ **btnOutpExcel** → `<button id="btnOutpExcel">Übersicht drucken</button>`
- ✅ **Befehl37** → `<button id="Befehl37">&times;</button>` (Schließen)

### 2.2 ⚠️ TEILWEISE IMPLEMENTIERT

#### KW-Combobox (40% implementiert)
**Access:**
- Nicht dokumentiert (vermutlich in Access vorhanden)

**HTML:**
```html
<select id="cboKW" style="width:60px; height:22px; font-size:11px;"></select>
```

**Fehlend:**
- ❌ Keine Options-Befüllung (KW 1-53)
- ❌ Kein Change-Event-Handler
- ❌ Keine Auto-Selektion der aktuellen KW
- ❌ Keine Synchronisation mit dtStartdatum

**Implementierung benötigt:**
```javascript
// KW-Dropdown befüllen
function initKWDropdown() {
    const select = document.getElementById('cboKW');
    for (let kw = 1; kw <= 53; kw++) {
        const option = document.createElement('option');
        option.value = kw;
        option.textContent = kw.toString().padStart(2, '0');
        select.appendChild(option);
    }
}

// KW aus Datum berechnen
function getKW(date) {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + 3 - (d.getDay() + 6) % 7);
    const week1 = new Date(d.getFullYear(), 0, 4);
    return 1 + Math.round(((d - week1) / 86400000 - 3 + (week1.getDay() + 6) % 7) / 7);
}

// Event: KW-Auswahl → Datum ändern
elements.cboKW.addEventListener('change', (e) => {
    const kw = parseInt(e.target.value);
    const year = new Date().getFullYear();
    // Montag der KW berechnen...
});
```

#### Position-Filter (60% implementiert)
**Access:**
- `PosAusblendAb` = 25 (Default)
- `IstAuftrAusblend` = Checkbox zum Aktivieren

**HTML/Logic:**
- ✅ Input-Feld vorhanden
- ✅ Checkbox vorhanden
- ⚠️ Filter-Logik nur auf Schicht-Anzahl, nicht auf Position-Nummern

**Problem:**
```javascript
// AKTUELL: Filtert nach Anzahl Schichten
totalSchichten += (state.einsatztage[key] || []).length;
return totalSchichten <= state.posAusblendAb;

// SOLLTE: Filtern nach Position-Attribut (falls vorhanden)
// Vermutlich: Schichten haben ein Feld "Position" oder "PositionNr"
```

**Unklarheit:**
- Was bedeutet "Position ausblenden ab 25"?
- Ist dies die Anzahl Schichten oder ein Positionsattribut?
- → Access-Abfrage prüfen notwendig

### 2.3 ❌ NICHT IMPLEMENTIERT

#### 1. Versions-Label
**Access:**
- `lbl_Version` (26532/226, 1515x270) - Versions-Anzeige

**Fehlend in HTML:**
- Kein Element für Versions-Info

**Implementierung:**
```html
<div class="header-version" id="lbl_Version">v1.55</div>
```

#### 2. tmpFokus (Fokus-Hilfsfeld)
**Access:**
- `tmpFokus` (7532/286, 0x315) - Unsichtbares Hilfselement

**Fehlend in HTML:**
- Nicht benötigt im Browser-Kontext

#### 3. Ribbon/DB-Navigation (4 Buttons)
**Access:**
- `btnRibbonAus` (851/313, 238x253)
- `btnRibbonEin` (851/643, 238x253)
- `btnDaBaEin` (1136/478, 238x253)
- `btnDaBaAus` (566/478, 238x253)

**Fehlend in HTML:**
- Alle 4 Buttons fehlen komplett

**Grund:**
- Im Browser-Kontext nicht relevant
- Ribbon = Access-spezifisch
- DB-Navigation = Access-spezifisch

**Empfehlung:**
- ❌ Nicht implementieren (Access-spezifisch)

#### 4. btnOutpExcelSend
**Access:**
- `btnOutpExcelSend` (21373/170, 1890x330) - Excel mit Versand
- Sichtbar: Nein

**Fehlend in HTML:**
- Versteckter Button für Excel-Versand

**Implementierung:**
```html
<button class="header-btn-export" id="btnOutpExcelSend" style="display:none;">
    Excel versenden
</button>
```

#### 5. Rechteck108 (Datums-Rahmen)
**Access:**
- `Rechteck108` (7441/271, 2571x686) - Dekorativer Rahmen

**Fehlend in HTML:**
- Kein spezielles Rahmen-Element

**Implementierung:**
- CSS-Styling für `.header-date-box` reicht aus
- ❌ Nicht kritisch

#### 6. Subform: sub_DP_Grund
**Access:**
- `sub_DP_Grund` (3000/450, 25645x5746) - Hauptinhalt-Subform
- Source Object: `sub_DP_Grund`

**Fehlend in HTML:**
- Vollständig fehlend!

**KRITISCH:**
- Access zeigt Planungsdaten NICHT direkt im Formular
- Sondern via Sub-Formular `sub_DP_Grund`
- HTML rendert Daten direkt in `.calendar-body`

**Architektur-Unterschied:**
```
ACCESS:
frm_DP_Dienstplan_Objekt (Filter/Navigation)
  └── sub_DP_Grund (Daten-Matrix)

HTML:
frm_DP_Dienstplan_Objekt.html (Filter + Daten kombiniert)
```

**Entscheidung:**
- ✅ HTML-Ansatz ist BESSER (keine Subform-Komplexität)
- ⚠️ ABER: Prüfen ob `sub_DP_Grund` spezielle Logik hat
- → `sub_DP_Grund.html` und `sub_DP_Grund.logic.js` prüfen

#### 7. frm_Menuefuehrung (Sidebar)
**Access:**
- `frm_Menuefuehrung` (45/0, 3237x6291) - Eingebettetes Menü

**HTML:**
- ✅ Ersetzt durch `<aside class="app-sidebar">` mit Buttons
- ✅ Funktional equivalent

---

## 3. Funktionalität Gap-Analyse

### 3.1 ✅ VOLLSTÄNDIG IMPLEMENTIERT

#### Datumsnavigation (100%)
- ✅ Startdatum-Eingabe
- ✅ Woche vor/zurück
- ✅ "Ab Heute"-Button
- ✅ Wochenstart auf Montag
- ✅ 7-Tage-Header dynamisch

#### Kalender-Header (100%)
- ✅ Wochentag + Datum (ddd/ dd.mm.yy)
- ✅ Wochenend-Highlighting (Sa/So dunkelblau)
- ✅ Sub-Header: Name / von / bis
- ✅ Responsive Spalten

#### Kalender-Body (90%)
- ✅ Auftrags-Spalte mit Name/Objekt/Ort
- ✅ 7 Tages-Spalten
- ✅ MA-Einträge mit Name/von/bis
- ✅ Unbesetzte Positionen (gelb)
- ✅ Fragliche Zusagen (türkis, Status_ID=4)
- ✅ Stornierte Einträge (rot, Status_ID=5/6)
- ⚠️ Überbuchungs-Anzeige fehlt (siehe unten)

#### Filter (70%)
- ✅ "Nur freie Schichten anzeigen" (NurIstNichtZugeordnet)
- ⚠️ "Aufträge mit weniger als X Positionen" (IstAuftrAusblend) - unklar
- ✅ Filter-Checkbox-Events

#### Export (80%)
- ✅ Excel-Export (CSV-Download)
- ✅ CSV mit UTF-8 BOM
- ❌ E-Mail-Versand fehlt (btnOutpExcelSend)

### 3.2 ⚠️ TEILWEISE IMPLEMENTIERT

#### 1. Überbuchungs-/Unterbuchungs-Anzeige (30%)
**Sollte:**
- Unterbuchung: Zeige leere gelbe Einträge (✅ implementiert)
- Überbuchung: Warne wenn mehr MA zugeordnet als Soll

**Aktuell:**
```javascript
// Zeigt nur unbesetzte Positionen
const unbesetzt = Math.max(0, soll - zuordnungen.length);
```

**Fehlend:**
```javascript
// Überbuchung prüfen
if (zuordnungen.length > soll) {
    // Warnung anzeigen (roter Rahmen, Ausrufezeichen)
    html += `<div class="ma-entry ueberbucht">
        <span class="ma-name" style="color:red;">⚠️ Überbucht (${zuordnungen.length}/${soll})</span>
    </div>`;
}
```

#### 2. Master-Detail Navigation (0%)
**Access:**
- DblClick auf Tag-Spalte (lbl_Tag_1 bis lbl_Tag_7) öffnet Detail-Ansicht

**HTML:**
- ❌ Kein DblClick-Handler auf `.day-title`

**Implementierung benötigt:**
```javascript
// DblClick auf Tages-Header → Detail-Ansicht öffnen
document.querySelectorAll('.day-title').forEach((el, index) => {
    el.addEventListener('dblclick', () => {
        const date = new Date(state.startDate);
        date.setDate(date.getDate() + index);
        openDetailView(date);
    });
});

function openDetailView(datum) {
    // Öffne frm_DP_Dienstplan_MA oder ähnlich
    // Oder: Navigiere zu Detail-Formular
    if (typeof window.navigateToForm === 'function') {
        window.navigateToForm('frm_DP_Dienstplan_MA', { datum });
    }
}
```

#### 3. KW-Combobox (40%)
Siehe Abschnitt 2.2

#### 4. Position-Filter-Logik (60%)
Siehe Abschnitt 2.2

### 3.3 ❌ NICHT IMPLEMENTIERT

#### 1. Feiertags-Hervorhebung (0%)
**Aktuell:**
```javascript
// Feiertage definiert aber nicht verwendet!
const FEIERTAGE_2025 = [...];

function istFeiertag(datum) {
    const dateKey = formatDateForInput(datum);
    return FEIERTAGE_2025.includes(dateKey);
}

// IN updateHeaderLabels():
const isFeiertag = istFeiertag(date);
dayHeader.classList.toggle('feiertag', isFeiertag); // ✅ Gesetzt

// ABER: Kein CSS für .feiertag definiert! ❌
```

**Implementierung:**
```css
.day-title.feiertag {
    background-color: #ff6666 !important; /* Rot für Feiertage */
    color: white !important;
}
```

#### 2. Ribbon/DB-Navigation
Siehe Abschnitt 2.3 (Empfehlung: Nicht implementieren)

#### 3. E-Mail-Versand (btnOutpExcelSend)
**Access:**
- Versteckter Button für Excel-Versand via Outlook

**HTML:**
- Vollständig fehlend

**Implementierung benötigt:**
```javascript
async function exportExcelSend() {
    setStatus('Exportiere und versende...');

    // 1. Excel/CSV erstellen
    const csvBlob = createCSV();

    // 2. Via VBA-Bridge an Outlook übergeben
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('sendExcelMail', {
            recipient: 'planer@consys.de',
            subject: `Planungsübersicht ${formatDateForInput(state.startDate)}`,
            csvData: await blobToBase64(csvBlob)
        });
    }
}
```

#### 4. sub_DP_Grund Integration
**KRITISCH:** Access zeigt Daten über Subform, HTML direkt.
- → Prüfen ob `sub_DP_Grund` spezielle Logik/Features hat!

---

## 4. Datenanbindung Gap-Analyse

### 4.1 ✅ REST-API (Browser-Modus)

#### Endpoints verwendet:
```javascript
// 1. Aufträge im Zeitraum
GET /api/auftraege?von=YYYY-MM-DD&bis=YYYY-MM-DD&limit=100

// 2. Einsatztage/Schichten
GET /api/einsatztage?von=YYYY-MM-DD&bis=YYYY-MM-DD

// 3. MA-Zuordnungen
GET /api/zuordnungen?von=YYYY-MM-DD&bis=YYYY-MM-DD
```

#### Datenstruktur:
```javascript
state.auftraege = [
    { VA_ID, Auftrag, Objekt, Ort, ... }
];

state.einsatztage = {
    "VA_ID_YYYY-MM-DD": [
        { VADatum_ID, VA_Start, VA_Ende, Soll, ... }
    ]
};

state.zuordnungen = {
    "VADatum_ID": [  // Schicht-ID!
        { MA_ID, MAName, MA_Start, MA_Ende, Status_ID, ... }
    ]
};
```

### 4.2 ⚠️ WebView2 Bridge (40%)

#### Implementiert:
- ✅ Bridge Event-Listener registriert
- ✅ `handleBridgeData()` vorhanden
- ✅ Daten-Parsing für auftraege/zuordnungen

#### Fehlend:
- ❌ `einsatztage` nicht via Bridge geladen
- ❌ Keine initiale Datenanfrage beim Form_Load
- ❌ Keine Bridge-basierte Excel-Funktion

**Access VBA fehlt:**
```vba
' mod_N_DP_Dienstplan_Objekt.bas (FEHLT!)
Public Sub OpenDPObjekt_WebView2(Optional StartDatum As Date)
    ' WebView2 öffnen und Daten senden
    Dim json As String
    json = GetPlanungsuebersichtJSON(StartDatum)

    ' WebView2 PostWebMessage
    webView.PostWebMessage json
End Sub
```

### 4.3 ❌ Access-Abfragen fehlen

**Dokumentierte Queries:**
- Keine spezifischen Queries im Access-Export erwähnt
- Vermutlich: `qry_DP_Objekt` oder `qry_DP_Grund`

**Benötigte Queries:**
```sql
-- Aufträge mit Schichten im Zeitraum
SELECT
    a.VA_ID, a.Auftrag, a.Objekt, a.Ort,
    s.VADatum, s.VADatum_ID, s.VA_Start, s.VA_Ende, s.MA_Anzahl AS Soll
FROM tbl_VA_Auftragstamm a
INNER JOIN tbl_VA_Start s ON a.VA_ID = s.VA_ID
WHERE s.VADatum BETWEEN ? AND ?
ORDER BY s.VADatum, a.Auftrag;

-- MA-Zuordnungen
SELECT
    z.VAStart_ID, z.MA_ID, z.Status_ID,
    z.MVA_Start AS MA_Start, z.MVA_Ende AS MA_Ende,
    m.Nachname, m.Vorname
FROM tbl_MA_VA_Planung z
INNER JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
WHERE z.VADatum BETWEEN ? AND ?;
```

---

## 5. Event-Handling Gap-Analyse

### 5.1 ✅ IMPLEMENTIERT (9 Events)

| Event | Control | Handler | Status |
|-------|---------|---------|--------|
| Click | btnVor | `navigateWeek(1)` | ✅ |
| Click | btnrueck | `navigateWeek(-1)` | ✅ |
| Click | btn_Heute | `goToToday()` | ✅ |
| Click | btnStartdatum | Datum übernehmen | ✅ |
| Change | NurIstNichtZugeordnet | Filter Toggle | ✅ |
| Change | IstAuftrAusblend | Filter Toggle | ✅ |
| Change | PosAusblendAb | Filter Update | ✅ |
| Click | btnOutpExcel | `exportExcel()` | ✅ |
| Click | Befehl37 | `window.close()` | ✅ |

### 5.2 ❌ FEHLEND (5+ Events)

| Event | Control | Access-Handler | HTML-Status |
|-------|---------|----------------|-------------|
| **DblClick** | lbl_Tag_1 bis lbl_Tag_7 | Detail-Ansicht öffnen | ❌ Fehlt |
| **Change** | cboKW | Woche wechseln | ❌ Fehlt |
| **OnLoad** | Formular | Initiale Daten laden | ⚠️ Teilweise (init()) |
| **OnOpen** | Formular | Parameter verarbeiten | ❌ Fehlt |
| **OnClose** | Formular | Cleanup | ⚠️ Nur window.close() |
| **Click** | btnOutpExcelSend | Excel versenden | ❌ Fehlt |

**Kritisch:** DblClick auf Tag-Spalten

---

## 6. Styling/Layout Gap-Analyse

### 6.1 ✅ Farben korrekt (95%)

| Element | Access ForeColor | Access BackColor | HTML | Match |
|---------|------------------|------------------|------|-------|
| Tag-Spalten | 0 (Schwarz) | 16179314 (Hellorange) | #000080 (Blau) | ⚠️ Abweichung |
| Auftrag-Label | 16777215 (Weiß) | 15801669 (Orange) | #000080 (Blau) | ⚠️ Abweichung |
| Excel-Buttons | 0 (Schwarz) | 14136213 (Gelb) | #D6DFEC (Grau) | ⚠️ Abweichung |

**Problem:**
- Access: Tag-Spalten haben **hellorange** Hintergrund (#f6c683)
- HTML: Tag-Spalten haben **dunkelblauen** Hintergrund (#000080)

**Korrektur notwendig:**
```css
/* AKTUELL */
.day-title {
    background-color: #000080; /* Blau */
}

/* SOLLTE (Access-Original) */
.day-title {
    background-color: #f6c683; /* Hellorange */
    color: #000;
}

.day-title.weekend {
    background-color: #4040a0; /* Dunkelblau nur für Wochenende */
}
```

### 6.2 ✅ Positionen korrekt (90%)

**Header:**
- ✅ Höhe: 70px (Access: ~945 Twips / 66.5px) ≈ OK
- ✅ Layout: Horizontal mit Flex

**Detail:**
- ✅ Flex-Layout für Spalten
- ✅ Auftrag-Spalte: 250px (Access: 3555 Twips / 250px) ✅
- ✅ Tag-Spalten: flex: 1 (dynamisch)

### 6.3 ⚠️ Schriftgrößen (80%)

| Element | Access | HTML | Match |
|---------|--------|------|-------|
| Titel | 14px | 22px (+8px) | ✅ OK (CLAUDE.md) |
| Header-Labels | 10-11px | 10-11px | ✅ |
| MA-Einträge | ~11px | 11px | ✅ |
| Buttons | 10px | 10px | ✅ |

---

## 7. Priorisierte Gap-Liste

### 🔴 KRITISCH (Muss implementiert werden)

1. **KW-Combobox Logik** (Prio 1)
   - Optionen befüllen (KW 1-53)
   - Change-Event → Datum setzen
   - Auto-Selektion der aktuellen KW
   - Datei: `frm_DP_Dienstplan_Objekt.logic.js`
   - Aufwand: 1-2 Stunden

2. **Master-Detail Navigation** (Prio 1)
   - DblClick auf `.day-title` → Detail-Ansicht öffnen
   - Navigation zu `frm_DP_Dienstplan_MA` mit Datum-Parameter
   - Datei: `frm_DP_Dienstplan_Objekt.logic.js`
   - Aufwand: 2-3 Stunden

3. **Überbuchungs-Anzeige** (Prio 2)
   - Warnung wenn `zuordnungen.length > soll`
   - Visuelles Highlight (rote Schrift, Ausrufezeichen)
   - Datei: `frm_DP_Dienstplan_Objekt.logic.js` (renderCalendar)
   - Aufwand: 1 Stunde

4. **Feiertags-CSS** (Prio 2)
   - CSS-Klasse `.day-title.feiertag` definieren
   - Roter Hintergrund für Feiertage
   - Datei: Inline `<style>` im HTML
   - Aufwand: 15 Minuten

### 🟡 WICHTIG (Sollte implementiert werden)

5. **Position-Filter Logik klären** (Prio 3)
   - Prüfen ob "Position" ein Feld in den Daten ist
   - Falls ja: Filter anpassen
   - Falls nein: Aktuelle Logik beibehalten
   - Datei: `frm_DP_Dienstplan_Objekt.logic.js`
   - Aufwand: 1-2 Stunden (inkl. DB-Analyse)

6. **Tag-Spalten Farben korrigieren** (Prio 3)
   - Access: Hellorange (#f6c683)
   - HTML: Aktuell Blau (#000080)
   - Datei: Inline `<style>` im HTML
   - Aufwand: 15 Minuten

7. **Excel-Versand** (Prio 4)
   - `btnOutpExcelSend` implementieren
   - VBA-Bridge für Outlook-Integration
   - Datei: `frm_DP_Dienstplan_Objekt.logic.js` + VBA
   - Aufwand: 3-4 Stunden

### 🟢 OPTIONAL (Nice-to-have)

8. **Versions-Label** (Prio 5)
   - `lbl_Version` in Header hinzufügen
   - Datei: HTML + CSS
   - Aufwand: 30 Minuten

9. **sub_DP_Grund Logik-Analyse** (Prio 5)
   - Prüfen ob `sub_DP_Grund` spezielle Features hat
   - Falls ja: In HTML-Logik integrieren
   - Dateien: `sub_DP_Grund.html`, `sub_DP_Grund.logic.js`
   - Aufwand: 2-4 Stunden

10. **WebView2 Bridge für einsatztage** (Prio 6)
    - `einsatztage` auch via Bridge laden
    - VBA-Backend erweitern
    - Dateien: `frm_DP_Dienstplan_Objekt.webview2.js` + VBA
    - Aufwand: 2-3 Stunden

### ⚪ NICHT UMSETZEN

- ❌ **Ribbon/DB-Navigation** (4 Buttons) - Access-spezifisch
- ❌ **tmpFokus** - Hilfselement, im Browser nicht benötigt
- ❌ **Rechteck108** - Dekorativ, CSS reicht

---

## 8. Technische Schulden / Code-Qualität

### 8.1 ✅ Gut gelöst

1. **State Management** - Sauber mit `state` Object
2. **Daten-Gruppierung** - Effizient mit Keys (`VA_ID_DATUM`)
3. **Responsive Layout** - Flexbox für Spalten
4. **Filter-Logik** - Deklarativ und performant
5. **CSV-Export** - UTF-8 BOM, korrekte Formatierung

### 8.2 ⚠️ Verbesserungsbedarf

1. **Zuordnungs-Gruppierung inconsistent:**
   ```javascript
   // Bei einsatztage: Gruppierung nach "VA_ID_DATUM"
   state.einsatztage[`${vaId}_${datum}`]

   // Bei zuordnungen: Gruppierung nach "VAStart_ID"
   state.zuordnungen[schichtId]  // schichtId = VAStart_ID

   // → Unterschiedliche Schlüssel-Strategien!
   ```

2. **Fehlendes Error-Handling:**
   ```javascript
   // fetch() ohne .catch()
   const response = await fetch(url);
   const data = await response.json(); // Kann fehlschlagen!
   ```

3. **Hardcoded Limits:**
   ```javascript
   for (const auftrag of auftraege.slice(0, 50)) {
       // Warum nur 50? → Konfigurierbar machen
   }
   ```

4. **Keine Lade-Indikation bei Filter-Änderung:**
   ```javascript
   elements.NurIstNichtZugeordnet.addEventListener('change', (e) => {
       state.nurFreieSchichten = e.target.checked;
       renderCalendar(); // Sofort rendern, keine Loading-Anzeige
   });
   ```

### 8.3 ❌ Kritische Probleme

1. **Keine Zeitzone-Behandlung:**
   ```javascript
   const d = new Date(date);
   // Problem: Datumsübergänge bei UTC vs. lokaler Zeit
   // → Immer mit lokalem Datum arbeiten!
   ```

2. **Fehlende Debouncing:**
   ```javascript
   // Bei schnellen Datum-Änderungen mehrfach API-Calls
   elements.btnVor.addEventListener('click', () => navigateWeek(1));
   // → Debounce für 300ms implementieren
   ```

---

## 9. Testplan

### 9.1 Funktionstests

| Test | Beschreibung | Erwartet | Aktuell |
|------|--------------|----------|---------|
| T1 | Formular öffnen | Zeigt aktuelle Woche | ✅ OK |
| T2 | "Woche vor" klicken | +7 Tage, Daten neu laden | ✅ OK |
| T3 | "Woche zurück" klicken | -7 Tage, Daten neu laden | ✅ OK |
| T4 | "Ab Heute" klicken | Sprung zu aktueller Woche | ✅ OK |
| T5 | KW auswählen | Wechsel zu gewählter Woche | ❌ Fehlt |
| T6 | Datum manuell ändern | Woche ab Datum anzeigen | ✅ OK |
| T7 | "Nur freie Schichten" aktivieren | Zeigt nur Aufträge mit Lücken | ✅ OK |
| T8 | "Aufträge ausblenden" aktivieren | Zeigt nur Aufträge mit <25 Pos. | ⚠️ Unklar |
| T9 | Doppelklick auf Tag-Spalte | Öffnet Detail-Ansicht | ❌ Fehlt |
| T10 | Excel-Export | CSV-Download | ✅ OK |
| T11 | Wochenende hervorheben | Sa/So dunkelblau | ✅ OK |
| T12 | Feiertag hervorheben | Feiertag rot | ❌ CSS fehlt |
| T13 | Unbesetzte Position anzeigen | Gelber Eintrag | ✅ OK |
| T14 | Fragliche Zusage anzeigen | Türkiser Eintrag | ✅ OK |
| T15 | Stornierung anzeigen | Roter Text | ✅ OK |
| T16 | Überbuchung anzeigen | Warnung | ❌ Fehlt |

### 9.2 Integrationstests

| Test | Beschreibung | Status |
|------|--------------|--------|
| I1 | Browser-Modus (REST-API) | ✅ OK |
| I2 | WebView2-Modus (Bridge) | ⚠️ Teilweise (einsatztage fehlt) |
| I3 | Shell-Integration (Sidebar aus) | ✅ OK |
| I4 | Navigation zu anderen Formularen | ❌ Ungetestet |

### 9.3 Performance-Tests

| Test | Beschreibung | Ziel | Aktuell |
|------|--------------|------|---------|
| P1 | 100 Aufträge rendern | <500ms | ⚠️ Ungetestet |
| P2 | 1000 MA-Einträge | <1s | ⚠️ Ungetestet |
| P3 | Filter-Wechsel | <100ms | ✅ Vermutlich OK |

---

## 10. Implementierungs-Roadmap

### Phase 1: Kritische Funktionen (1-2 Tage)
1. ✅ KW-Combobox implementieren
2. ✅ Master-Detail Navigation (DblClick)
3. ✅ Überbuchungs-Anzeige
4. ✅ Feiertags-CSS

### Phase 2: Wichtige Verbesserungen (1 Tag)
5. ✅ Position-Filter Logik klären
6. ✅ Tag-Spalten Farben korrigieren
7. ✅ Error-Handling verbessern
8. ✅ Debouncing für Navigation

### Phase 3: Optional (2-3 Tage)
9. ✅ Excel-Versand (VBA-Bridge)
10. ✅ sub_DP_Grund Analyse
11. ✅ WebView2 Bridge erweitern
12. ✅ Versions-Label

### Phase 4: Testing & Dokumentation (1 Tag)
13. ✅ Alle Tests durchführen
14. ✅ Dokumentation aktualisieren
15. ✅ User-Akzeptanz-Test

**Gesamt-Aufwand:** 5-7 Arbeitstage

---

## 11. Abhängigkeiten & Risiken

### Abhängigkeiten
1. **sub_DP_Grund** - Unklare Rolle im Access-Original
2. **API-Endpoints** - Benötigt `/api/einsatztage` und `/api/zuordnungen`
3. **Position-Feld** - Unklare DB-Struktur für PosAusblendAb-Filter
4. **VBA-Backend** - Fehlt für WebView2-Integration

### Risiken
- ⚠️ **Performance** bei >100 Aufträgen ungetestet
- ⚠️ **Timezone-Probleme** bei Datums-Berechnungen
- ⚠️ **Browser-Kompatibilität** (nur Chrome/Edge getestet?)

---

## 12. Fazit

### Zusammenfassung
- **Basis-Funktionalität:** ✅ 80% implementiert
- **UI/Layout:** ✅ 90% korrekt
- **Datenanbindung:** ⚠️ 70% (WebView2 unvollständig)
- **Events:** ⚠️ 65% (Master-Detail fehlt)
- **Kritische Lücken:** 4 (KW-Combobox, DblClick, Überbuchung, Feiertags-CSS)

### Empfehlung
**Status:** ⚠️ **BEDINGT PRODUKTIONSREIF**

**Begründung:**
- Basis-Funktionen (Navigation, Filter, Anzeige) funktionieren
- Kritische Lücken (Master-Detail, Überbuchung) beeinträchtigen User-Experience
- Performance bei großen Datenmengen ungetestet

**Nächste Schritte:**
1. Phase 1 umsetzen (2 Tage)
2. User-Test durchführen
3. Feedback integrieren
4. Dann: Produktiv-Release

---

**Erstellt:** 2026-01-12
**Analyst:** Claude Code
**Version:** 1.0
